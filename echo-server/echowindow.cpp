#include "echowindow.h"
#include "ui_echowindow.h"


EchoWindow::EchoWindow(QWidget *parent) :
	QMainWindow(parent),
	ui(new Ui::EchoWindow)
{
	ui->setupUi(this);

	wsServer = new WsServer(11011);
	cs = new CsEngine("../echogame.csd");
	cs->start();
	connect(wsServer, SIGNAL(newConnection(int)), this, SLOT(setClientsCount(int)));
	connect(wsServer, SIGNAL(newEvent(QString)),cs,SLOT(csEvent(QString))  );

	on_repeatAfterSlider_valueChanged(ui->repeatAfterSlider->value());
	cs->setChannel("volume",(MYFLT) ui->volumeSlider->value()/100.0);
	cs->setChannel("bgLevel",(MYFLT) ui->backgroundSlider->value()/100.0);
	cs->setChannel("repeatcount", (MYFLT) ui->repeatCount->value() );
}

EchoWindow::~EchoWindow()
{
	delete ui;
}

void EchoWindow::setClientsCount(int clientsCount)
{
	ui->numberOfClientsLabel->setText(QString::number(clientsCount));
}


void EchoWindow::on_volumeSlider_valueChanged(int value)
{
	cs->setChannel("volume",(MYFLT) value/100.0);
}

void EchoWindow::on_backgroundSlider_valueChanged(int value)
{
	cs->setChannel("bgLevel",(MYFLT) value/100.0);
}

void EchoWindow::on_repeatCount_valueChanged(int value)
{
	cs->setChannel("repeatcount", (MYFLT) value);
}

void EchoWindow::on_repeatAfterSlider_valueChanged(int value)
{
	cs->setChannel("returntime", (MYFLT)value);
	ui->repeatAfterLabel->setText(QString::number(value));
}

void EchoWindow::on_pauseButton_toggled(bool checked)
{
	wsServer->setPaused(checked);
}

void EchoWindow::on_lowButton_toggled(bool checked)
{	QString state = (checked) ? "disable" : "enable";
	wsServer->send2all("range low "+state);
}

void EchoWindow::on_mediumButton_toggled(bool checked)
{
	QString state = (checked) ? "disable" : "enable";
	wsServer->send2all("range medium "+state);
}

void EchoWindow::on_highButton_toggled(bool checked)
{
	QString state = (checked) ? "disable" : "enable";
	wsServer->send2all("range high "+state);
}
