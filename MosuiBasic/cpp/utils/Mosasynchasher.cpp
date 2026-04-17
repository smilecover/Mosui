/*
 * HuskarUI
 *
 * Copyright (C) mengps (MenPenS) (MIT License)
 * https://github.com/mengps/HuskarUI
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy of
 * this software and associated documentation files (the "Software"), to deal in
 * the Software without restriction, including without limitation the rights to
 * use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of
 * the Software, and to permit persons to whom the Software is furnished to do so,
 * subject to the following conditions:
 * - The above copyright notice and this permission notice shall be included in
 *   all copies or substantial portions of the Software.
 * - The Software is provided "as is", without warranty of any kind, express or
 *   implied, including but not limited to the warranties of merchantability,
 *   fitness for a particular purpose and noninfringement. In no event shall the
 *   authors or copyright holders be liable for any claim, damages or other
 *   liability, whether in an action of contract, tort or otherwise, arising from,
 *   out of or in connection with the Software or the use or other dealings in the
 *   Software.
 */

#include "Mosasynchasher.h"

#include <QtCore/QBuffer>
#include <QtCore/QDebug>
#include <QtCore/QFile>
#include <QtCore/QLoggingCategory>
#include <QtCore/QRunnable>
#include <QtCore/QThreadPool>
#include <QtNetwork/QNetworkAccessManager>
#include <QtNetwork/QNetworkReply>
#include <QtQml/QQmlEngine>

class AsyncRunnable : public QObject, public QRunnable
{
    Q_OBJECT

public:
    AsyncRunnable(QIODevice *device, QCryptographicHash::Algorithm algorithm)
        : QObject{nullptr}, m_device(device), m_algorithm(algorithm)
    {
        setAutoDelete(false);
    }

    void cancel() {
        m_stop = true;
    }

signals:
    void progress(qint64 processed, qint64 total);
    void finished(const QString &result);

protected:
    virtual void run() {
        if (m_device) {
            static constexpr qint64 chunkSize = 4 * 1024 * 1024;
            QCryptographicHash hash(m_algorithm);
            qint64 processed = 0;
            qint64 total = m_device->size();
            while (!m_device->atEnd()) {
                if (m_stop) {
                    m_device->deleteLater();
                    return;
                }
                auto readData = m_device->read(std::min(chunkSize, total));
                hash.addData(readData);
                processed += readData.size();
                emit progress(processed, total);
            }
            emit finished(hash.result().toHex().toUpper());
            m_device->deleteLater();
        }
    }

    std::atomic_bool m_stop = { false };
    QIODevice *m_device = nullptr;
    QCryptographicHash::Algorithm m_algorithm;
};

class MosAsyncHasherPrivate
{
public:
    void cleanupRunnable()
    {
        if (m_runnable) {
            m_runnable->cancel();
            m_runnable->disconnect();
            m_runnable->deleteLater();
            m_runnable = nullptr;
        }
    }

    QCryptographicHash::Algorithm m_algorithm = QCryptographicHash::Md5;
    bool m_asynchronous = true;
    QString m_hashValue;
    QUrl m_source;
    QString m_sourceText;
    QByteArray m_sourceData;
    QObject *m_sourceObject = nullptr;
    QNetworkReply *m_reply = nullptr;
    QNetworkAccessManager *m_manager = nullptr;
    AsyncRunnable *m_runnable = nullptr;
};

MosAsyncHasher::MosAsyncHasher(QObject *parent)
    : QObject{parent}
    , d_ptr(new MosAsyncHasherPrivate)
{

}

MosAsyncHasher::~MosAsyncHasher()
{
    Q_D(MosAsyncHasher);

    d->cleanupRunnable();
}

QCryptographicHash::Algorithm MosAsyncHasher::algorithm()
{
    Q_D(MosAsyncHasher);

    return d->m_algorithm;
}

void MosAsyncHasher::setAlgorithm(QCryptographicHash::Algorithm algorithm)
{
    Q_D(MosAsyncHasher);

    if (d->m_algorithm != algorithm) {
        d->m_algorithm = algorithm;
        emit algorithmChanged();
        emit hashLengthChanged();
    }
}

bool MosAsyncHasher::asynchronous() const
{
    Q_D(const MosAsyncHasher);

    return d->m_asynchronous;
}

void MosAsyncHasher::setAsynchronous(bool async)
{
    Q_D(MosAsyncHasher);

    if (d->m_asynchronous != async) {
        d->m_asynchronous = async;
        emit asynchronousChanged();
    }
}

QString MosAsyncHasher::hashValue() const
{
    Q_D(const MosAsyncHasher);

    return d->m_hashValue;
}

int MosAsyncHasher::hashLength() const
{
    Q_D(const MosAsyncHasher);

    return QCryptographicHash::hashLength(d->m_algorithm);
}

QUrl MosAsyncHasher::source() const
{
    Q_D(const MosAsyncHasher);

    return d->m_source;
}

