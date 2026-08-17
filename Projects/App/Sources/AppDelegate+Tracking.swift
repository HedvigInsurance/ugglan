import Apollo
import AppStateContainer
import AuthenticationCore
import DatadogCore
import DatadogCrashReporting
import DatadogLogs
import DatadogRUM
import DatadogTrace
import Environment
import FirebaseCore
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
        let store: ProfileStore = globalAppStateContainer.get()
        if let userId = store.memberDetails?.id {
            let analyticsService: AnalyticsClient = Dependencies.shared.resolve()
            analyticsService.setWith(userId: userId)
            let eventTrackingClient: EventTrackingClient = Dependencies.shared.resolve()
            eventTrackingClient.setUserId(userId)
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
                ),
                trackBackgroundEvents: true,
                trackMemoryWarnings: false
            )
        )

        URLSessionInstrumentation.enableDurationBreakdown(
            with: .init(
                delegateClass: InterceptingURLSessionClient.self
            )
        )

        Trace.enable(
            with: .init(
                service: "ios",
                urlSessionTracking: .init(
                    firstPartyHostsTracing: .traceWithHeaders(
                        hostsWithHeaders: [
                            Environment.current.octopusEndpointURL.host ?? "": [TracingHeaderType.datadog],
                            Environment.current.claimsApiURL.host ?? "": [TracingHeaderType.datadog],
                            Environment.current.odysseyApiURL.host ?? "": [TracingHeaderType.datadog],
                        ],
                        traceControlInjection: .all
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
            RUMViewTracker.shared.startView(key: key, name: name)
        }
        logStopView = { key in
            RUMViewTracker.shared.stopView(key: key)
        }

        AuthenticationService.logAuthResourceStart = { key, url in
            RUMMonitor.shared().startResource(resourceKey: key, url: url, attributes: [:])
        }

        AuthenticationService.logAuthResourceStop = { key, url in
            RUMMonitor.shared().stopResource(resourceKey: key, response: url, size: 0, attributes: [:])
        }

        FirebaseApp.configure()
        let eventTrackingClient: EventTrackingClient = Dependencies.shared.resolve()
        eventTrackingClient.setCollectionEnabled(AnalyticsConsent.isGiven)
    }
}

struct HedvigUIKitRUMViewsPredicate: UIKitRUMViewsPredicate {
    func rumView(for _: UIViewController) -> RUMView? {
        nil
    }
}

/// Bridges our `logStartView`/`logStopView` hooks to Datadog RUM while keeping a stack of the
/// views that are still on screen underneath the active one.
///
/// RUM tracks a single active view and `stopView` does not re-activate whatever was showing before.
/// A detent/modal presented with `.custom`/`.overFullScreen` keeps its presenter on screen, but
/// UIKit never calls the presenter's `viewWillAppear` when the modal is dismissed — so without this,
/// stopping the modal's view leaves no active view. When the top view stops, we re-activate the one
/// it revealed.
@MainActor
private final class RUMViewTracker {
    static let shared = RUMViewTracker()

    private init() {}

    /// Views currently on screen, ordered bottom-to-top. The last element is the frontmost view.
    private var stack: [(key: String, name: String)] = []

    func startView(key: String, name: String) {
        stack.removeAll { $0.key == key }
        stack.append((key: key, name: name))
        // Always forward to RUM, exactly like a direct `startView` call would.
        RUMMonitor.shared().startView(key: key, name: name, attributes: [:])
    }

    func stopView(key: String) {
        let wasFrontmost = stack.last?.key == key
        stack.removeAll { $0.key == key }
        RUMMonitor.shared().stopView(key: key, attributes: [:])
        // If the frontmost view stopped and nothing new started (e.g. a `.custom`/`.overFullScreen`
        // modal was dismissed — UIKit never calls the presenter's `viewWillAppear`), re-activate the
        // view revealed underneath so RUM has an active view again.
        if wasFrontmost, let revealed = stack.last {
            RUMMonitor.shared().startView(key: revealed.key, name: revealed.name, attributes: [:])
        }
    }
}

extension View {
    func trackViewName(name: String? = nil) -> some View {
        onAppear {
            RUMMonitor.shared()
                .startView(key: .init(describing: self), name: name ?? .init(describing: self), attributes: [:])
        }
        .onDisappear {
            RUMMonitor.shared().stopView(key: .init(describing: self), attributes: [:])
        }
    }
}
