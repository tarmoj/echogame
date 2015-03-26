#-------------------------------------------------
#
# Project created by QtCreator 2015-02-04T15:01:47
#
#-------------------------------------------------

QT       += core gui websockets

greaterThan(QT_MAJOR_VERSION, 4): QT += widgets

TARGET = echo-server
TEMPLATE = app

INCLUDEPATH += /usr/local/include/csound

SOURCES += main.cpp\
        echowindow.cpp \
    csengine.cpp \
    wsserver.cpp

HEADERS  += echowindow.h \
    csengine.h \
    wsserver.h

FORMS    += echowindow.ui

unix|win32: LIBS += -lcsnd6

unix|win32: LIBS += -lcsound64
