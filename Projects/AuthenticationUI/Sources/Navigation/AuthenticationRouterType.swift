import hCoreUI

public enum AuthenticationRouterType: Hashable {
    case emailLogin
    case otpCodeEntry
    case error(message: String)
}

extension AuthenticationRouterType: TrackingViewNameProtocol {
    public var nameForTracking: String {
        switch self {
        case .emailLogin:
            return .init(describing: OTPEntryView.self)
        case .otpCodeEntry:
            return .init(describing: OTPCodeEntryView.self)
        case .error:
            return .init(describing: LoginErrorView.self)
        }
    }
}
