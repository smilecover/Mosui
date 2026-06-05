#ifndef TPINVFILEHELPER_H
#define TPINVFILEHELPER_H

#include <QObject>
#include <QString>
#include <QVariantList>
#include <QtQml/qqml.h>

class TpinvFileHelper : public QObject
{
    Q_OBJECT
    QML_SINGLETON
    QML_NAMED_ELEMENT(TpinvFileHelper)

public:
    ~TpinvFileHelper() override;

    static TpinvFileHelper *instance();
    static TpinvFileHelper *create(QQmlEngine *, QJSEngine *);

    /// 打开指令文件，返回文件内容字符串（每行一条指令，字节用空格分隔）
    Q_INVOKABLE QString openCommandFile(const QString &filePath);

    /// 保存指令数据到文件（纯文本，一行一条指令）
    Q_INVOKABLE bool saveCommandData(const QString &filePath, const QString &data);

    /// 将表格中的指令数据保存到文件
    /// @param filePath 目标文件路径
    /// @param rows 表格行数据，每行是 QVariantMap，键为 "Byte0", "Byte1" ...
    /// @param byteCount 每行的字节列数
    Q_INVOKABLE bool saveCommandTableData(const QString &filePath,
                                          const QVariantList &rows,
                                          int byteCount);

    /// 解析指令文件内容为表格行数据
    /// @return QVariantMap { rows: QVariantList, commandCount: int, byteCount: int, error: string }
    Q_INVOKABLE QVariantMap parseCommandContent(const QString &content);

    /// 获取上次操作的错误信息
    Q_INVOKABLE QString lastError() const;

private:
    explicit TpinvFileHelper(QObject *parent = nullptr);
    QString lastError_;
};

#endif // TPINVFILEHELPER_H
