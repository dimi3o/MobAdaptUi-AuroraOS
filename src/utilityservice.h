#ifndef UTILITYSERVICE_H
#define UTILITYSERVICE_H

#include <QObject>
#include <QVector>
#include <QVariant>


class UtilityService : public QObject
{
    Q_OBJECT
public:
    explicit UtilityService(QObject *parent = nullptr);
    Q_INVOKABLE void setErrors(const std::vector<double>& err);
    Q_INVOKABLE QVariantList getErrors();

private:
    QVector<double> errors;
};

#endif // UTILITYSERVICE_H
