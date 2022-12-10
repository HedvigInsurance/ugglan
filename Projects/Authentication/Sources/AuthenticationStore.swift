import Apollo
import Flow
import Foundation
import Presentation
import UIKit
import authlib
import hCore
import hCoreUI
import hGraphQL

struct OTPState: StateProtocol {
    var isLoading = false
    var isResending = false
    var resendUrl: URL? = nil
    var verifyUrl: URL? = nil
    var code: String = ""
    var codeErrorMessage: String? = nil
    var emailErrorMessage: String? = nil
    var email: String = ""
    var canResendAt: Date? = nil

    public init() {}
}

struct SEBankIDState: StateProtocol {
    var autoStartToken: String? = nil
    public init() {}
}

struct ZignsecState: StateProtocol {
    var isLoading: Bool = false
    var personalNumber: String = ""
    var webviewUrl: URL? = nil

    public init() {}
}

public struct AuthenticationState: StateProtocol {
    var currentlyObservingLoginStatusUrl: URL? = nil
    var statusText: String? = nil
    var otpState = OTPState()
    var seBankIDState = SEBankIDState()
    var zignsecState = ZignsecState()

    public init() {}
}

public enum OTPStateAction: ActionProtocol {
    case setCode(code: String)
    case verifyCode
    case setLoading(isLoading: Bool)
    case setCodeError(message: String?)
    case setEmailError(message: String?)
    case setEmail(email: String)
    case startSession(verifyUrl: URL, resendUrl: URL)
    case submitEmail
    case reset
    case resendCode
    case showResentToast
}

public enum AuthenticationNavigationAction: ActionProtocol {
    case otpCode
    case authSuccess
    case zignsecWebview
}

public enum SEBankIDStateAction: ActionProtocol {
    case startSession
    case updateWith(autoStartToken: String)
}

public enum ZignsecStateAction: ActionProtocol {
    case reset
    case setIsLoading(isLoading: Bool)
    case setPersonalNumber(personalNumber: String)
    case setWebviewUrl(url: URL)
    case startSession(personalNumber: String)
}

enum LoginError: Error {
    case failed
}

public enum AuthenticationAction: ActionProtocol {
    case setStatus(text: String?)
    case exchange(code: String)
    case cancel
    case logout
    case logoutSuccess
    case logoutFailure
    case loginFailure
    case observeLoginStatus(url: URL)
    case otpStateAction(action: OTPStateAction)
    case seBankIDStateAction(action: SEBankIDStateAction)
    case zignsecStateAction(action: ZignsecStateAction)
    case navigationAction(action: AuthenticationNavigationAction)
}

public final class AuthenticationStore: StateStore<AuthenticationState, AuthenticationAction> {
    @Inject var client: ApolloClient

    var networkAuthRepository: NetworkAuthRepository {
        NetworkAuthRepository(
            environment: Environment.current.authEnvironment,
            additionalHttpHeaders: ApolloClient.headers()
        )
    }

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

