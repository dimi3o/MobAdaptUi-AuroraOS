#include "stringobject.h"

StringObject::StringObject(QObject *parent) : QObject(parent)
{

}

QString StringObject::value() const
{
    return m_value;
}

void StringObject::setValue(const QString &value)
{
    if (m_value == value)
        return;
    m_value = value;
    emit valueChanged();
}

void StringObject::updateValue(const QString &value)
{
    setValue(value);
}
