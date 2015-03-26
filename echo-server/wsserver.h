#ifndef WSSERVER_H
#define WSSERVER_H

#include <QObject>
#include <QtCore/QList>
#include <QtCore/QByteArray>
#include <QtCore/QHash>
#include <QStringList>

QT_FORWARD_DECLARE_CLASS(QWebSocketServer)
QT_FORWARD_DECLARE_CLASS(QWebSocket)

#define LOW 0 // indexes for soundFie list
#define  MEDIUM 1
#define HIGH 2
#define SHORT 0
#define LONG 2

class WsServer : public QObject
{
    Q_OBJECT
public:
    explicit WsServer(quint16 port, QObject *parent = NULL);
    ~WsServer();

	void sendMessage(QWebSocket *socket, QString message);
	void setPaused(bool paused);
	void send2all(QString message);

Q_SIGNALS:
    void closed();
    void newConnection(int connectionsCount);
    void newEvent(QString eventString);


private Q_SLOTS:
    void onNewConnection();
    void processTextMessage(QString message);
    //void processBinaryMessage(QByteArray message);
    void socketDisconnected();


private:
    QWebSocketServer *m_pWebSocketServer;
    QList<QWebSocket *> m_clients;
	void getFilenames();
	//QHash<QString, int>  clientsHash;
	bool pauseIsOn;
	QList <QList <QStringList> >  soundFiles ; // directory structure: low/mid/high -> short/mid/long -> filenames
};



#endif // WSSERVER_H
