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
    /// 初始化：读取下位机当前模式/阀门/板卡状态，同步到 K3data
    Q_INVOKABLE void InitFromPlc();
    Q_INVOKABLE void Flag_Auto_Hand();
    Q_INVOKABLE void Flag_Model_Downhole();
    Q_INVOKABLE void Flag_Model_Ground();
    Q_INVOKABLE void Flag_Model_Mainsecond();
    Q_INVOKABLE void Flag_Model_Profession();
    Q_INVOKABLE void Flag_Stop();
    Q_INVOKABLE void Flag_Board();
    Q_INVOKABLE void Flag_Valve_A();
    Q_INVOKABLE void Flag_Valve_B();
    Q_INVOKABLE void Flag_Valve_C();
    /// 阀门开度调节: 1=快减(-1%), 2=快加(+1%), 3=慢减(-0.1%), 4=慢加(+0.1%)
    Q_INVOKABLE void ValveA_Adjust(int flag);
    Q_INVOKABLE void ValveB_Adjust(int flag);
    Q_INVOKABLE void ValveC_Adjust(int flag);
    Q_INVOKABLE bool checkProfessionPassword(const QString &password);
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
    // 接收阀门状态 (DB444 byte 4: 1 byte)
    void processValveStatus(const QVector<quint8> &rawBytes);
    // 接收回压过高保护 (DB333: 1 byte)
    void processBackpressureStatus(const QVector<quint8> &rawBytes);
    // 接收自动/手动模式 (DB333 byte 1)
    void processModeAutoHand(const QVector<quint8> &rawBytes);
    // 接收模式标志 (DB333 byte 2): 主备阀/井底/井口
    void processModeFlags(const QVector<quint8> &rawBytes);
    // 接收全局/局部追压标志 (DB333 byte 4)
    void processGlobalLocalFlags(const QVector<quint8> &rawBytes);

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

    // DB444 byte 4 — 阀门状态 (WPF Read_Valve_Open)
    static constexpr int kValve_DbNumber  = 444;
    static constexpr int kValve_StartAddr = 4;
    static constexpr int kValve_Count     = 1;

    // DB333 — 回压过高保护 (WPF Read_PLC_Data §回压过高保护)
    static constexpr int kBackpressure_DbNumber  = 333;
    static constexpr int kBackpressure_StartAddr = 3;
    static constexpr int kBackpressure_Count     = 1;

    // DB333 byte 1 — 自动/手动模式 (WPF load_Click init)
    static constexpr int kModeAutoHand_DbNumber  = 333;
    static constexpr int kModeAutoHand_StartAddr = 1;
    static constexpr int kModeAutoHand_Count     = 1;

    // DB333 byte 2 — 模式标志: bit2=主备阀, bit3=井底, bit4=井口 (WPF load_Click init)
    static constexpr int kModeFlags_DbNumber  = 333;
    static constexpr int kModeFlags_StartAddr = 2;
    static constexpr int kModeFlags_Count     = 1;

    // DB333 byte 4 — 全局/局部追压标志: bit1=C, bit2=A, bit3=B (WPF load_Click init + 全局追压)
    static constexpr int kGlobalLocal_DbNumber  = 333;
    static constexpr int kGlobalLocal_StartAddr = 4;
    static constexpr int kGlobalLocal_Count     = 1;

};

#endif // K3DATAPROCESS_H
