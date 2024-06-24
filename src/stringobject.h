#ifndef STRINGOBJECT_H
#define STRINGOBJECT_H

#include <QObject>
#include <QString>

class StringObject : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QString value READ value WRITE setValue NOTIFY valueChanged)
public:
    explicit StringObject(QObject *parent = nullptr);

    QString value() const;
    void setValue(const QString &value);

public slots:
    void updateValue(const QString &value);

signals:
    void valueChanged();

private:
    QString m_value = "HELLO";
};

#endif // STRINGOBJECT_H
