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
        HomeOutlined = 0xe000,
        SettingsOutlined = 0xe010,
        UniversalOutlined = 0xe007,
        ButtonOutlined = 0xe00d,
        CaptionbarOutlined = 0xe00c,
        LeftOutlined = 0xe00e,
        RightOutlined = 0xe3a5,
        UpOutlined = 0xe3a6,
        DownOutlined = 0xe3a7,
        MinusOutlined = 0xe005,
        CodeOutlined = 0xe00f,
        CopyOutlined = 0xe00a,
        PlayCircleOutlined = 0xe009,
        CloseOutlined = 0xe229,
        SerialportOutlined = 0xe003,
        SerialPortOutlined = 0xe003,
        FaultOutlined = 0xe002,
        ControlOutlined = 0xe008,
        WaveOutlined = 0xe001,
        CloseCircleFilled = 0xe229,
        ArrowLeftOutlined = 0xe011,
        CalendarOutlined = 0xe012,
        CaretDownOutlined = 0xe013,
        CaretLeftOutlined = 0xe014,
        CaretRightOutlined = 0xe015,
        CaretUpOutlined = 0xe016,
        CheckCircleFilled = 0xe017,
        CheckOutlined = 0xe018,
        ClockCircleOutlined = 0xe019,
        DoubleLeftOutlined = 0xe01a,
        DoubleRightOutlined = 0xe01b,
        ExclamationCircleFilled = 0xe01c,
        EyeOutlined = 0xe01d,
        LoadingOutlined = 0xe01e,
        MoonOutlined = 0xe01f,
        PlusOutlined = 0xe020,
        PushpinOutlined = 0xe021,
        RotateLeftOutlined = 0xe022,
        RotateRightOutlined = 0xe023,
        SearchOutlined = 0xe024,
        StarFilled = 0xe025,
        SunOutlined = 0xe026,
        SwapOutlined = 0xe027,
        ZoomInOutlined = 0xe028,
        ZoomOutOutlined = 0xe029,
        ChartOutlined = 0xe02a,
        AnimatedImageOutlined = 0xe02b,
        AvatarOutlined = 0xe02c,
        BadgeOutlined = 0xe02d,
        MqttOutlined = 0xe02e,
        ToolsOutlined = 0xe02f,
        RocketOutlined = 0xe030,
        FontColorsOutlined = 0xe031,
        GroupOutlined = 0xe032,
        ExpandOutlined = 0xe033,
        MessageOutlined = 0xe034,
        NotificationOutlined = 0xe035,
        LineOutlined = 0xe036,
        ColumnWidthOutlined = 0xe037,
        NumberOutlined = 0xe038,
        FontSizeOutlined = 0xe039,
        QuestionCircleOutlined = 0xe03a,
        CheckCircleOutlined = 0xe03b,
        CheckSquareOutlined = 0xe03c,
        TableOutlined = 0xe03d,
        DragOutlined = 0xe03e,
        RadiusOutlined = 0xe03f,
        BorderOutlined = 0xe040,
        BgColorsOutlined = 0xe041,
        IdcardOutlined = 0xe042,
        PictureOutlined = 0xe043,
        AppstoreOutlined = 0xe044,
        MenuUnfoldOutlined = 0xe045,
        MenuOutlined = 0xe046,
        InboxOutlined = 0xe047,
        FileImageOutlined = 0xe048,
        EditOutlined = 0xe049,
        SelectOutlined = 0xe04a,
        SafetyOutlined = 0xe04b,
        FileOutlined = 0xe04c,
        MoreOutlined = 0xe04d,
        InfoCircleOutlined = 0xe04e,
        DashboardOutlined = 0xe04f,
        StarOutlined = 0xe050,
        AimOutlined = 0xe051,
        SolutionOutlined = 0xe052,
        ApartmentOutlined = 0xe053,
        TagsOutlined = 0xe054,
        WebOutlined = 0xe055,
        LinkOutlined = 0xe056,
        SearchOutlined2 = 0xe057,
        DashOutlined = 0xe058,
        FieldTimeOutlined = 0xe059,
        UserOutlined = 0xe05a
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