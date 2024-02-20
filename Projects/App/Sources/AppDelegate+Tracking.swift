import DatadogCore
import DatadogCrashReporting
import DatadogInternal
//import DatadogSessionReplay
import DatadogLogs
//import DatadogObjc
import DatadogPrivate
import Foundation
import hCore
import hGraphQL

extension AppDelegate {
    func setupAnalyticsAndTracking() {
        //        Datadog.initialize(
        //            appContext: .init(),
        //            trackingConsent: .granted,
        //            configuration: Datadog.Configuration
        //                .builderUsing(
        //                    rumApplicationID: "416e8fc0-c96a-4485-8c74-84412960a479",
        //                    clientToken: "pub4306832bdc5f2b8b980c492ec2c11ef3",
        //                    environment: Environment.current.datadogName
        //                )
        //                .set(serviceName: "ios")
        //                .set(endpoint: .eu1)
        //                .enableLogging(true)
        //                .enableTracing(true)
        //                .enableCrashReporting(using: DDCrashReportingPlugin())
        //                .enableRUM(true)
        //                .trackUIKitRUMActions(using: RUMUserActionsPredicate())
        //                .trackUIKitRUMViews(using: RUMViewsPredicate())
        //                .trackURLSession(firstPartyHosts: [
        //                    Environment.current.octopusEndpointURL.host ?? "",
        //                    Environment.current.claimsApiURL.host ?? "",
        //                    Environment.current.odysseyApiURL.host ?? "",
        //                ])
        //                .set(uploadFrequency: .frequent)
        //                .build()
        //        )

        let configuration = Datadog.Configuration(
            clientToken: "pub4306832bdc5f2b8b980c492ec2c11ef3",
            env: Environment.current.datadogName,
            site: .eu1,
            service: "iOS",
            bundle: .main,
            batchSize: .medium,
            uploadFrequency: .average,
            //            proxyConfiguration: [
            //                Environment.current.octopusEndpointURL.host ?? "",
            //                Environment.current.claimsApiURL.host ?? "",
            //                Environment.current.odysseyApiURL.host ?? "",
            //            ],
            proxyConfiguration: .none,
            encryption: .none,
            serverDateProvider: .none,
            batchProcessingLevel: .medium,
            backgroundTasksEnabled: true
        )
        Datadog.initialize(
            with: configuration,
            trackingConsent: .granted,
            instanceName: "iOS"
        )

        Logs.enable()

        //        .register(urlSessionHandler: let urlSessionHandler = TracingURLSessionHandler)

        //        Global.rum = RUMMonitor.initialize()
        //        RUMMonitor.shared().ini

        //        Global.sharedTracer = Tracer.initialize(
        //            configuration: .init(
        //                serviceName: "ios",
        //                sendNetworkInfo: true,
        //                bundleWithRUM: true,
        //                globalTags: [:]
        //            )
        //        )

        if hGraphQL.Environment.current == .staging || hGraphQL.Environment.hasOverridenDefault {
            Datadog.verbosityLevel = .debug
        }
    }
}
