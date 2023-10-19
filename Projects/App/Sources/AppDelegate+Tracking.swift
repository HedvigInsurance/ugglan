import Datadog
import DatadogCrashReporting
import hCore
import hGraphQL

extension AppDelegate {
    func setupAnalyticsAndTracking() {
        Datadog.initialize(
            appContext: .init(),
            trackingConsent: .granted,
            configuration: Datadog.Configuration
                .builderUsing(
                    rumApplicationID: "416e8fc0-c96a-4485-8c74-84412960a479",
                    clientToken: "pub4306832bdc5f2b8b980c492ec2c11ef3",
                    environment: Environment.current.datadogName
                )
                .set(serviceName: "ios")
                .set(endpoint: .eu1)
                .enableLogging(true)
                .enableTracing(true)
                .enableCrashReporting(using: DDCrashReportingPlugin())
                .enableRUM(true)
                .trackUIKitRUMActions(using: RUMUserActionsPredicate())
                .trackUIKitRUMViews(using: RUMViewsPredicate())
                .trackURLSession(firstPartyHosts: [
                    Environment.production.giraffeEndpointURL.host ?? "",
                    Environment.staging.giraffeEndpointURL.host ?? "",
                    Environment.production.octopusEndpointURL.host ?? "",
                    Environment.staging.octopusEndpointURL.host ?? "",
                ])
                .set(uploadFrequency: .frequent)
                .build()
        )

        Global.rum = RUMMonitor.initialize()
        Global.sharedTracer = Tracer.initialize(
            configuration: .init(
                serviceName: "ios",
                sendNetworkInfo: true,
                bundleWithRUM: true,
                globalTags: [:]
            )
        )

        if hGraphQL.Environment.current == .staging || hGraphQL.Environment.hasOverridenDefault {
            Datadog.verbosityLevel = .debug
        }

        setupHAnalytics()
    }
}
