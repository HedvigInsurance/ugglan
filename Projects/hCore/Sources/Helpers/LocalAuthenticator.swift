import Foundation
import LocalAuthentication

@MainActor
public protocol LocalAuthenticator {
    /// Asks the user to confirm their identity with Face ID / Touch ID, falling back to the device passcode.
    /// Throws `LocalAuthenticationError` when authentication fails or is cancelled.
    /// Succeeds when the device has no biometrics or passcode set up, or biometrics are locked out, so the user
    /// isn't blocked by something they can't resolve in the app.
    func authenticate(reason: String) async throws
}

public struct DefaultLocalAuthenticator: LocalAuthenticator {
    public init() {}

    public func authenticate(reason: String) async throws {
        let context = LAContext()
        var error: NSError?
        guard context.canEvaluatePolicy(.deviceOwnerAuthentication, error: &error) else {
            return
        }
        do {
            try await context.evaluatePolicy(.deviceOwnerAuthentication, localizedReason: reason)
        } catch let error as LAError {
            switch error.code {
            case .biometryLockout, .passcodeNotSet, .biometryNotAvailable, .biometryNotEnrolled:
                return
            default:
                throw LocalAuthenticationError(error)
            }
        } catch {
            throw LocalAuthenticationError.unknown
        }
    }
}

public enum LocalAuthenticationError: Error, Equatable {
    /// The user dismissed the prompt.
    case cancelledByUser
    /// The system or the app dismissed the prompt, e.g. the app went to the background; nothing to report.
    case cancelledBySystem
    /// The user didn't pass Face ID / Touch ID or entered the wrong passcode.
    case failed
    case unknown

    init(_ error: LAError) {
        switch error.code {
        case .userCancel:
            self = .cancelledByUser
        case .systemCancel, .appCancel:
            self = .cancelledBySystem
        case .authenticationFailed:
            self = .failed
        default:
            self = .unknown
        }
    }
}

// TODO: Replace with L10n keys once the strings are added to Lokalise.
extension LocalAuthenticationError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .cancelledByUser:
            return "You need to confirm it's you to make this change."
        case .cancelledBySystem:
            return nil
        case .failed:
            return "We couldn't verify that it's you. Please try again."
        case .unknown:
            return "We couldn't verify your identity right now. Please try again."
        }
    }
}

public struct LocalAuthenticatorDemo: LocalAuthenticator {
    public init() {}

    public func authenticate(reason: String) async throws {}
}

extension Dependencies {
    public static var localAuthenticator: LocalAuthenticator {
        Dependencies.shared.resolve()
    }
}
