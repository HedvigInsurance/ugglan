import DatadogCore
import DatadogCrashReporting
import DatadogLogs
import DatadogRUM
import DatadogTrace
import Introspect
import Presentation
import Profile
import SwiftUI
import hCore
import hCoreUI
import hGraphQL

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
        if hGraphQL.Environment.current == .staging || hGraphQL.Environment.hasOverridenDefault {
            Datadog.verbosityLevel = .debug
        }
    }
}

public struct HedvigUIKitRUMViewsPredicate: UIKitRUMViewsPredicate {
    public init() {}

    public func rumView(for viewController: UIViewController) -> RUMView? {
        guard !HedvigUIKitRUMViewsPredicate.isUIKit(class: type(of: viewController)) else {
            // Part of our heuristic for (auto) tracking view controllers is to ignore
            // container view controllers coming from `UIKit` if they are not subclassed.
            // This condition is wider and it ignores all view controllers defined in `UIKit` bundle.
            return nil
        }

        guard !isSwiftUI(class: type(of: viewController)) else {
            // `SwiftUI` requires manual instrumentation in views. Therefore, all SwiftUI
            // `UIKit` containers (e.g. `UIHostingController`) will be ignored from
            // auto-intrumentation.
            // This condition is wider and it ignores all view controllers defined in `SwiftUI` bundle.
            return nil
        }

        guard let viewName = viewController.getViewNameForRum else { return nil }
        var view = RUMView(name: viewName)
        view.path = viewName
        print("VIEW NAME: \(viewName) ")
        return nil
        return view
    }

    static func isUIKit(`class`: AnyClass) -> Bool {
        return Bundle(for: `class`).isUIKit
    }

    private func isSwiftUI(`class`: AnyClass) -> Bool {
        return Bundle(for: `class`).isSwiftUI
    }
}

extension UIViewController {
    fileprivate var getViewNameForRum: String? {
        let debugDescriptionName = self.debugDescription
        return debugDescriptionName.getViewName()
    }
}

extension String {
    fileprivate func getViewName() -> String? {
        let removedModifiedContent = self.replacingOccurrences(of: "ModifiedContent<", with: "")
        guard let firstElement = removedModifiedContent.split(separator: ",").first else { return nil }
        let nameToLog = String(firstElement)
        if !nameToLog.shouldBeLoggedAsView {
            return nil
        }
        let elements = nameToLog.split(separator: "SizeModifier<")
        if elements.count > 1, let lastElement = elements.last {
            return String(lastElement).replacingOccurrences(of: "Optional<", with: "")
                .replacingOccurrences(of: ">", with: "")
        } else {
            let elements = nameToLog.split(separator: ":")
            if elements.count > 1, let firstElement = elements.first {
                return String(firstElement).replacingOccurrences(of: "<", with: "")
            }
            return nameToLog
        }
    }
    fileprivate var shouldBeLoggedAsView: Bool {

        let array = [
            String(describing: hNavigationController.self),
            String(describing: hNavigationControllerWithLargerNavBar.self),
            String(describing: IntrospectionUIViewController.self),
            "EmbededInNavigation",
            "PUPickerRemoteViewController",
            "CAMImagePickerCameraViewController",
            "CAMViewfinderViewController",
            "UIDocumentBrowserViewController",
        ]

        for element in array {
            if self.contains(element) {
                return false
            }
        }
        return true
    }
}

extension Bundle {
    fileprivate var isUIKit: Bool {
        return bundleURL.lastPathComponent == "UIKitCore.framework"  // on iOS 12+
            || bundleURL.lastPathComponent == "UIKit.framework"  // on iOS 11
    }
}

extension Bundle {
    var isSwiftUI: Bool {
        return bundleURL.lastPathComponent == "SwiftUI.framework"
    }
}

extension SwiftUI.View {
    var typeDescription: String {
        return String(describing: type(of: self))
    }
}
