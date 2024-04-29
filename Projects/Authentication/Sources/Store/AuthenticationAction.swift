import Foundation
import Presentation

public enum AuthenticationNavigationAction: ActionProtocol {
    case impersonation
}

enum LoginError: Error {
    case failed
}

public enum AuthenticationAction: ActionProtocol {
    case cancel
    case logout
    case logoutSuccess
    case logoutFailure
    case loginFailure(message: String?)
    case navigationAction(action: AuthenticationNavigationAction)
}
