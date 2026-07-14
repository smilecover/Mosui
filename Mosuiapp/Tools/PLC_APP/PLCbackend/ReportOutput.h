#ifndef REPORTOUTPUT_H
#define REPORTOUTPUT_H

#include <QObject>
#include <QString>
#include <QThread>
#include <QTimer>
#include <QFile>
#include <QTextStream>
#include <QMutex>
#include <QtQml/qqml.h>

class ReportWorker : public QObject
{
    Q_OBJECT

public:
    explicit ReportWorker(QObject *parent = nullptr);
    ~ReportWorker() override;

public slots:
    void startRecording(const QString &dirPath);
    void stopRecording();
    void writeDataRow();

signals:
    void recordingStarted();
    void recordingStopped();
    void rowWritten(int totalRows);

private:
    void createNewFile();
    void writeHeader();

    QTimer   *m_timer = nullptr;
    QFile     m_file;
    QTextStream m_stream;
    QString   m_dirPath;
    int       m_rowNum = 2;       // current row (row 1 = header)
    int       m_fileIndex = 0;
    bool      m_recording = false;

    static constexpr int kMaxRows = 3600;   // 1 hour = 3600 rows
    static constexpr int kIntervalMs = 1000;
};

class ReportOutput : public QObject
{
    Q_OBJECT
    QML_SINGLETON
    QML_NAMED_ELEMENT(ReportOutput)

    Q_PROPERTY(bool recording READ isRecording NOTIFY recordingChanged)
    Q_PROPERTY(QString outputDir READ outputDir WRITE setOutputDir NOTIFY outputDirChanged)
    Q_PROPERTY(int totalRows READ totalRows NOTIFY totalRowsChanged)

public:
    ~ReportOutput() override;

    static ReportOutput *instance();
    static ReportOutput *create(QQmlEngine *, QJSEngine *);

    bool isRecording() const;
    QString outputDir() const;
    int totalRows() const;
    void setOutputDir(const QString &dir);

    Q_INVOKABLE void startRecording();
    Q_INVOKABLE void stopRecording();
    Q_INVOKABLE void openOutputFolder();

signals:
    void recordingChanged();
    void outputDirChanged();
    void totalRowsChanged();
    void requestStart(const QString &dir);
    void requestStop();

private:
    explicit ReportOutput(QObject *parent = nullptr);

    void ensureDefaultDir();

    QThread       m_workerThread;
    ReportWorker *m_worker = nullptr;
    QString       m_outputDir;
    int           m_totalRows = 0;
    bool          m_recording = false;
};

#endif // REPORTOUTPUT_H
