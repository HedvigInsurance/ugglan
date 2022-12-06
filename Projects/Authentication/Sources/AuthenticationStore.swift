import Apollo
import Flow
import Foundation
import Presentation
import UIKit
import hCore
import hCoreUI
import hGraphQL
import authlib

struct OTPState: StateProtocol {
    var isLoading = false
    var isResending = false
    var id: String? = nil
    var code: String = ""
    var codeErrorMessage: String? = nil
    var emailErrorMessage: String? = nil
    var email: String = ""
    var canResendAt: Date? = nil

    public init() {}
}

struct SEBankIDState: StateProtocol {
    var statusUrl: URL? = nil
    var autoStartToken: String? = nil
    public init() {}
}

public struct AuthenticationState: StateProtocol {
    var otpState = OTPState()
    var seBankIDState = SEBankIDState()

    public init() {}
}

public enum OTPStateAction: ActionProtocol {
    case setCode(code: String)
    case verifyCode
    case setLoading(isLoading: Bool)
    case setCodeError(message: String?)
    case setEmailError(message: String?)
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
    case chat
}

public enum SEBankIDStateAction: ActionProtocol {
    case startSession
    case updateWith(autoStartToken: String, statusUrl: URL)
}

public enum AuthenticationAction: ActionProtocol {
    case otpStateAction(action: OTPStateAction)
    case seBankIDStateAction(action: SEBankIDStateAction)
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
                    if data.loginVerifyOtpAttempt.asVerifyOtpLoginAttemptError != nil {
                        return .otpStateAction(
                            action: .setCodeError(message: L10n.Login.CodeInput.ErrorMsg.codeNotValid)
                        )
                    } else if let success = data.loginVerifyOtpAttempt.asVerifyOtpLoginAttemptSuccess {
                        return .navigationAction(action: .authSuccess(accessToken: success.accessToken))
                    }

                    return nil
                }
                .valueThenEndSignal
        } else if case .otpStateAction(action: .setCodeError) = action {
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
                            .otpStateAction(action: .setEmailError(message: L10n.Login.TextInput.emailErrorNotValid)),
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
        } else if case .seBankIDStateAction(action: .startSession) = action {
            return Future { completion in
                NetworkAuthRepository(environment: Environment.current.authEnvironment).startLoginAttempt(
                    loginMethod: .seBankid,
                    market: Localization.Locale.currentLocale.market.rawValue,
                    personalNumber: nil,
                    email: nil
                ) { result, error in
                    if
                        let bankIdProperties = result as? AuthAttemptResultBankIdProperties,
                        let statusUrl = URL(string: bankIdProperties.statusUrl.url)
                    {
                        completion(
                            .success(
                                .seBankIDStateAction(
                                    action: .updateWith(
                                        autoStartToken: bankIdProperties.autoStartToken,
                                        statusUrl: statusUrl
                                    )
                                )
                            )
                        )
                    }
                }
                
                return DisposeBag()
            }
            .valueThenEndSignal
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

                newState.otpState.codeErrorMessage = nil
            case let .setLoading(isLoading):
                newState.otpState.isLoading = isLoading
            case let .setCodeError(message):
                newState.otpState.codeErrorMessage = message
            case let .setEmailError(message):
                newState.otpState.emailErrorMessage = message
            case let .setEmail(email):
                newState.otpState.email = email
                newState.otpState.emailErrorMessage = nil
            case let .setID(id):
                newState.otpState.code = ""
                newState.otpState.id = id
                newState.otpState.codeErrorMessage = nil
                newState.otpState.emailErrorMessage = nil
                newState.otpState.canResendAt = Date().addingTimeInterval(60)
                newState.otpState.isResending = false
            case .resendCode:
                newState.otpState.code = ""
                newState.otpState.codeErrorMessage = nil
                newState.otpState.isResending = true
            case .submitEmail:
                newState.otpState.emailErrorMessage = nil
            default:
                break
            }
        case let .seBankIDStateAction(action):
            switch action {
            case .startSession:
                newState.seBankIDState.autoStartToken = nil
                newState.seBankIDState.statusUrl = nil
            case let .updateWith(autoStartToken, statusUrl):
                newState.seBankIDState.autoStartToken = autoStartToken
                newState.seBankIDState.statusUrl = statusUrl
            }
        default:
            break
        }

        return newState
    }
}
