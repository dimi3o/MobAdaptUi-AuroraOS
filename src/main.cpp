#include <auroraapp.h>
#include <QtQuick>
#include <QtQml>
#include "stringobject.h"
#include "neural-net.h"
#include "utilityservice.h"

using namespace std;

int main(int argc, char *argv[])
{
    TrainingData trainData("/usr/share/ru.bmstu.MobAdaptUi/lib/trainingData.txt");
    //e.g., {3, 2, 1 }
    vector<unsigned> topology;
    //topology.push_back(3);
    //topology.push_back(2);
    //topology.push_back(1);

    trainData.getTopology(topology);
    Net myNet(topology);

    vector<double> inputVals, targetVals, resultVals;
    int trainingPass = 0;

    std::vector<double> errors;
    while(!trainData.isEof())
    {
        ++trainingPass;
        cout << endl << "Pass" << trainingPass;

        // Get new input data and feed it forward:
        if(trainData.getNextInputs(inputVals) != topology[0])
            break;
        showVectorVals(": Inputs :", inputVals);
        myNet.feedForward(inputVals);

        // Collect the net's actual results:
        myNet.getResults(resultVals);
        showVectorVals("Outputs:", resultVals);

        // Train the net what the outputs should have been:
        trainData.getTargetOutputs(targetVals);
        showVectorVals("Targets:", targetVals);
        assert(targetVals.size() == topology.back());

        myNet.backProp(targetVals);

        // Report how well the training is working, average over recnet
        double error = myNet.getRecentAverageError();
        cout << "Net recent average error: "
             << error << endl;
        errors.push_back(error);
    }

    cout << endl << "Done" << endl;

    QScopedPointer<QGuiApplication> application(Aurora::Application::application(argc, argv));
    application->setOrganizationName(QStringLiteral("ru.bmstu"));
    application->setApplicationName(QStringLiteral("MobAdaptUi"));

    //----second way CPPtoQML
    qmlRegisterType<StringObject>("StringObject", 1, 0, "StringObject");
    auto utilityService = new UtilityService(application.data());
    utilityService->setErrors(errors);


    QScopedPointer<QQuickView> view(Aurora::Application::createView());
    view->setSource(Aurora::Application::pathTo(QStringLiteral("qml/MobAdaptUi.qml")));

    view->rootContext()->setContextProperty("utilityServ", utilityService);
    //----first way CPPtoQML
//    auto stringObject = new StringObject(application.data());
//    view->rootContext()->setContextProperty("stringObject", stringObject);


    view->show();

    return application->exec();
}
