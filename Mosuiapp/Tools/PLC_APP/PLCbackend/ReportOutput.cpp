#include "ReportOutput.h"
#include "K3data.h"

#include <QCoreApplication>
#include <QDateTime>
#include <QDesktopServices>
#include <QDir>
#include <QUrl>
#include <QDebug>
#include <QQmlEngine>

// ═══════════════════════════════════════════════
//  ReportWorker — 在子线程中运行
// ═══════════════════════════════════════════════

ReportWorker::ReportWorker(QObject *parent)
    : QObject(parent)
{
    m_timer = new QTimer(this);
    m_timer->setInterval(kIntervalMs);
    connect(m_timer, &QTimer::timeout, this, &ReportWorker::writeDataRow);
}

ReportWorker::~ReportWorker()
{
    stopRecording();
}

void ReportWorker::startRecording(const QString &dirPath)
{
    if (m_recording) return;

    m_dirPath = dirPath;
    QDir().mkpath(m_dirPath);
    m_rowNum = 2;
    m_recording = true;

    createNewFile();
    writeHeader();
    m_timer->start();
    emit recordingStarted();
}

void ReportWorker::stopRecording()
{
    if (!m_recording) return;

    m_timer->stop();
    if (m_file.isOpen()) {
        m_stream.flush();
        m_file.close();
    }
    m_recording = false;
    emit recordingStopped();
}

void ReportWorker::createNewFile()
{
    if (m_file.isOpen()) {
        m_stream.flush();
        m_file.close();
    }

    QString fileName = QString("PLC数据_%1_%2.csv")
        .arg(QDateTime::currentDateTime().toString("yyMMddHHmmss"))
        .arg(m_fileIndex++);
    QString filePath = m_dirPath + "/" + fileName;

    m_file.setFileName(filePath);
    if (m_file.open(QIODevice::WriteOnly | QIODevice::Text)) {
        m_stream.setDevice(&m_file);
    }
}

void ReportWorker::writeHeader()
{
    if (!m_file.isOpen()) return;
    // 与 WPF 一致的 18 列表头
    m_stream << "时间,"
             << "WHP目标值(MPa),"
             << "环空摩阻(MPa),"
             << "入口流量(L/s),"
             << "出口流量(L/s),"
             << "立管压力(MPa),"
             << "井口压力(备用)(MPa),"
             << "主通道压力(MPa),"
             << "辅助通道压力(MPa),"
             << "节流后压力(MPa),"
             << "泵冲1(MPa),"
             << "泵冲2(MPa),"
             << "泵冲3(MPa),"
             << "钻头深度(m),"
             << "井深(m),"
             << "出口密度(g/cm³),"
             << "液压站压力(MPa),"
             << "液压温度(°C)\n";
    m_stream.flush();
}