            return FiniteSignal { callback in
                let bag = DisposeBag()

                if let verifyUrl = state.otpState.verifyUrl {
                    bag += Signal(after: 0.5)
                        .onValue { _ in
                            self.networkAuthRepository.submitOtp(
                                verifyUrl: verifyUrl.absoluteString,
                                otp: state.otpState.code
                            ) { result, error in
                                if let success = result as? SubmitOtpResultSuccess {
                                    callback(.value(.exchange(code: success.loginAuthorizationCode.code)))
                                } else {
                                    callback(
                                        .value(
                                            .otpStateAction(
                                                action: .setCodeError(
                                                    message: L10n.Login.CodeInput.ErrorMsg.codeNotValid
                                                )
                                            )
                                        )
                                    )
                                }
                            }
                        }
                }

                return bag
            }
        } else if case .otpStateAction(action: .setCodeError) = action {
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.error)

            return [
                .otpStateAction(action: .setLoading(isLoading: false))
            ]
            .emitEachThenEnd
        } else if case .otpStateAction(action: .submitEmail) = action {
            let state = getState()

            return FiniteSignal { callback in
                let bag = DisposeBag()

                self.networkAuthRepository.startLoginAttempt(
                    loginMethod: .otp,
                    market: Localization.Locale.currentLocale.market.rawValue,
                    personalNumber: nil,
                    email: state.otpState.email
                ) { result, error in
                    bag += Signal(after: 0.5)
                        .onValue { _ in
                            if let otpProperties = result as? AuthAttemptResultOtpProperties,
                                let verifyUrl = URL(string: otpProperties.verifyUrl),
                                let resendUrl = URL(string: otpProperties.resendUrl)
                            {
                                callback(.value(.navigationAction(action: .otpCode)))
                                callback(
                                    .value(
                                        .otpStateAction(
                                            action: .startSession(verifyUrl: verifyUrl, resendUrl: resendUrl)
                                        )
                                    )
                                )
                            } else {
                                callback(.value(.otpStateAction(action: .setLoading(isLoading: false))))
                                callback(
                                    .value(
                                        .otpStateAction(
                                            action: .setEmailError(message: L10n.Login.TextInput.emailErrorNotValid)
                                        )
                                    )
                                )
                            }

                            callback(.end)
                        }
                }

                return bag
            }
        } else if case .navigationAction(action: .authSuccess) = action {
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.success)
        } else if case .otpStateAction(action: .resendCode) = action {
            let state = getState()

            return FiniteSignal { callback in
                if let resendUrl = state.otpState.resendUrl {
                    self.networkAuthRepository.resendOtp(resendUrl: resendUrl.absoluteString) { _, _ in
                        callback(.value(.otpStateAction(action: .showResentToast)))
                        callback(.end)
                    }
                }

                return DisposeBag()
            }
        } else if case .otpStateAction(action: .showResentToast) = action {
            Toasts.shared.displayToast(
                toast: .init(
                    symbol: .icon(hCoreUIAssets.refresh.image),
                    body: L10n.Login.Snackbar.codeResent
                )
            )
        } else if case .seBankIDStateAction(action: .startSession) = action {
            return Signal { callbacker in
                callbacker(.cancel)

                self.networkAuthRepository.startLoginAttempt(
                    loginMethod: .seBankid,
                    market: Localization.Locale.currentLocale.market.rawValue,
                    personalNumber: nil,
                    email: nil
                ) { result, error in
                    if let bankIdProperties = result as? AuthAttemptResultBankIdProperties,
                        let statusUrl = URL(string: bankIdProperties.statusUrl.url)
                    {
                        callbacker(
                            .seBankIDStateAction(
                                action: .updateWith(
                                    autoStartToken: bankIdProperties.autoStartToken
                                )
                            )
                        )

                        callbacker(.observeLoginStatus(url: statusUrl))
                    }
                }

                return DisposeBag()
            }
            .finite()
        } else if case let .observeLoginStatus(statusUrl) = action {
            return FiniteSignal { callbacker in
                let bag = DisposeBag()

                bag += Signal(every: 1)
                    .onValue { _ in
                        self.networkAuthRepository
                            .loginStatus(statusUrl: StatusUrl(url: statusUrl.absoluteString)) { result, error in
                                if let completedResult = result as? LoginStatusResultCompleted {
                                    callbacker(.value(.exchange(code: completedResult.authorizationCode.code)))
                                    callbacker(.end)
                                } else if let _ = result as? LoginStatusResultFailed {
                                    callbacker(.value(.loginFailure))
                                    callbacker(.end(LoginError.failed))
                                } else if let pendingResult = result as? LoginStatusResultPending {
                                    callbacker(.value(.setStatus(text: pendingResult.statusMessage)))
                                }
                            }
                    }

                bag += Signal(after: 250)
                    .onValue { _ in
                        callbacker(.end(LoginError.failed))
                    }

                return bag
            }
        } else if case let .exchange(code) = action {
            return Signal { callbacker in
                self.networkAuthRepository
                    .exchange(
                        grant: AuthorizationCodeGrant(code: code)
                    ) { result, error in
                        if let successResult = result as? AuthTokenResultSuccess {
                            ApolloClient.handleAuthTokenSuccessResult(result: successResult)
                            callbacker(.navigationAction(action: .authSuccess))
                        }
                    }

                return DisposeBag()
            }
            .finite()
        } else if case .logout = action {
            return FiniteSignal { callback in
                if let token = ApolloClient.retreiveToken() {
                    self.networkAuthRepository.revoke(token: token.refreshToken) { result, _ in
                        if let _ = result as? RevokeResultSuccess {
                            callback(.value(.logoutSuccess))
                        } else {
                            callback(.value(.logoutFailure))
                        }
                    }
                } else {
                    callback(.value(.logoutSuccess))
                }

                return DisposeBag()
            }
        } else if case .cancel = action {
            let state = getState()

            if let currentlyObservingLoginStatusUrl = state.currentlyObservingLoginStatusUrl {
                cancelEffect(.observeLoginStatus(url: currentlyObservingLoginStatusUrl))
            }
        } else if case let .zignsecStateAction(.startSession(personalNumber)) = action {
            return FiniteSignal { callback in
                let bag = DisposeBag()

                self.networkAuthRepository.startLoginAttempt(
                    loginMethod: .zignsec,
                    market: Localization.Locale.currentLocale.market.rawValue,
                    personalNumber: personalNumber,
                    email: nil
                ) { result, error in
                    if let zignsecProperties = result as? AuthAttemptResultZignSecProperties,
                        let statusUrl = URL(string: zignsecProperties.statusUrl.url),
                        let webviewUrl = URL(string: zignsecProperties.redirectUrl)
                    {
                        callback(.value(.zignsecStateAction(action: .setWebviewUrl(url: webviewUrl))))
                        callback(.value(.navigationAction(action: .zignsecWebview)))
                        callback(.value(.observeLoginStatus(url: statusUrl)))
                    }
                }

                return bag
            }
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
            case let .startSession(verifyUrl, resendUrl):
                newState.otpState.code = ""
                newState.otpState.verifyUrl = verifyUrl
                newState.otpState.resendUrl = resendUrl
                newState.otpState.isLoading = false
                newState.otpState.codeErrorMessage = nil
                newState.otpState.emailErrorMessage = nil
                newState.otpState.canResendAt = Date().addingTimeInterval(60)
                newState.otpState.isResending = false
            case .resendCode:
                newState.otpState.code = ""
                newState.otpState.codeErrorMessage = nil
                newState.otpState.isResending = true
            case .showResentToast:
                newState.otpState.isResending = false
            case .submitEmail:
                newState.otpState.emailErrorMessage = nil
            default:
                break
            }
        case let .seBankIDStateAction(action):
            switch action {
            case .startSession:
                newState.seBankIDState.autoStartToken = nil
            case let .updateWith(autoStartToken):
                newState.seBankIDState.autoStartToken = autoStartToken
            }
        case let .zignsecStateAction(action):
            switch action {
            case .reset:
                newState.zignsecState = ZignsecState()
            case let .setIsLoading(isLoading):
                newState.zignsecState.isLoading = isLoading
            case let .setPersonalNumber(personalNumber):
                newState.zignsecState.personalNumber = personalNumber
            case let .setWebviewUrl(url):
                newState.zignsecState.webviewUrl = url
            case .startSession:
                break
            }
        case let .setStatus(text):
            newState.statusText = text
        case let .observeLoginStatus(url):
            newState.currentlyObservingLoginStatusUrl = url
        case .cancel:
            newState.otpState = OTPState()
            newState.seBankIDState = SEBankIDState()
            newState.zignsecState.webviewUrl = nil
            newState.zignsecState.isLoading = false
        default:
            break
        }

        return newState
    }
}
