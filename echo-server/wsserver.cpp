#include "wsserver.h"
#include "QtWebSockets/qwebsocketserver.h"
#include "QtWebSockets/qwebsocket.h"
#include <QtCore/QDebug>
#include <QDir>


QT_USE_NAMESPACE



WsServer::WsServer(quint16 port, QObject *parent) :
    QObject(parent),
	m_pWebSocketServer(new QWebSocketServer(QStringLiteral("EchoServer"),
                                            QWebSocketServer::NonSecureMode, this)),
    m_clients()
{
    if (m_pWebSocketServer->listen(QHostAddress::Any, port)) {
        qDebug() << "WsServer listening on port" << port;
        connect(m_pWebSocketServer, &QWebSocketServer::newConnection,
                this, &WsServer::onNewConnection);
        connect(m_pWebSocketServer, &QWebSocketServer::closed, this, &WsServer::closed);
    }
	pauseIsOn = false;
	QList <QStringList> temp = QList <QStringList>() << QStringList() << QStringList() << QStringList();
	soundFiles << temp << temp <<temp; // clumsy way to initaliaze the list;
	getFilenames();
}



WsServer::~WsServer()
{
    m_pWebSocketServer->close();
    qDeleteAll(m_clients.begin(), m_clients.end());
}


void WsServer::onNewConnection()
{
    QWebSocket *pSocket = m_pWebSocketServer->nextPendingConnection();

    connect(pSocket, &QWebSocket::textMessageReceived, this, &WsServer::processTextMessage);
    //connect(pSocket, &QWebSocket::binaryMessageReceived, this, &WsServer::processBinaryMessage);
    connect(pSocket, &QWebSocket::disconnected, this, &WsServer::socketDisconnected);

    m_clients << pSocket;
	QString pausedSate = (pauseIsOn) ? "pause" : "continue"; // send message to connected client weather to start paused or playing
	pSocket->sendTextMessage(pausedSate);
    emit newConnection(m_clients.count());
}



void WsServer::processTextMessage(QString message)
{
    QWebSocket *pClient = qobject_cast<QWebSocket *>(sender());
    if (!pClient) {
        return;
    }
    qDebug()<<message;

    QStringList messageParts = message.split(" ");

//	if (messageParts[0]=="pause")
//		setPause();

//	if (messageParts[0]=="continue")
//		setContinue();

	if (messageParts[0]=="play") {
		QString instrument;
		int voice=0,length=0;

		if (messageParts[4]=="low") voice=LOW;
		if (messageParts[4]=="medium") voice=MEDIUM;
		if (messageParts[4]=="high") voice=HIGH;

		if (messageParts[5]=="short") length=SHORT;
		if (messageParts[5]=="medium") length=MEDIUM;
		if (messageParts[5]=="long") length=LONG;

		int soundFileCount = soundFiles[voice][length].length();
		instrument=soundFiles[voice][length].at(qrand()%soundFileCount);

		qDebug()<<"instrument number: "<<instrument;
		float distance = messageParts[3].toFloat(); // comes in 0..1
		float degree =  messageParts[2].toFloat(); // comes in 0..1
		QString scoreLine;
		scoreLine.sprintf("i \"play\" 0 5 \"%s\" %f %f ",instrument.toLocal8Bit().data(), degree, distance  );
		qDebug()<< scoreLine;
		emit newEvent(scoreLine);
	}


}

//void WsServer::processBinaryMessage(QByteArray message)
//{
//    QWebSocket *pClient = qobject_cast<QWebSocket *>(sender());
//    if (pClient) {
//        pClient->sendBinaryMessage(message);
//    }
//}

void WsServer::socketDisconnected()
{
    QWebSocket *pClient = qobject_cast<QWebSocket *>(sender());
    if (pClient) {
        m_clients.removeAll(pClient);
        emit newConnection(m_clients.count());
        pClient->deleteLater();
	}
}

void WsServer::getFilenames()
{	QStringList voices = QStringList()<< "low" << "medium" << "high";
	QStringList lengths = QStringList()<< "short" << "medium" << "long";
	for (int voice=LOW;voice<=HIGH;voice++) {

		for (int length=SHORT; length<=LONG; length++) {
			QString path = "../sounds/"+voices[voice]+"/"+lengths[length];
			QDir directory(path);
			QStringList files = directory.entryList(QStringList()<<"*.wav");

			foreach (QString fileName, files) {
					soundFiles[voice][length].append(path+"/"+fileName);
			}
			//qDebug()<<"directory: "<<path<<"files: "<< soundFiles[voice][length];
		}
	}
}


void WsServer::sendMessage(QWebSocket *socket, QString message )
{
    if (socket == 0)
    {
        return;
    }
    socket->sendTextMessage(message);

}

void WsServer::setPaused(bool paused)  // store the state (pause/continue), send to all clients)
{
	pauseIsOn = paused;
	QString pausedSate = (pauseIsOn) ? "pause" : "continue"; // send message to connected client weather to start paused or playing
	send2all(pausedSate);
}


void WsServer::send2all(QString message)
{
	foreach (QWebSocket *socket, m_clients) {
		socket->sendTextMessage(message);
	}
}
