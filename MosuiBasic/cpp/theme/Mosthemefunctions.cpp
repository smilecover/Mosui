#include "Mosthemefunctions.h"
#include "Moscolorgenerator.h"
#include "Mossizegenerator.h"
#include "Mosradiusgenerator.h"

#include <QtGui/QFontDatabase>

MosThemeFunctions::MosThemeFunctions(QObject *parent)
    : QObject{parent}
{

}
MosThemeFunctions::~MosThemeFunctions()
{

}
MosThemeFunctions *MosThemeFunctions::instance()
{
    static MosThemeFunctions *ins = new MosThemeFunctions;
    return ins;
}

MosThemeFunctions *MosThemeFunctions::create(QQmlEngine *, QJSEngine *)
{
    return instance();
}

QList<QColor> MosThemeFunctions::genColor(int preset, bool light, const QColor &background)
{
    return MosColorGenerator::generate(MosColorGenerator::Preset(preset), light, background);
}

QList<QColor> MosThemeFunctions::genColor(const QColor &color, bool light, const QColor &background)
{
    return MosColorGenerator::generate(color, light, background);   
}

QList<QString> MosThemeFunctions::genColorString(const QColor &color, bool light, const QColor &background)
{
    QList<QString> result;
    const auto listColor = MosColorGenerator::generate(color, light, background);
    for (const auto &color : listColor)
        result.append(color.name());

    return result;
}

QList<qreal> MosThemeFunctions::genFontSize(qreal fontSizeBase)
{
    return MosSizeGenerator::generateFontSize(fontSizeBase);
}

QList<qreal> MosThemeFunctions::genFontLineHeight(qreal fontSizeBase)
{
    return MosSizeGenerator::generateFontLineHeight(fontSizeBase);
}

QList<int> MosThemeFunctions::genRadius(int radiusBase)
{
    return MosRadiusGenerator::generateRadius(radiusBase);
}

QString MosThemeFunctions::genFontFamily(const QString &familyBase)
{
    const auto families = familyBase.split(',');
#if QT_VERSION >= QT_VERSION_CHECK(6, 0, 0)
    const auto database = QFontDatabase::families();
#else
    const auto database = QFontDatabase().families();
#endif
    for(auto family: families) {
        auto normalize = family.remove('\'').remove('\"').trimmed();
        if (database.contains(normalize)) {
            return normalize.trimmed();
        }
    }
    return database.first();
}

QColor MosThemeFunctions::darker(const QColor &color, int factor)
{
    return color.darker(factor);
}

QColor MosThemeFunctions::lighter(const QColor &color, int factor)
{
    return color.lighter(factor);
}

QColor MosThemeFunctions::brightness(const QColor &color, bool light, int lighterFactor, int darkerFactor)
{
    if (light) {
        return darker(color, lighterFactor);
    } else {
        return lighter(color, darkerFactor);
    }
}

QColor MosThemeFunctions::alpha(const QColor &color, qreal alpha)
{
    return QColor(color.red(), color.green(), color.blue(), alpha * 255);
}

QColor MosThemeFunctions::onBackground(const QColor &color, const QColor &background)
{
    const auto fg = color.toRgb();
    const auto bg = background.toRgb();
    const auto alpha = fg.alphaF() + bg.alphaF() * (1 - fg.alphaF());

    return QColor::fromRgbF(
            fg.redF() * fg.alphaF() + bg.redF() * bg.alphaF() * (1 - fg.alphaF()) / alpha,
            fg.greenF() * fg.alphaF() + bg.greenF() * bg.alphaF() * (1 - fg.alphaF()) / alpha,
            fg.blueF() * fg.alphaF() + bg.blueF() * bg.alphaF() * (1 - fg.alphaF()) / alpha,
            alpha
        );
}

qreal MosThemeFunctions::multiply(qreal num1, qreal num2)
{
    return num1 * num2;
}
