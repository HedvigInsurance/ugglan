import Foundation
import SwiftUI

public struct NavigationViews: RawRepresentable, Hashable {
    public init(
        rawValue: String
    ) {
        self.rawValue = rawValue
    }

    public var rawValue: String
    public static let tabBarView = NavigationViews(rawValue: "tabBarView")
    public static let homeView = NavigationViews(rawValue: "homeView")
    public static let foreverView = NavigationViews(rawValue: "foreverView")

    public static let submitClaim = NavigationViews(rawValue: "submitClaim")
}

public enum NavigationForeverView {
    case changeCodeView
}

public enum NavigationHomeView {
    case helpCenter
}

public enum NavigationClaimsView {
    case honestyPledge
}

@available(iOS 16.0, *)
public class MyModelObject: ObservableObject {

    @Published public var path: NavigationPath
    public var currentMainRoute: NavigationViews = .homeView
    public var currentForeverRoute: NavigationForeverView = .changeCodeView
    public var currentHomeRoute: NavigationHomeView = .helpCenter
    public var currentClaimsRoute: NavigationClaimsView = .honestyPledge

    public init() {
        self.path = NavigationPath()
    }

    public func changeRoute(_ route: NavigationViews) {
        path.append(route)
        currentMainRoute = route
    }

    public func changeForeverRoute(_ route: NavigationForeverView) {
        currentForeverRoute = route
    }

    public func changeHomeRoute(_ route: NavigationHomeView) {
        currentHomeRoute = route
    }

    public func changeClaimsRoute(_ route: NavigationClaimsView) {
        currentClaimsRoute = route
    }

    public func backRoute() {
        path.removeLast()
    }
}