void ReportWorker::writeDataRow()
{
    if (!m_recording || !m_file.isOpen()) return;

    // 从 K3data 读取当前数据
    auto lookup = [](const QString &key, const QString &fallback = "0") -> QString {
        // K3data 是单例，但跨线程访问可能不安全。
        // 这里用值拷贝的方式：通过 signal/slot 机制在主线程取值会更安全，
        // 但为简单起见，直接读取（K3data 的属性是主线程安全的）
        QVariantList all = K3data::instance()->property("k3data_all").toList();
        for (const QVariant &g : all) {
            QVariantMap group = g.toMap();
            QVariantList metrics = group["metrics"].toList();
            for (const QVariant &m : metrics) {
                QVariantMap item = m.toMap();
                if (item["key"].toString() == key) {
                    QVariant val = item["value"];
                    if (val.isValid() && !val.isNull())
                        return val.toString();
                    return fallback;
                }
            }
        }
        return fallback;
    };

    // 18 列数据（与 WPF 一致）
    m_stream << QDateTime::currentDateTime().toString("HH:mm:ss") << ","
             << "0,"                          // WHP目标值 (SetPoint from UI)
             << lookup("Friction", "0") << "," // 环空摩阻
             << lookup("InletFlow", "0") << ","  // 入口流量
             << lookup("OutletFlow", "0") << "," // 出口流量
             << lookup("StandpipePressure", "0") << "," // 立管压力
             << lookup("WellheadPressure", "0") << ","  // 井口压力
             << lookup("MainChannelPressure", "0") << "," // 主通道压力
             << lookup("AuxiliaryChannelPressure", "0") << "," // 辅助通道压力
             << lookup("ThrottledPressure", "0") << "," // 节流后压力
             << lookup("PumpStroke1", "0") << "," // 泵冲1
             << lookup("PumpStroke2", "0") << "," // 泵冲2
             << lookup("PumpStroke3", "0") << "," // 泵冲3
             << lookup("BitDepth", "0") << ","    // 钻头深度
             << lookup("WellDepth", "0") << ","   // 井深
             << lookup("OutletDensity", "0") << "," // 出口密度
             << lookup("pres_yeyazhan", "0") << "," // 液压站压力
             << lookup("temp_yeyazhan", "0") << "\n"; // 液压温度

    m_stream.flush();
    m_rowNum++;

    emit rowWritten(m_rowNum - 2); // 已写入数据行数

    // 每小时新建文件
    if (m_rowNum > kMaxRows) {
        m_rowNum = 2;
        createNewFile();
        writeHeader();
    }
}

// ═══════════════════════════════════════════════
//  ReportOutput — 主线程单例
// ═══════════════════════════════════════════════

ReportOutput::ReportOutput(QObject *parent)
    : QObject(parent)
{
    m_worker = new ReportWorker;
    m_worker->moveToThread(&m_workerThread);

    connect(&m_workerThread, &QThread::finished, m_worker, &QObject::deleteLater);
    connect(this, &ReportOutput::requestStart, m_worker, &ReportWorker::startRecording);
    connect(this, &ReportOutput::requestStop, m_worker, &ReportWorker::stopRecording);
    connect(m_worker, &ReportWorker::recordingStarted, this, [this]() {
        m_recording = true;
        emit recordingChanged();
    });
    connect(m_worker, &ReportWorker::recordingStopped, this, [this]() {
        m_recording = false;
        emit recordingChanged();
    });
    connect(m_worker, &ReportWorker::rowWritten, this, [this](int rows) {
        m_totalRows = rows;
        emit totalRowsChanged();
    });

    m_workerThread.start();
    ensureDefaultDir();
}

ReportOutput::~ReportOutput()
{
    stopRecording();
    m_workerThread.quit();
    m_workerThread.wait(3000);
}

ReportOutput *ReportOutput::instance()
{
    static ReportOutput ins;
    return &ins;
}

ReportOutput *ReportOutput::create(QQmlEngine *, QJSEngine *)
{
    auto *rpt = instance();
    QQmlEngine::setObjectOwnership(rpt, QQmlEngine::CppOwnership);
    return rpt;
}

bool ReportOutput::isRecording() const { return m_recording; }
QString ReportOutput::outputDir() const { return m_outputDir; }
int ReportOutput::totalRows() const { return m_totalRows; }

void ReportOutput::setOutputDir(const QString &dir)
{
    if (m_outputDir != dir) {
        m_outputDir = dir;
        emit outputDirChanged();
    }
}

void ReportOutput::ensureDefaultDir()
{
    if (m_outputDir.isEmpty()) {
        QString appDir = QCoreApplication::applicationDirPath();
        // 与 WPF 一致：在 EXE 同级创建 "EXCEL数据" 目录
        m_outputDir = appDir + "/EXCEL数据";
        emit outputDirChanged();
    }
}

void ReportOutput::startRecording()
{
    ensureDefaultDir();
    emit requestStart(m_outputDir);
}

void ReportOutput::stopRecording()
{
    emit requestStop();
}

void ReportOutput::openOutputFolder()
{
    ensureDefaultDir();
    QDir().mkpath(m_outputDir);
    QDesktopServices::openUrl(QUrl::fromLocalFile(m_outputDir));
}
