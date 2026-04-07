#include "Mostheme.h"
#include "Mostheme_p.h"

#include "Mosthemefunctions.h"
#include "Moscolorgenerator.h"

#include <QtCore/QFile>
#include <QtCore/QLoggingCategory>
#include <QtCore/QJsonArray>
#include <QtGui/QFont>
#include <QColor>


MosTheme *MosTheme::instance()
{
    static MosTheme *theme = new MosTheme;


    return theme;
}
MosTheme *MosTheme::create(QQmlEngine *, QJSEngine *)
{
    return instance();
}
MosTheme::~MosTheme()
{

}
MosTheme::MosTheme(QObject *parent)
    : QObject{parent}
    , d_ptr(new MosThemePrivate(this))
{
    Q_D(MosTheme);
    d->initializeComponentPropertyHash();


    
    reloadTheme();

}
// @brief 主题重新加载
// @Function void reloadTheme()
// @Description 重新加载主题
void MosTheme::reloadTheme()
{
    Q_D(MosTheme);
    // 打开json文件
    QFile index(d->m_themeMainPath);
    if (!index.open(QIODevice::ReadOnly)) {
        qDebug() << "Index.json open faild:" << index.errorString();
        return;
    }
    QByteArray indexJson = index.readAll();
    index.close();
    QJsonParseError error;
    QJsonDocument indexDoc = QJsonDocument::fromJson(indexJson, &error);
    if (error.error == QJsonParseError::NoError) {
        d->m_mainObject = indexDoc.object();
        d->reloadMainTheme();
    } else {
        qDebug() << "Index.json parse error:" << error.errorString();
    }
} 
void MosThemePrivate::reloadMainTheme()
{
    Q_Q(MosTheme);
    m_mainTokenTable.clear();
    q->m_Primary.clear();

    auto __init__ = m_mainObject["__init__"].toObject();
    auto __base__ = __init__["__base__"].toObject();

    auto colorTextBase = __base__["colorTextBase"].toString();
    auto colorBgBase = __base__["colorBgBase"].toString();
    auto colorTextBaseList = colorTextBase.split("|");
    auto colorBgBaseList = colorBgBase.split("|");

    m_mainTokenTable["colorTextBase"] = q->isDark() ? colorTextBaseList.at(1) : colorTextBaseList.at(0);
    m_mainTokenTable["colorBgBase"] = q->isDark() ? colorBgBaseList.at(1) : colorBgBaseList.at(0);

    auto __vars__ = __init__["__vars__"].toObject();
    for (auto it = __vars__.constBegin(); it != __vars__.constEnd(); it++) {
        auto expr = it.value().toString().simplified();
        parseIndexExpr(it.key(), expr);
    }


    for (auto it = m_mainTokenTable.constBegin(); it != m_mainTokenTable.constEnd(); it++) {
        q->m_Primary[it.key()] = it.value();
    }
    emit q->PrimaryChanged();

    auto __components__ = __init__["__components__"].toObject();
    for (auto it = m_mainTokenTable.constBegin(); it != m_mainTokenTable.constEnd(); it++) {

        
    }
}
// @brief 暗色|亮色
// @Function bool isDark() const
// @Description 判断是否为暗色主题
bool MosTheme::isDark() const
{
    Q_D(const MosTheme);
    return d->m_darkMode == MosTheme::DarkMode::Dark;
}
// @brief 设置暗色|亮色
// @Function void setDarkMode(DarkMode darkMode)
// @Description 设置暗色主题
void MosTheme::setDarkMode(MosTheme::DarkMode darkMode)
{
    Q_D(MosTheme);
    d->m_darkMode = darkMode;
    emit darkModeChanged();
}
// @brief 获取暗色|亮色
// @Function DarkMode darkMode() const
// @Description 获取暗色主题
MosTheme::DarkMode MosTheme::darkMode() const
{
    Q_D(const MosTheme);
    return d->m_darkMode;
}
// @brief 主题变量var处理
// @Function void parseIndexExpr(const QString &tokenName, const QString &expr)
// @Description 解析主题变量var表达式
void MosThemePrivate::parseIndexExpr(const QString &tokenName, const QString &expr)
{
    Q_Q(MosTheme);
    if (expr.isEmpty()) {
        return;
    }
    
}
// @brief 初始化组件哈希列表
// @Function void initializeComponentPropertyHash()
// @Description 初始化组件哈希列表
void MosThemePrivate::initializeComponentPropertyHash()
{
    #define ADD_COMPONENT_PROPERTY(ComponentName) \
    g_componentTable->insert(#ComponentName, &q->m_##ComponentName);

    Q_Q(MosTheme);

    static bool initialized = false;

    if (!initialized) {
        initialized = true;

        ADD_COMPONENT_PROPERTY(MosButton);

    }
}
// @brief 注册默认组件主题
// @Function void registerDefaultComponentTheme()
// @Description 注册默认组件主题
void MosThemePrivate::registerDefaultComponentTheme(const QString &componentName, const QString &themePath)
{
    Q_Q(MosTheme);
    if (g_componentTable->contains(componentName)) {
        registerComponentTheme(q, componentName, g_componentTable->value(componentName), themePath, m_defaultTheme);
    }
}
// @brief 注册组件主题
// @Function void registerComponentTheme(QObject *themeObject, const QString &component, QVariantMap
void MosThemePrivate::registerComponentTheme(QObject *themeObject, const QString &component, QVariantMap *themeMap,const QString &themePath, QMap<QObject *, ThemeData> &dataMap)
{
    if (!themeObject || !themeMap) return;

    if (!dataMap.contains(themeObject))
    dataMap[themeObject] = ThemeData{};

    if (dataMap.contains(themeObject)) {
        dataMap[themeObject].themeObject = themeObject;
        dataMap[themeObject].componentMap[component].path = themePath;
        dataMap[themeObject].componentMap[component].tokenMap = themeMap;
    }
}
// @brief 组件默认主题重新加载
// @Function void reloadDefaultComponentTheme()
void MosThemePrivate::reloadDefaultComponentTheme()
{
    Q_Q(MosTheme);

    reloadComponentTheme(m_defaultTheme);
}
// @brief 组件主题重新加载
// @Function void reloadComponentTheme(const QMap<QObject *, ThemeData> &dataMap)
void MosThemePrivate::reloadComponentTheme(const QMap<QObject *, ThemeData> &dataMap)
{
    Q_Q(MosTheme);

    for (auto &themeData: dataMap) {
        for (auto it = themeData.componentMap.constBegin(); it != themeData.componentMap.constEnd(); it++) {
            auto componentName = it.key();
            auto componentTheme = it.value();
            reloadComponentThemeFile(themeData.themeObject, componentName, componentTheme);
        }
    }
}
// @brief 组件文件重新加载
// @Function void reloadComponentThemeFile(QObject *themeObject, const QString &componentName, const ThemeData::Component &componentTheme)
void MosThemePrivate::reloadComponentThemeFile(QObject *themeObject, const QString &componentName, const ThemeData::Component &componentTheme)
{
    Q_Q(MosTheme);

    auto tokenMapPtr = componentTheme.tokenMap;
    auto installTokenMap = componentTheme.installTokenMap;

    auto style = QJsonObject();
    if (reloadComponentImport(style, componentName)) {
        for (auto it = style.constBegin(); it != style.constEnd(); it++) {
            parseComponentExpr(tokenMapPtr, it.key(), it.value().toString().simplified());
        }

        /*! 读取通过 @link installComponentToken() 安装的变量, 存在则覆盖, 否则添加 */
        for (auto it = installTokenMap.constBegin(); it != installTokenMap.constEnd(); it++) {
            // parseComponentExpr(tokenMapPtr, it.key(), it.value());
        }

        auto signalName = componentName + "Changed";
        QMetaObject::invokeMethod(themeObject, signalName.toStdString().c_str());
    }
}
// @brief 组件文件重新加载
// @Function void reloadComponentImport(QJsonObject &style, const QString &componentName)
bool MosThemePrivate::reloadComponentImport(QJsonObject &style, const QString &componentName)
{
    Q_Q(MosTheme);

    const auto __component__ = m_mainObject["__component__"].toObject();
    if (__component__.contains(componentName)) {
        const auto themePath = __component__[componentName].toString();
        if (QFile theme(themePath); theme.open(QIODevice::ReadOnly)) {
            QJsonParseError error;
            QJsonDocument themeDoc = QJsonDocument::fromJson(theme.readAll(), &error);
            if (error.error == QJsonParseError::NoError) {
                const auto object = themeDoc.object();
                const auto componentObject = themeDoc.object();
                const auto __init__ = object["__init__"].toObject();
                if (__init__.contains("__import__")) {
                    const auto __import__ = __init__["__import__"].toArray();
                    for (const auto &v : __import__) {
                        reloadComponentImport(style, v.toString());
                    }
                }
                const auto __style__ = componentObject["__style__"].toObject();
                for (auto it = __style__.constBegin(); it != __style__.constEnd(); it++) {
                    style[it.key()] = it.value();
                }
            } else {
                qDebug() << QString("Parse import component theme [%1] faild:").arg(themePath) << error.errorString();
            }
        } else {
            qDebug() << "Open import component theme faild:" << theme.errorString() << themePath;
        }
        return true;
    } else {
        return false;
    }
}
void MosThemePrivate::parseComponentExpr(QVariantMap *tokenMapPtr, const QString &tokenName, const QString &expr)
{
    if (expr.startsWith('@')) {
        auto refTokenName = expr.mid(1);
        if (m_mainTokenTable.contains(refTokenName)) {
            tokenMapPtr->insert(tokenName, m_mainTokenTable[refTokenName]);
        } else {
            qDebug() << QString("Component: Token(%1):Ref(%2) not found!").arg(tokenName, refTokenName);
        }
    } else if (expr.startsWith('$')) {
        parse(*tokenMapPtr, tokenName, expr);
    } else if (expr.startsWith('#')) {
        /*! 按颜色处理 */
        auto color = QColor(expr);
        /*! 从预置颜色中获取 */
        if (expr.startsWith("Preset_"))
            // color = MusColorGenerator::presetToColor(expr.mid(1));
        if (!color.isValid())
            qDebug() << QString("Component [%1]: Unknown color:") << expr;
        tokenMapPtr->insert(tokenName, color);
    } else {
        /*! 按字符串处理 */
        tokenMapPtr->insert(tokenName, expr);
    }
}
void MosThemePrivate::parse(QMap<QString, QVariant> &out, const QString &tokenName, const QString &expr)
{
    Q_Q(MosTheme);

    static QHash<QString, Function> g_funcTable {
        { "genColor",          Function::GenColor },
        { "genFontFamily",     Function::GenFontFamily },
        { "genFontSize",       Function::GenFontSize },
        { "genFontLineHeight", Function::GenFontLineHeight },
        { "genRadius",         Function::GenRadius },
        { "darker",            Function::Darker },
        { "lighter",           Function::Lighter },
        { "brightness",        Function::Brightness },
        { "alpha",             Function::Alpha },
        { "onBackground",      Function::OnBackground },
        { "multiply",          Function::Multiply }
    };

    static QRegularExpression g_funcRegex("\\$([^)]+)\\(");
    static QRegularExpression g_argsRegex("\\(([^)]+)\\)");

    QRegularExpressionMatch funcMatch = g_funcRegex.match(expr);
    QRegularExpressionMatch argsMatch = g_argsRegex.match(expr);
    if (funcMatch.hasMatch()) {
        QString func = funcMatch.captured(1);
        QString args = argsMatch.captured(1);
        if (g_funcTable.contains(func)) {
            switch (g_funcTable[func]) {
            case Function::GenColor:
            {
                QColor color = colorFromIndexTable(args);
                if (color.isValid()) {
                    auto colorBgBase = m_mainTokenTable["colorBgBase"].value<QColor>();
                    auto colors = MosThemeFunctions::genColor(color, !q->isDark(), colorBgBase);
                    if (q->isDark()) {
                        /*! 暗黑模式需要后移并翻转色表 */
                        colors.append(colors[0]);
                        std::reverse(colors.begin(), colors.end());
                    }
                    for (int i = 0; i < colors.length(); i++) {
                        auto genColor = colors.at(i);
                        auto key = tokenName + "-" + QString::number(i + 1);
                        out[key] = genColor;
                    }
                } else {
                    qDebug() << QString("func genColor() invalid color:(%1)").arg(args);
                }
            } break;
            case Function::GenFontFamily:
            {
                out["fontFamilyBase"] = MosThemeFunctions::genFontFamily(args.trimmed());
            } break;
            case Function::GenFontSize:
            {
                bool ok = false;
                auto base = args.toDouble(&ok);
                if (ok) {
                    const auto fontSizes = MosThemeFunctions::genFontSize(base);
                    for (int i = 0; i < fontSizes.length(); i++) {
                        auto genFontSize = fontSizes.at(i);
                        auto key = tokenName + "-" + QString::number(i + 1);
                        out[key] = genFontSize;
                    }
                } else {
                    qDebug() << QString("func genFontSize() invalid size:(%1)").arg(args);
                }
            } break;
            case Function::GenFontLineHeight:
            {
                bool ok = false;
                auto base = args.toDouble(&ok);
                if (ok) {
                    const auto fontLineHeights = MosThemeFunctions::genFontLineHeight(base);
                    for (int i = 0; i < fontLineHeights.length(); i++) {
                        auto genFontLineHeight = fontLineHeights.at(i);
                        auto key = tokenName + "-" + QString::number(i + 1);
                        out[key] = genFontLineHeight;
                    }
                } else {
                    qDebug() << QString("func genFontLineHeight() invalid size:(%1)").arg(args);
                }
            } break;
            case Function::GenRadius:
            {
                bool ok = false;
                auto base = args.toInt(&ok);
                if (ok) {
                    const auto radius = MosThemeFunctions::genRadius(base);
                    for (int i = 0; i < radius.length(); i++) {
                        auto genRadius = radius.at(i);
                        auto key = tokenName + "-" + QString::number(i + 1);
                        out[key] = genRadius;
                    }
                } else {
                    qDebug() << QString("func genRadius() invalid size:(%1)").arg(args);
                }
            } break;
            case Function::Darker:
            {
                auto argList = args.split(',');
                if (argList.length() == 1) {
                    auto arg1 = colorFromIndexTable(argList.at(0));
                    out[tokenName] = MosThemeFunctions::darker(arg1);
                } else if (argList.length() == 2) {
                    auto arg1 = colorFromIndexTable(argList.at(0));
                    auto arg2 = numberFromIndexTable(argList.at(1));
                    out[tokenName] = MosThemeFunctions::darker(arg1, arg2);
                } else {
                    qDebug() << QString("func darker() only accepts 1/2 parameters:(%1)").arg(args);
                }
            } break;
            case Function::Lighter:
            {
                auto argList = args.split(',');
                if (argList.length() == 1) {
                    auto arg1 = colorFromIndexTable(argList.at(0));
                    out[tokenName] = MosThemeFunctions::lighter(arg1);
                } else if (argList.length() == 2) {
                    auto arg1 = colorFromIndexTable(argList.at(0));
                    auto arg2 = numberFromIndexTable(argList.at(1));
                    out[tokenName] = MosThemeFunctions::lighter(arg1, arg2);
                } else {
                    qDebug() << QString("func lighter() only accepts 1/2 parameters:(%1)").arg(args);
                }
            } break;
            case Function::Brightness:
            {
                auto argList = args.split(',');
                if (argList.length() == 1) {
                    auto arg1 = colorFromIndexTable(argList.at(0));
                    out[tokenName] = MosThemeFunctions::brightness(arg1, !q->isDark());
                } else if (argList.length() == 2) {
                    auto arg1 = colorFromIndexTable(argList.at(0));
                    auto arg2 = numberFromIndexTable(argList.at(1));
                    out[tokenName] = MosThemeFunctions::brightness(arg1, !q->isDark(), arg2);
                } else if (argList.length() == 3) {
                    auto arg1 = colorFromIndexTable(argList.at(0));
                    auto arg2 = numberFromIndexTable(argList.at(1));
                    auto arg3 = numberFromIndexTable(argList.at(2));
                    out[tokenName] = MosThemeFunctions::brightness(arg1, !q->isDark(), arg2, arg3);
                } else {
                    qDebug() << QString("func brightness() only accepts 1/2/3 parameters:(%1)").arg(args);
                }
            } break;
            case Function::Alpha:
            {
                auto argList = args.split(',');
                if (argList.length() == 1) {
                    auto arg1 = colorFromIndexTable(argList.at(0));
                    out[tokenName] = MosThemeFunctions::alpha(arg1);
                } else if (argList.length() == 2) {
                    auto arg1 = colorFromIndexTable(argList.at(0));
                    auto arg2 = numberFromIndexTable(argList.at(1));
                    out[tokenName] = MosThemeFunctions::alpha(arg1, arg2);
                } else {
                    qDebug() << QString("func alpha() only accepts 1/2 parameters:(%1)").arg(args);
                }
            } break;
            case Function::OnBackground:
            {
                auto argList = args.split(',');
                if (argList.length() == 2) {
                    auto arg1 = colorFromIndexTable(argList.at(0).trimmed());
                    auto arg2 = colorFromIndexTable(argList.at(1).trimmed());
                    out[tokenName] = MosThemeFunctions::onBackground(arg1, arg2);
                } else {
                    qDebug() << QString("func onBackground() only accepts 2 parameters:(%1)").arg(args);
                }
            } break;
            case Function::Multiply:
            {
                auto argList = args.split(',');
                if (argList.length() == 2) {
                    auto arg1 = numberFromIndexTable(argList.at(0).trimmed());
                    auto arg2 = numberFromIndexTable(argList.at(1).trimmed());
                    out[tokenName] = MosThemeFunctions::multiply(arg1, arg2);
                } else {
                    qDebug() << QString("func multiply() only accepts 2 parameters:(%1)").arg(args);
                }
            } break;
            default:
                break;
            }
        } else {
            qDebug() << "Unknown func name:" << func;
        }
    } else {
        qDebug() << "Unknown expr:" << expr;
    }
}
// @brief 从预设颜色表中获取颜色
// @Function QColor colorFromIndexTable(const QString &tokenName)   
QColor MosThemePrivate::colorFromIndexTable(const QString &tokenName)
{
    QColor color;
    auto refTokenName = tokenName;
    if (refTokenName.startsWith('@')) {
        refTokenName = tokenName.mid(1);
        if (m_mainTokenTable.contains(refTokenName)) {
            auto v = m_mainTokenTable[refTokenName];
            color = v.value<QColor>();
            if (!color.isValid()) {
                qDebug() << QString("Token toColor faild:(%1)").arg(tokenName);
            }
        } else {
            qDebug() << QString("Main Token(%1) not found!").arg(refTokenName);
        }
    } else {
        /*! 按颜色处理 */
        color = QColor(tokenName);
        /*! 从预置颜色中获取 */
        if (tokenName.startsWith("#Preset_"))
            color = MosColorGenerator::presetToColor(tokenName.mid(1));
        if (!color.isValid()) {
            qDebug() << QString("Token toColor faild:(%1)").arg(tokenName);
        }
    }

    return color;
}

qreal MosThemePrivate::numberFromIndexTable(const QString &tokenName)
{
    qreal number = 0;
    auto refTokenName = tokenName;
    if (refTokenName.startsWith('@')) {
        refTokenName = tokenName.mid(1);
        if (m_mainTokenTable.contains(refTokenName)) {
            auto value = m_mainTokenTable[refTokenName];
            auto ok = false;
            number = value.toDouble(&ok);
            if (!ok) {
                qDebug() << QString("Token toDouble faild:(%1)").arg(refTokenName);
            }
        } else {
            qDebug() << QString("Main Token(%1) not found!").arg(refTokenName);
        }
    } else {
        auto ok = false;
        number = tokenName.toDouble(&ok);
        if (!ok) {
            qDebug() << QString("Token toDouble faild:(%1)").arg(tokenName);
        }
    }

    return number;
}