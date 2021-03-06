#ifndef CSENGINE_H
#define CSENGINE_H

#include <QThread>
#include <csound.hpp>
#include <csPerfThread.hpp>



class CsEngine : public QThread
{
    Q_OBJECT
private:
    bool mStop;
    Csound cs;
    char *m_csd;
    int errorValue;
    QString errorString;
    int sliderCount;

    //QMutex mutex;

public:
    explicit CsEngine(char *csd);
    void run();
    void stop();
    QString getErrorString();
    int getErrorValue();

    void setChannel(QString channel, MYFLT value);



    double getChannel(QString);
    Csound *getCsound();
signals:
    //void newSliderValue(int silderno, int value);
    //void newClient(int clientsCount);
    void newCounterValue(int value);

public slots:
    void csEvent(QString event_string);
    //void compileOrc(QString code);
    void restart();
};

#endif // CSENGINE_H
