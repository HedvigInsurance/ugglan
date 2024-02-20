import DatadogCore
import DatadogCrashReporting
import DatadogInternal
//import DatadogSessionReplay
import DatadogLogs
//import DatadogObjc
import DatadogPrivate
import DatadogRUM
import DatadogTrace
import Foundation
import hCore
import hGraphQL

extension AppDelegate {
    func setupAnalyticsAndTracking() {
        //        Datadog.initialize(
        //            appContext: .init(),
        //            trackingConsent: .granted,
        //            configuration: Datadog.Configuration
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
        //        requestPermissionForTracking()
        let configuration = Datadog.Configuration(
            clientToken: "pub4306832bdc5f2b8b980c492ec2c11ef3",
            env: Environment.current.datadogName,
            site: .eu1,
            service: "ios",
            bundle: .main,
            batchSize: .medium,
            uploadFrequency: .average,
            proxyConfiguration: nil,
            encryption: .none,
            serverDateProvider: .none,
            batchProcessingLevel: .medium,
            backgroundTasksEnabled: true
        )
        Datadog.initialize(
            with: configuration,
            trackingConsent: .granted
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

        RUM.enable(
            with: RUM.Configuration(
                applicationID: "416e8fc0-c96a-4485-8c74-84412960a479",
                uiKitViewsPredicate: DefaultUIKitRUMViewsPredicate(),
                uiKitActionsPredicate: DefaultUIKitRUMActionsPredicate(),
                urlSessionTracking: RUM.Configuration.URLSessionTracking(
                    firstPartyHostsTracing: .trace(
                        hosts: [
                            Environment.current.octopusEndpointURL.host ?? "",
                            Environment.current.claimsApiURL.host ?? "",
                            Environment.current.odysseyApiURL.host ?? "",
                        ],
                        sampleRate: 100
                    )
                )
            )
        )

        Trace.enable(
            with: .init(
                urlSessionTracking: .init(
                    firstPartyHostsTracing: .trace(
                        hosts: [
                            Environment.current.octopusEndpointURL.host ?? "",
                            Environment.current.claimsApiURL.host ?? "",
                            Environment.current.odysseyApiURL.host ?? "",
                        ]
                    )
                )
            )
        )

        CrashReporting.enable()

        //        URLSessionInstrumentation.enable(
        //            with: .init(
        //                delegateClass: SessionDelegate.self
        //            )
        //        )
        //
        if hGraphQL.Environment.current == .staging || hGraphQL.Environment.hasOverridenDefault {
            Datadog.verbosityLevel = .debug
        }
    }
}
