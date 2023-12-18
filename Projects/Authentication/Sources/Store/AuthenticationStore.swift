import Apollo
import Flow
import Foundation
import Presentation
import UIKit
import authlib
import hCore
import hCoreUI
import hGraphQL

enum LoginStatus: Equatable {
    case pending(statusMessage: String?)
    case completed(code: String)
    case failed(message: String?)
    case unknown
}

extension CoreSignal where Kind == Plain {
    func poll(
        poller: @escaping () -> Signal<Value>,
        shouldPoll: @escaping (_ value: Value) -> Bool
    ) -> CoreSignal<Plain, Value> {
        return self.flatMapLatest { value in
            if shouldPoll(value) {
                return poller()
                    .delay(by: 0.25)
                    .poll(poller: poller, shouldPoll: shouldPoll)
            }

            return Signal(just: value)
        }
    }
}

public final class AuthenticationStore: StateStore<AuthenticationState, AuthenticationAction> {
    lazy var networkAuthRepository: NetworkAuthRepository = {
        NetworkAuthRepository(
            environment: Environment.current.authEnvironment,
            additionalHttpHeaders: ApolloClient.headers(),
            callbacks: Callbacks(
                successUrl: "\(Bundle.main.urlScheme ?? "")://login-success",
                failureUrl: "\(Bundle.main.urlScheme ?? "")://login-failure"
            )
        )
    }()
    func checkStatus(statusUrl: URL) -> Signal<LoginStatus> {
        return Signal { callbacker in
            self.networkAuthRepository
                .loginStatus(statusUrl: StatusUrl(url: statusUrl.absoluteString)) { result, error in
                    if let completedResult = result as? LoginStatusResultCompleted {
                        log.info(
                            "LOGIN AUTH FINISHED"
                        )
                        callbacker(.completed(code: completedResult.authorizationCode.code))
                    } else if let result = result as? LoginStatusResultFailed {
                        let message = result.message
                        log.error(
                            "LOGIN FAILED",
                            error: NSError(domain: message, code: 1000),
                            attributes: [
                                "message": message,
                                "statusUrl": statusUrl.absoluteString,
                            ]
                        )
                        callbacker(.failed(message: message))
                    } else if let pendingResult = result as? LoginStatusResultPending {
                        callbacker(.pending(statusMessage: pendingResult.statusMessage))
                    } else {
                        callbacker(.unknown)
                    }
                }

            return NilDisposer()
        }
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
            send(.bankIdQrResultAction(action: .loggedIn))
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
                    } else if let result = result as? AuthAttemptResultError {
                        let error = NSError(domain: result.message, code: 1000)
                        log.error(
                            "Got Error when signing in with BankId",
                            error: error,
                            attributes: [:]
                        )
                        callbacker(.loginFailure(message: nil))
                    } else if let error {
                        log.error(
                            "Got Error when signing in with BankId",
                            error: error,
                            attributes: [:]
                        )
                        callbacker(.loginFailure(message: nil))
                    }
                }

                return DisposeBag()
            }
            .finite()

        } else if case let .observeLoginStatus(statusUrl) = action {
            return FiniteSignal { callbacker in
                let bag = DisposeBag()

                bag += self.checkStatus(statusUrl: statusUrl)
                    .poll {
                        self.checkStatus(statusUrl: statusUrl)
                    } shouldPoll: { loginStatus in
                        if case .pending = loginStatus {
                            return true
                        } else if case .unknown = loginStatus {
                            return true
                        }

                        return false
                    }
                    .onValue { loginStatus in
                        if case let .completed(code) = loginStatus {
                            callbacker(.value(.exchange(code: code)))
                            callbacker(.end)
                        } else if case let .failed(message) = loginStatus {
                            callbacker(.value(.loginFailure(message: message)))
                            callbacker(.end(LoginError.failed))
                        }
                    }

                bag += self.actionSignal.onValue({ action in
                    switch action {
                    case .observeLoginStatus(_),
                        .cancel,
                        .navigationAction(action: .authSuccess):
                        callbacker(.end)
                    default:
                        break
                    }
                })

                return bag
            }
        } else if case let .exchange(code) = action {
            return Signal { callbacker in
                self.exchange(code: code) { successResult in
                    ApolloClient.handleAuthTokenSuccessResult(result: successResult)
                    callbacker(.navigationAction(action: .authSuccess))
                }
                return DisposeBag()
            }
            .finite()
        } else if case let .impersonate(code) = action {
            return Signal { callbacker in
                self.exchange(code: code) { successResult in
                    ApolloClient.handleAuthTokenSuccessResult(result: successResult)
                    callbacker(.navigationAction(action: .impersonation))
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
                        callback(.value(.navigationAction(action: .zignsecWebview(url: webviewUrl))))
                        callback(.value(.observeLoginStatus(url: statusUrl)))
                    } else {
                        callback(
                            .value(
                                .zignsecStateAction(
                                    action: .setIsLoading(isLoading: false)
                                )
                            )
                        )
                        callback(
                            .value(
                                .zignsecStateAction(
                                    action: .setCredentialError(error: true)
                                )
                            )
                        )
                    }
                    callback(.end)
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
            case let .setCredentialError(error):
                newState.zignsecState.credentialError = error
            case .startSession:
                newState.zignsecState.credentialError = false
            }
        case let .setStatus(text):
            newState.statusText = text
        case .cancel:
            newState.otpState = OTPState()
            newState.seBankIDState = SEBankIDState()
            newState.zignsecState.webviewUrl = nil
            newState.zignsecState.isLoading = false
            newState.zignsecState.credentialError = false
            newState.loginHasFailed = false
        case .loginFailure:
            newState.seBankIDState = SEBankIDState()
            newState.loginHasFailed = true
        default:
            break
        }

        return newState
    }

    private func exchange(
        code: String,
        onSuccess: @escaping (AuthTokenResultSuccess) -> Void
    ) {
        DispatchQueue.main.async {
            self.networkAuthRepository
                .exchange(
                    grant: AuthorizationCodeGrant(code: code)
                ) { result, error in
                    if let successResult = result as? AuthTokenResultSuccess {
                        onSuccess(successResult)
                    }
                }
        }
    }
}
