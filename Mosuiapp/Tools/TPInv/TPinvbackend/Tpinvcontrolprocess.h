#ifndef TPINVCONTROLPROCESS_H
#define TPINVCONTROLPROCESS_H

#include <QByteArray>
#include <QObject>
#include <QString>
#include <QVariant>
#include <QVariantList>
#include <QtQml/qqml.h>
#include <qlist.h>
#include <qstringview.h>
#include <qtmetamacros.h>
#include "Mosdefinitions.h"
#include "ring_buffer.h"

class Tpinvcontrolprocess : public QObject
{
    Q_OBJECT
    QML_SINGLETON
    QML_NAMED_ELEMENT(TpinvControlProcess)
    MOSUI_PROPERTY_READONLY(QList<QByteArray>, txBuffer)
    

public:


    ~Tpinvcontrolprocess() override;

    static Tpinvcontrolprocess *instance();
    static Tpinvcontrolprocess *create(QQmlEngine *, QJSEngine *);

    Q_INVOKABLE int Initprocess() const;

Q_SIGNALS:


private:
    explicit Tpinvcontrolprocess(QObject *parent = nullptr);

    static constexpr int MaxRxBufferSize = 4096;


    // 绑定逆变器控制
    void bandTpInvcontroldata();
    // 构建逆变器参数
    void buildTpInvParamet();
    
    QByteArray rxBuffer_;

    /*
    txBuffer_构成

    0 = 0xBB 0xF0 0/1(启停) 0(保留) 0/1/2(工作模式) 0(保留) 交流有效值低字节 交流有效值低字节 交流频率低字节 交流频率高字节 母线电压低字节 母线电压高字节   0(保留)   0(保留)   0(保留)   0(保留)   0(保留) 0(保留) 校验位低字节 校验位高字节
        0    1    2         3      4               5       6               7               8               9            10              11        12        13        14        15        16        17          18          19

    
    */
    tpinv::RingBuffer cmdBuffer;
    
    int parsedFrameCount_ = 0;
    int droppedFrameCount_ = 0;
    QString lastFrameHex_;
    QString lastErrorString_;

};

#endif // TPINVCONTROLPROCESS_H
