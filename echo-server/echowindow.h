#ifndef ECHOWINDOW_H
#define ECHOWINDOW_H

#include <QMainWindow>
#include "csengine.h"
#include "wsserver.h"

namespace Ui {
class EchoWindow;
}

class EchoWindow : public QMainWindow
{
	Q_OBJECT

public:
	explicit EchoWindow(QWidget *parent = 0);
	~EchoWindow();

public slots:
	void setClientsCount(int clientsCount);

private slots:


	void on_volumeSlider_valueChanged(int value);

	void on_backgroundSlider_valueChanged(int value);

	void on_repeatCount_valueChanged(int arg1);

	void on_repeatAfterSlider_valueChanged(int value);

	void on_pauseButton_toggled(bool checked);

	void on_lowButton_toggled(bool checked);

	void on_mediumButton_toggled(bool checked);

	void on_highButton_toggled(bool checked);

private:
	Ui::EchoWindow *ui;	
	CsEngine *cs;
	WsServer *wsServer;

};

#endif // ECHOWINDOW_H
