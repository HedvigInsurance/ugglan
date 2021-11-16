import Apollo
import Flow
import Foundation
import Presentation
import UIKit
import hCore
import hCoreUI
import hGraphQL

struct OTPState: StateProtocol {
    var isLoading = false
    var isResending = false
    var id: String? = nil
    var code: String = ""
    var errorMessage: String? = nil
    var email: String = ""
    var canResendAt: Date? = nil

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
    case resendCode
    case showResentToast
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
                .resultSignal
                .delay(by: 0.5)
                .flatMapLatest { result -> FiniteSignal<AuthenticationAction> in
                    switch result {
                    case .failure:
                        return [
                            .otpStateAction(action: .setLoading(isLoading: false)),
                            .otpStateAction(action: .setError(message: L10n.Login.TextInput.emailErrorNotValid))
                        ]
                        .emitEachThenEnd
                    case let .success(data):
                        return [
                            .navigationAction(action: .otpCode),
                            .otpStateAction(action: .setID(id: data.loginCreateOtpAttempt)),
                        ]
                        .emitEachThenEnd
                    }
                }
        } else if case .otpStateAction(action: .setID) = action {
            return [
                .otpStateAction(action: .setLoading(isLoading: false))
            ]
            .emitEachThenEnd
        } else if case .navigationAction(action: .authSuccess) = action {
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.success)
        } else if case .otpStateAction(action: .resendCode) = action {
            let state = getState()

            return
                client.perform(
                    mutation: GraphQL.ResendLoginOtpMutation(id: state.otpState.id ?? "")
                )
                .valueThenEndSignal
                .flatMapLatest { data in
                    [
                        .otpStateAction(action: .setID(id: data.loginResendOtp)),
                        .otpStateAction(action: .showResentToast),
                    ]
                    .emitEachThenEnd
                }
        } else if case .otpStateAction(action: .showResentToast) = action {
            Toasts.shared.displayToast(
                toast: .init(
                    symbol: .icon(hCoreUIAssets.refresh.image),
                    body: L10n.Login.Snackbar.codeResent
                )
            )
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
                newState.otpState.code = ""
                newState.otpState.id = id
                newState.otpState.canResendAt = Date().addingTimeInterval(60)
                newState.otpState.isResending = false
            case .resendCode:
                newState.otpState.code = ""
                newState.otpState.errorMessage = nil
                newState.otpState.isResending = true
            case .submitEmail:
                newState.otpState.errorMessage = nil
            default:
                break
            }
        default:
            break
        }

        return newState
    }
}
