#include "echowindow.h"
#include <QApplication>

int main(int argc, char *argv[])
{
	QApplication a(argc, argv);
	EchoWindow w;
	w.show();

	return a.exec();
}
