#include "utilityservice.h"

UtilityService::UtilityService(QObject *parent) : QObject(parent)
{

}

void UtilityService::setErrors(const std::vector<double>& err) {
    errors.clear();
    for (const auto& elem : err) {
        errors.push_back(elem);
    }
}

QVariantList UtilityService::getErrors() {
    QVariantList list;
        for (double value : errors) {
            list.append(value);
        }
        return list;
}
