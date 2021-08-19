import Foundation
import ProjectDescription

public enum ExternalDependency: CaseIterable {
    case adyen
    case firebase
    case kingfisher
    case apollo
    case flow
    case form
    case presentation
    case dynamiccolor
    case disk
    case snapkit
    case markdownkit
    case mixpanel
    case runtime
    case sentry
    case hero
    case snapshottesting
    case shake

    public func targetDependencies() -> [TargetDependency] {
        switch self {
        case .sentry: return [.external(name: "Sentry")]
        case .adyen:
            return [
                .external(name: "Adyen"), .external(name: "AdyenCard"),
                .external(name: "AdyenDropIn"),
            ]
        case .firebase: return [.external(name: "FirebaseAnalytics"), .external(name: "FirebaseMessaging")]
        case .kingfisher: return [.external(name: "Kingfisher")]
        case .apollo: return [.external(name: "ApolloWebSocket"), .external(name: "Apollo")]
        case .flow: return [.external(name: "Flow")]
        case .form: return [.external(name: "Form")]
        case .presentation:
            return [.external(name: "Presentation"), .external(name: "PresentationDebugSupport")]
        case .dynamiccolor: return [.external(name: "DynamicColor")]
        case .disk: return [.external(name: "Disk")]
        case .snapkit: return [.external(name: "SnapKit")]
        case .markdownkit: return [.external(name: "MarkdownKit")]
        case .mixpanel: return [.external(name: "Mixpanel")]
        case .runtime: return [.external(name: "Runtime")]
        case .hero: return [.external(name: "Hero")]
        case .snapshottesting: return [.external(name: "SnapshotTesting")]
        case .shake: return [.external(name: "Shake")]
        }
    }
}
