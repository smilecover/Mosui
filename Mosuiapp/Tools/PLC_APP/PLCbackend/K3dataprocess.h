#ifndef K3DATAPROCESS_H
#define K3DATAPROCESS_H

#include <QHash>
#include <QObject>
#include <QString>
#include <QThread>
#include <QVector>
#include <QtQml/qqml.h>

class K3Client;
class K3data;
class QTimer;

class K3dataprocess : public QObject
{
    Q_OBJECT
    QML_SINGLETON
    QML_NAMED_ELEMENT(K3dataprocess)

public:
    ~K3dataprocess() override;

    static K3dataprocess *instance();
    static K3dataprocess *create(QQmlEngine *, QJSEngine *);

    Q_INVOKABLE void InitK3dataprocess();

signals:

private Q_SLOTS:
    void startPolling();
    void stopPolling();
    void onPollTimeout();
    void onRealDataReceived(int dbNumber, int start, QVector<float> values);
    void onBitDataReceived(int dbNumber, int start, QVector<quint8> rawBytes);

private:
    explicit K3dataprocess(QObject *parent = nullptr);

    // 接收 AI 模拟量 (DB444: 19 floats)
    void processAIData(int dbNumber, int start, const QVector<float> &values);
    // 接收 DI 数字量 (DB555: 14 bytes)
    void processDIData(int dbNumber, int start, const QVector<quint8> &rawBytes);
    // 接收流程数据 (DB222: 14 floats)
    void processFlowData(int dbNumber, int start, const QVector<float> &values);

    QTimer   *m_pollTimer = nullptr;
    QThread   m_workerThread;
    QObject  *m_worker = nullptr;

    // ── 轮询参数（与原始 WPF 代码一致） ──
    static constexpr int kPollIntervalMs = 1000;   // 1秒一次 (对应 Task.Delay(1000))

    // DB444 — AI 模拟量 (WPF Read_PLC_Data §AI)
    static constexpr int kAI_DbNumber  = 444;
    static constexpr int kAI_StartAddr = 1;
    static constexpr int kAI_Count     = 19;

    // DB555 — DI 数字量 (WPF Read_PLC_Data §DI)
    static constexpr int kDI_DbNumber  = 555;
    static constexpr int kDI_StartAddr = 1;
    static constexpr int kDI_Count     = 14;   // 字节数

    // DB222 — 流程数据 (WPF PLCtoText)
    static constexpr int kFlow_DbNumber  = 222;
    static constexpr int kFlow_StartAddr = 1;
    static constexpr int kFlow_Count     = 14;
};

#endif // K3DATAPROCESS_H
