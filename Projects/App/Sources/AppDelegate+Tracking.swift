import DatadogCore
import DatadogCrashReporting
import DatadogLogs
import DatadogRUM
import DatadogTrace
import Introspect
import SwiftUI
import UIKit
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
                )
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

        let viewName = viewController.getViewNameForRum
        if !viewName.shouldBeLoggedAsView {
            return nil
        }
        var view = RUMView(name: viewName)
        view.path = viewName
        print("VIEW NAME: \(viewName) ")
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
    fileprivate var getViewNameForRum: String {

        var viewControllerName = String(describing: type(of: self).self)
        if let self = self as? UINavigationController, self.viewControllers.count == 1 {
            if let vc = self.viewControllers.first, HedvigUIKitRUMViewsPredicate.isUIKit(class: type(of: vc)),
                let title = vc.title
            {
                return title
            }
        }

        if viewControllerName.contains("HostingJourneyController") {
            if let range = viewControllerName.range(of: "HostingJourneyController<") {
                viewControllerName.removeSubrange(range)
            }

            if let lastIndex = viewControllerName.lastIndex(of: ">") {
                viewControllerName.remove(at: lastIndex)
            }
        }

        if viewControllerName.contains("ModifiedContent") {
            if let range = viewControllerName.range(of: "ModifiedContent<") {
                viewControllerName.removeSubrange(range)
            }
            if let viewName = viewControllerName.components(separatedBy: ",").first {
                return viewName
            }
        }
        return viewControllerName
    }
}

extension String {
    fileprivate var shouldBeLoggedAsView: Bool {
        switch self {

        case String(describing: hNavigationController.self),
            String(describing: hNavigationControllerWithLargerNavBar.self),
            String(describing: IntrospectionUIViewController.self):
            return false
        default:
            return true
        }
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
