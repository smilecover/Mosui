#ifndef MOSICON_H
#define MOSICON_H

#include <QtCore/QObject>
#include <QtQml/qqml.h>

#include "Mosglobal.h"

class MOSUIBASIC_EXPORT MosIcon : public QObject
{
    Q_OBJECT
    QML_SINGLETON
    QML_NAMED_ELEMENT(MosIcon)
public:
    enum class Type : uint16_t {
        HomeOutlined = 0xe600,
        SettingsOutlined = 0xe851,
        UniversalOutlined = 0xe63e,
        ButtonOutlined = 0xe6fc,
        CaptionbarOutlined = 0xe686,
        LeftOutlined = 0xe70e,
        RightOutlined = 0xec97,
        UpOutlined = 0xec98,
        DownOutlined = 0xec99,
        MinusOutlined = 0xe621,
        CodeOutlined = 0xe74f,
        CopyOutlined = 0xe65f,
        PlayCircleOutlined = 0xe65d,
        CloseOutlined = 0xeb1b,
        SerialportOutlined = 0xe60a,
        FaultOutlined = 0xe602,
        ControlOutlined = 0xe647,
        WaveOutlined = 0xe601,
        CloseCircleFilled = 0xeb1b
        
        
    };
    Q_ENUM(Type);

    ~MosIcon();

    static MosIcon *instance();
    static MosIcon *create(QQmlEngine *, QJSEngine *);

    static Q_INVOKABLE QVariantMap allIconNames();
private:
    explicit MosIcon(QObject *parent = nullptr);
};

#endif // MOSICON_H