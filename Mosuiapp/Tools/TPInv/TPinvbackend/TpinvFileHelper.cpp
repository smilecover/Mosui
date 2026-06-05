#include "TpinvFileHelper.h"

#include <QFile>
#include <QFileInfo>
#include <QTextStream>
#include <QDir>
#include <QRegularExpression>
#include <QDebug>
#include <QQmlEngine>

TpinvFileHelper::TpinvFileHelper(QObject *parent)
    : QObject(parent)
{
}

TpinvFileHelper::~TpinvFileHelper() = default;

TpinvFileHelper *TpinvFileHelper::instance()
{
    static TpinvFileHelper *ins = new TpinvFileHelper;
    return ins;
}

TpinvFileHelper *TpinvFileHelper::create(QQmlEngine *qmlEngine, QJSEngine *)
{
    auto *helper = instance();
    if (qmlEngine) {
        QQmlEngine::setObjectOwnership(helper, QQmlEngine::CppOwnership);
    }
    return helper;
}

QString TpinvFileHelper::lastError() const
{
    return lastError_;
}

QString TpinvFileHelper::openCommandFile(const QString &filePath)
{
    lastError_.clear();

    if (filePath.isEmpty()) {
        lastError_ = QStringLiteral("文件路径为空");
        qWarning() << "TpinvFileHelper::openCommandFile:" << lastError_;
        return {};
    }

    QFile file(filePath);
    if (!file.exists()) {
        lastError_ = QStringLiteral("文件不存在: ") + filePath;
        qWarning() << "TpinvFileHelper::openCommandFile:" << lastError_;
        return {};
    }

    if (!file.open(QIODevice::ReadOnly | QIODevice::Text)) {
        lastError_ = QStringLiteral("无法打开文件: ") + file.errorString();
        qWarning() << "TpinvFileHelper::openCommandFile:" << lastError_;
        return {};
    }

    QTextStream stream(&file);
    const QString content = stream.readAll();
    file.close();

    qDebug() << "TpinvFileHelper::openCommandFile: 成功读取文件" << filePath
             << "大小:" << content.size() << "字节";
    return content;
}

bool TpinvFileHelper::saveCommandData(const QString &filePath, const QString &data)
{
    lastError_.clear();

    if (filePath.isEmpty()) {
        lastError_ = QStringLiteral("文件路径为空");
        qWarning() << "TpinvFileHelper::saveCommandData:" << lastError_;
        return false;
    }

    // 确保目标目录存在（支持创建新文件）
    QFileInfo fileInfo(filePath);
    QDir dir = fileInfo.absoluteDir();
    if (!dir.exists()) {
        if (!dir.mkpath(QStringLiteral("."))) {
            lastError_ = QStringLiteral("无法创建目录: ") + dir.absolutePath();
            qWarning() << "TpinvFileHelper::saveCommandData:" << lastError_;
            return false;
        }
    }

    QFile file(filePath);
    if (!file.open(QIODevice::WriteOnly | QIODevice::Text | QIODevice::Truncate)) {
        lastError_ = QStringLiteral("无法写入文件: ") + file.errorString();
        qWarning() << "TpinvFileHelper::saveCommandData:" << lastError_;
        return false;
    }

    QTextStream stream(&file);
    stream << data;
    file.close();

    qDebug() << "TpinvFileHelper::saveCommandData: 成功保存到" << filePath
             << "大小:" << data.size() << "字节";
    return true;
}

bool TpinvFileHelper::saveCommandTableData(const QString &filePath,
                                            const QVariantList &rows,
                                            int byteCount)
{
    lastError_.clear();

    if (filePath.isEmpty()) {
        lastError_ = QStringLiteral("文件路径为空");
        return false;
    }

    if (rows.isEmpty()) {
        lastError_ = QStringLiteral("没有可保存的指令数据");
        return false;
    }

    QStringList lines;
    for (const QVariant &rowVar : rows) {
        const QVariantMap row = rowVar.toMap();
        QStringList bytes;
        for (int col = 0; col < byteCount; ++col) {
            const QString key = QStringLiteral("Byte%1").arg(col);
            const QString value = row.value(key).toString().trimmed();
            if (!value.isEmpty()) {
                // 标准化为两位十六进制大写
                QString normalized = value.toUpper();
                if (normalized.startsWith(QStringLiteral("0X"))) {
                    normalized = normalized.mid(2);
                }
                if (normalized.length() == 1) {
                    normalized.prepend(QStringLiteral("0"));
                }
                if (normalized.length() == 2) {
                    bytes.append(normalized);
                }
            }
        }
        if (!bytes.isEmpty()) {
            lines.append(bytes.join(QStringLiteral(" ")));
        }
    }

    if (lines.isEmpty()) {
        lastError_ = QStringLiteral("指令表格中没有有效数据");
        return false;
    }

    return saveCommandData(filePath, lines.join(QStringLiteral("\n")) + QStringLiteral("\n"));
}

QVariantMap TpinvFileHelper::parseCommandContent(const QString &content)
{
    lastError_.clear();
    QVariantMap result;
    int commandCount = 0;
    int maxBytes = 0;
    QVariantList rows;

    if (content.isEmpty()) {
        result[QStringLiteral("rows")] = rows;
        result[QStringLiteral("commandCount")] = 0;
        result[QStringLiteral("byteCount")] = 0;
        result[QStringLiteral("error")] = QStringLiteral("文件内容为空");
        return result;
    }

    // 按行分割，忽略空行和注释行（以 # 开头）
    const QStringList lines = content.split(QStringLiteral("\n"), Qt::SkipEmptyParts);

    for (const QString &line : lines) {
        const QString trimmed = line.trimmed();
        if (trimmed.isEmpty() || trimmed.startsWith(QStringLiteral("#"))) {
            continue;
        }

        // 按空格/tab/逗号分割字节
        const QStringList tokens = trimmed.split(QRegularExpression(QStringLiteral("[\\s,]+")),
                                                  Qt::SkipEmptyParts);
        if (tokens.isEmpty()) {
            continue;
        }

        QVariantMap row;
        int col = 0;
        for (const QString &token : tokens) {
            // 标准化十六进制字节
            QString byte = token.toUpper();
            if (byte.startsWith(QStringLiteral("0X"))) {
                byte = byte.mid(2);
            }
            // 只保留两位有效的十六进制字符
            if (byte.length() > 2) {
                byte = byte.left(2);
            }
            if (byte.length() == 1) {
                byte.prepend(QStringLiteral("0"));
            }
            if (byte.length() == 2 && QRegularExpression(QStringLiteral("^[0-9A-F]{2}$")).match(byte).hasMatch()) {
                row[QStringLiteral("Byte%1").arg(col)] = byte;
                ++col;
            }
        }

        if (col > 0) {
            rows.append(row);
            ++commandCount;
            if (col > maxBytes) {
                maxBytes = col;
            }
        }
    }

    result[QStringLiteral("rows")] = rows;
    result[QStringLiteral("commandCount")] = commandCount;
    result[QStringLiteral("byteCount")] = maxBytes;
    result[QStringLiteral("error")] = QString();

    qDebug() << "TpinvFileHelper::parseCommandContent: 解析完成,"
             << commandCount << "条指令," << maxBytes << "字节/条";

    return result;
}