void MosAsyncHasher::setSource(const QUrl &source)
{
    Q_D(MosAsyncHasher);

    if (d->m_source != source) {
        d->m_source = source;
        emit sourceChanged();

        d->cleanupRunnable();

        if (source.isLocalFile()) {
            QFile *file = new QFile(source.toLocalFile());
            if (file->open(QIODevice::ReadOnly)) {
                emit started();
                if (d->m_asynchronous) {
                    d->m_runnable = new AsyncRunnable(file, d->m_algorithm);
                    connect(d->m_runnable, &AsyncRunnable::finished, this, &MosAsyncHasher::setHashValue, Qt::QueuedConnection);
                    connect(d->m_runnable, &AsyncRunnable::progress, this, &MosAsyncHasher::hashProgress, Qt::QueuedConnection);
                    QThreadPool::globalInstance()->start(d->m_runnable);
                } else {
                    QCryptographicHash hash(d->m_algorithm);
                    hash.addData(file);
                    setHashValue(hash.result().toHex().toUpper());
                    file->deleteLater();
                }
            } else {
                qDebug() << "File Error:" << file->errorString();
                file->deleteLater();
            }
        } else {
            if (d->m_reply)
                d->m_reply->abort();
            emit started();
            if (!d->m_manager) {
                if (qmlEngine(this)) {
                    d->m_manager = qmlEngine(this)->networkAccessManager();
                } else {
                    qDebug() << "MosAsyncHasher without QmlEngine, we cannot get QNetworkAccessManager!";
                }
            }
            if (d->m_manager) {
                d->m_reply = d->m_manager->get(QNetworkRequest(source));
                connect(d->m_reply, &QNetworkReply::finished, this, [d, this]{
                    if (d->m_reply->error() == QNetworkReply::NoError) {
                        if (d->m_asynchronous) {
                            d->m_runnable = new AsyncRunnable(d->m_reply, d->m_algorithm);
                            connect(d->m_runnable, &AsyncRunnable::finished, this, &MosAsyncHasher::setHashValue, Qt::QueuedConnection);
                            connect(d->m_runnable, &AsyncRunnable::progress, this, &MosAsyncHasher::hashProgress, Qt::QueuedConnection);
                            QThreadPool::globalInstance()->start(d->m_runnable);
                        } else {
                            QCryptographicHash hash(d->m_algorithm);
                            hash.addData(d->m_reply);
                            setHashValue(hash.result().toHex().toUpper());
                            d->m_reply->deleteLater();
                        }
                    } else {
                        qDebug() << "HTTP Request Error:" << d->m_reply->errorString();
                        d->m_reply->deleteLater();
                    }
                    d->m_reply = nullptr;
                });
            }
        }
    }
}

QString MosAsyncHasher::sourceText() const
{
    Q_D(const MosAsyncHasher);

    return d->m_sourceText;
}

void MosAsyncHasher::setSourceText(const QString &sourceText)
{
    Q_D(MosAsyncHasher);

    if (d->m_sourceText != sourceText) {
        d->m_sourceText = sourceText;
        emit sourceTextChanged();

        d->cleanupRunnable();

        emit started();
        if (d->m_asynchronous) {
            QBuffer *buffer = new QBuffer;
            buffer->setData(sourceText.toUtf8());
            buffer->open(QIODevice::ReadOnly);
            d->m_runnable = new AsyncRunnable(buffer, d->m_algorithm);
            connect(d->m_runnable, &AsyncRunnable::finished, this, &MosAsyncHasher::setHashValue, Qt::QueuedConnection);
            connect(d->m_runnable, &AsyncRunnable::progress, this, &MosAsyncHasher::hashProgress, Qt::QueuedConnection);
            QThreadPool::globalInstance()->start(d->m_runnable);
        } else {
            QCryptographicHash hash(d->m_algorithm);
            hash.addData(sourceText.toUtf8());
            setHashValue(hash.result().toHex().toUpper());
        }
    }
}

QByteArray MosAsyncHasher::sourceData() const
{
    Q_D(const MosAsyncHasher);

    return d->m_sourceData;
}

void MosAsyncHasher::setSourceData(const QByteArray &sourceData)
{
    Q_D(MosAsyncHasher);

    if (d->m_sourceData != sourceData) {
        d->m_sourceData = sourceData;
        emit sourceDataChanged();

        d->cleanupRunnable();

        emit started();
        if (d->m_asynchronous) {
            QBuffer *buffer = new QBuffer;
            buffer->setData(sourceData);
            buffer->open(QIODevice::ReadOnly);
            d->m_runnable = new AsyncRunnable(buffer, d->m_algorithm);
            connect(d->m_runnable, &AsyncRunnable::finished, this, &MosAsyncHasher::setHashValue, Qt::QueuedConnection);
            connect(d->m_runnable, &AsyncRunnable::progress, this, &MosAsyncHasher::hashProgress, Qt::QueuedConnection);
            QThreadPool::globalInstance()->start(d->m_runnable);
        } else {
            QCryptographicHash hash(d->m_algorithm);
            hash.addData(sourceData);
            setHashValue(hash.result().toHex().toUpper());
        }
    }
}

QObject *MosAsyncHasher::sourceObject() const
{
    Q_D(const MosAsyncHasher);

    return d->m_sourceObject;
}

void MosAsyncHasher::setSourceObject(QObject *sourceObject)
{
    Q_D(MosAsyncHasher);

    if (d->m_sourceObject != sourceObject) {
        d->m_sourceObject = sourceObject;
        emit sourceObjectChanged();
        emit started();
        setHashValue(QCryptographicHash::hash(QByteArray::number(qHash(sourceObject)), d->m_algorithm).toHex().toUpper());
    }
}

void MosAsyncHasher::setHashValue(const QString &value)
{
    Q_D(MosAsyncHasher);

    d->m_hashValue = value;
    emit hashValueChanged();
    emit finished();
}

bool MosAsyncHasher::operator==(const MosAsyncHasher &hasher)
{
    Q_D(const MosAsyncHasher);

    return hasher.d_func()->m_hashValue == d->m_hashValue;
}

bool MosAsyncHasher::operator!=(const MosAsyncHasher &hasher)
{
    return !(*this == hasher);
}

#include "Mosasynchasher.moc"
