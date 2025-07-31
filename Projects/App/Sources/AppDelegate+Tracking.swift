import Apollo
import Authentication
import DatadogCore
import DatadogCrashReporting
import DatadogLogs
import DatadogRUM
import DatadogTrace
import Environment
import PresentableStore
import Profile
import SwiftUI
import hCore
import hCoreUI

extension AppDelegate {
    func setupAnalyticsAndTracking() {
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
        let store: ProfileStore = globalPresentableStoreContainer.get()
        if let userId = store.state.memberDetails?.id {
            let analyticsService: AnalyticsClient = Dependencies.shared.resolve()
            analyticsService.setWith(userId: userId)
        }

        Logs.enable()
        RUM.enable(
            with: RUM.Configuration(
                applicationID: "416e8fc0-c96a-4485-8c74-84412960a479",
                uiKitViewsPredicate: HedvigUIKitRUMViewsPredicate(),
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

        URLSessionInstrumentation.enable(
            with: .init(
                delegateClass: URLSessionClient.self
            )
        )

        Trace.enable(
            with: .init(
                service: "ios",
                urlSessionTracking: .init(
                    firstPartyHostsTracing: .trace(
                        hosts: [
                            Environment.current.octopusEndpointURL.host ?? "",
                            Environment.current.claimsApiURL.host ?? "",
                            Environment.current.odysseyApiURL.host ?? "",
                        ]
                    )
                ),
                networkInfoEnabled: true
            )
        )
        CrashReporting.enable()
        if Environment.current == .staging || Environment.hasOverridenDefault {
            Datadog.verbosityLevel = .debug
        }
        logStartView = { key, name in
            print("VIEW NAME \(name)")
            RUMMonitor.shared().startView(key: key, name: name, attributes: [:])
        }
        logStopView = { key in
            RUMMonitor.shared().stopView(key: key, attributes: [:])
        }

        AuthenticationService.logAuthResourceStart = { key, url in
            RUMMonitor.shared().startResource(resourceKey: key, url: url, attributes: [:])
        }

        AuthenticationService.logAuthResourceStop = { key, url in
            RUMMonitor.shared().stopResource(resourceKey: key, response: url, size: 0, attributes: [:])
        }
    }
}

struct HedvigUIKitRUMViewsPredicate: UIKitRUMViewsPredicate {
    public func rumView(for viewController: UIViewController) -> RUMView? {
        return nil
    }
}

extension View {
    func trackViewName(name: String? = nil) -> some View {
        self.onAppear {
            RUMMonitor.shared()
                .startView(key: .init(describing: self), name: name ?? .init(describing: self), attributes: [:])
        }
        .onDisappear {
            RUMMonitor.shared().stopView(key: .init(describing: self), attributes: [:])
        }
    }
}
