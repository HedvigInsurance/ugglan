import Apollo
import Flow
import Foundation
import Presentation
import UIKit
import hCore
import hGraphQL

struct OTPState: StateProtocol {
    var isLoading = false
    var id: String? = nil
    var code: String = ""
    var errorMessage: String? = nil
    var email: String = ""

    public init() {}
}

public struct AuthenticationState: StateProtocol {
    var otpState = OTPState()

    public init() {}
}

public enum OTPStateAction: ActionProtocol {
    case setCode(code: String)
    case verifyCode
    case setLoading(isLoading: Bool)
    case setError(message: String?)
    case setEmail(email: String)
    case setID(id: String?)
    case submitEmail
    case reset
}

public enum AuthenticationNavigationAction: ActionProtocol {
    case otpCode
    case authSuccess(accessToken: String)
}

public enum AuthenticationAction: ActionProtocol {
    case otpStateAction(action: OTPStateAction)
    case navigationAction(action: AuthenticationNavigationAction)
}

public final class AuthenticationStore: StateStore<AuthenticationState, AuthenticationAction> {
    @Inject var client: ApolloClient

    public override func effects(
        _ getState: @escaping () -> AuthenticationState,
        _ action: AuthenticationAction
    ) -> FiniteSignal<AuthenticationAction>? {
        if case let .otpStateAction(action: .setCode(code)) = action {
            let generator = UIImpactFeedbackGenerator(style: .light)
            generator.impactOccurred()

            if code.count == 6 {
                return [
                    .otpStateAction(action: .verifyCode),
                    .otpStateAction(action: .setLoading(isLoading: true)),
                ]
                .emitEachThenEnd
            }
        } else if case .otpStateAction(action: .verifyCode) = action {
            let state = getState()

            return
                client.perform(
                    mutation: GraphQL.VerifyLoginOtpAttemptMutation(
                        id: state.otpState.id ?? "",
                        otp: state.otpState.code
                    )
                )
                .delay(by: 0.5)
                .compactMap { data in
                    if let error = data.loginVerifyOtpAttempt.asVerifyOtpLoginAttemptError {
                        return .otpStateAction(action: .setError(message: error.errorCode))
                    } else if let success = data.loginVerifyOtpAttempt.asVerifyOtpLoginAttemptSuccess {
                        return .navigationAction(action: .authSuccess(accessToken: success.accessToken))
                    }
                    
                    return nil
                }
                .valueThenEndSignal
        } else if case .otpStateAction(action: .setError) = action {
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.error)

            return [
                .otpStateAction(action: .setLoading(isLoading: false))
            ]
            .emitEachThenEnd
        } else if case .otpStateAction(action: .submitEmail) = action {
            let state = getState()

            return
                client.perform(
                    mutation: GraphQL.CreateLoginOtpAttemptMutation(
                        email: state.otpState.email
                    )
                )
                .map { data in
                    .otpStateAction(action: .setID(id: data.loginCreateOtpAttempt))
                }
                .valueThenEndSignal
        } else if case .otpStateAction(action: .setID) = action {
            return [
                .navigationAction(action: .otpCode),
                .otpStateAction(action: .setLoading(isLoading: false)),
            ]
            .emitEachThenEnd
        }

        return nil
    }

    public override func reduce(_ state: AuthenticationState, _ action: AuthenticationAction) -> AuthenticationState {
        var newState = state

        switch action {
        case let .otpStateAction(action):
            switch action {
            case .reset:
                newState.otpState = .init()
            case let .setCode(code):
                if state.otpState.isLoading {
                    return newState
                }

                if code.count <= 6 {
                    newState.otpState.code = String(code.prefix(6))
                } else {
                    newState.otpState.code = String(code.suffix(1))
                }

                newState.otpState.errorMessage = nil
            case let .setLoading(isLoading):
                newState.otpState.isLoading = isLoading
            case let .setError(message):
                newState.otpState.errorMessage = message
            case let .setEmail(email):
                newState.otpState.email = email
            case let .setID(id):
                newState.otpState.id = id
            default:
                break
            }
        default:
            break
        }

        return newState
    }
}
