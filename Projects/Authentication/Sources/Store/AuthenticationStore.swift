import Apollo
import Flow
import Foundation
import Presentation
import SwiftUI
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

final class Poll<ReturnValue> {
    let action: (() async throws -> ReturnValue?)?
    let shouldPull: (_ value: ReturnValue) -> Bool

    init(
        action: @escaping () async throws -> ReturnValue,
        shouldPull: @escaping (_ value: ReturnValue) -> Bool
    ) {
        self.action = action
        self.shouldPull = shouldPull
    }

    func getValue() async throws -> ReturnValue? {
        if let action {
            let data = try await action()
            if let data {
                if shouldPull(data) {
                    try? await Task.sleep(nanoseconds: 250_000_000)
                    return try await getValue()
                } else {
                    return data
                }
            }
        }
        return nil
    }
}

public final class AuthenticationStore: StateStore<AuthenticationState, AuthenticationAction> {
    lazy var networkAuthRepository: NetworkAuthRepository = {
        NetworkAuthRepository(
            environment: Environment.current.authEnvironment,
            additionalHttpHeadersProvider: { ApolloClient.headers() },
            callbacks: Callbacks(
                successUrl: "\(Bundle.main.urlScheme ?? "")://login-success",
                failureUrl: "\(Bundle.main.urlScheme ?? "")://login-failure"
            ),
            httpClientEngine: nil
        )
    }()
    func checkStatus(statusUrl: URL) async throws -> LoginStatus {
        async let sleepTask: () = try Task.sleep(nanoseconds: 2 * 100_000_000)
        async let statusTask = try self.networkAuthRepository.loginStatus(
            statusUrl: .init(url: statusUrl.absoluteString)
        )
        do {
            let data = try await [sleepTask, statusTask] as [Any]
            let statusData = data[1] as! LoginStatusResult
            if let statusData = statusData as? LoginStatusResultCompleted {
                log.info(
                    "LOGIN AUTH FINISHED"
                )
                return .completed(code: statusData.authorizationCode.code)
            } else if let statusData = statusData as? LoginStatusResultFailed {
                let message = statusData.message
                log.error(
                    "LOGIN FAILED",
                    error: NSError(domain: message, code: 1000),
                    attributes: [
                        "message": message,
                        "statusUrl": statusUrl.absoluteString,
                    ]
                )
                return .failed(message: message)
            } else if let statusData = statusData as? LoginStatusResultPending {
                self.send(
                    .seBankIDStateAction(
                        action: .setLiveQrCodeData(
                            liveQrCodeData: statusData.liveQrCodeData,
                            date: Date()
                        )
                    )
                )
                return .pending(statusMessage: statusData.statusMessage)
            } else {
                return .unknown
            }
        } catch let error {
            return .failed(message: error.localizedDescription)
        }
    }

    public override func effects(
        _ getState: @escaping () -> AuthenticationState,
        _ action: AuthenticationAction
    ) async {
        if case let .otpStateAction(action: .setCode(code)) = action {
            Task {
                let generator = await UIImpactFeedbackGenerator(style: .light)
                await generator.impactOccurred()
            }
            if code.count == 6 {
                send(.otpStateAction(action: .verifyCode))
                send(.otpStateAction(action: .setLoading(isLoading: true)))
            }
        } else if case .otpStateAction(action: .verifyCode) = action {
            let state = getState()
            if let verifyUrl = state.otpState.verifyUrl {
                do {
                    try await Task.sleep(nanoseconds: 5 * 100_000_000)
                    let data = try await networkAuthRepository.submitOtp(
                        verifyUrl: verifyUrl.absoluteString,
                        otp: state.otpState.code
                    )
                    if let data = data as? SubmitOtpResultSuccess {
                        send(.exchange(code: data.loginAuthorizationCode.code))
                    } else {
                        send(
                            .otpStateAction(action: .setCodeError(message: L10n.Login.CodeInput.ErrorMsg.codeNotValid))
                        )
                    }
                } catch {
                    send(.otpStateAction(action: .setCodeError(message: L10n.Login.CodeInput.ErrorMsg.codeNotValid)))
                }
            }
        } else if case .otpStateAction(action: .setCodeError) = action {
            Task {
                let generator = await UINotificationFeedbackGenerator()
                await generator.notificationOccurred(.error)
            }
            send(.otpStateAction(action: .setLoading(isLoading: false)))
        } else if case .otpStateAction(action: .submitOtpData) = action {
            let state = getState()
            let personalNumber = state.otpState.personalNumber?.replacingOccurrences(of: "-", with: "")
            do {
                let data = try await self.networkAuthRepository.startLoginAttempt(
                    loginMethod: .otp,
                    market: Localization.Locale.currentLocale.market.rawValue,
                    personalNumber: personalNumber,
                    email: state.otpState.email
                )
                try await Task.sleep(nanoseconds: 5 * 100_000_000)
                if let otpProperties = data as? AuthAttemptResultOtpProperties,
                    let verifyUrl = URL(string: otpProperties.verifyUrl),
                    let resendUrl = URL(string: otpProperties.resendUrl)
                {
                    send(.navigationAction(action: .otpCode))
                    send(.otpStateAction(action: .startSession(verifyUrl: verifyUrl, resendUrl: resendUrl)))
                } else {
                    send(.otpStateAction(action: .setLoading(isLoading: false)))
                    send(.otpStateAction(action: .setOtpInputError(message: L10n.Login.TextInput.emailErrorNotValid)))
                }
            } catch {
                send(.otpStateAction(action: .setLoading(isLoading: false)))
                send(.otpStateAction(action: .setOtpInputError(message: L10n.Login.TextInput.emailErrorNotValid)))
            }
        } else if case .navigationAction(action: .authSuccess) = action {
            Task {
                let generator = await UINotificationFeedbackGenerator()
                await generator.notificationOccurred(.success)
            }
            send(.bankIdQrResultAction(action: .loggedIn))
        } else if case .otpStateAction(action: .resendCode) = action {
            let state = getState()
            if let resendUrl = state.otpState.resendUrl {
                do {
                    _ = try await self.networkAuthRepository.resendOtp(resendUrl: resendUrl.absoluteString)
                    send(.otpStateAction(action: .showResentToast))
                } catch {}
            }
        } else if case .otpStateAction(action: .showResentToast) = action {
            Toasts.shared.displayToast(
                toast: .init(
                    symbol: .icon(hCoreUIAssets.refresh.image),
                    body: L10n.Login.Snackbar.codeResent
                )
            )
        } else if case .seBankIDStateAction(action: .startSession) = action {
            send(.cancel)
            do {
                let data = try await self.networkAuthRepository.startLoginAttempt(
                    loginMethod: .seBankid,
                    market: Localization.Locale.currentLocale.market.rawValue,
                    personalNumber: nil,
                    email: nil
                )
                if let data = data as? AuthAttemptResultBankIdProperties,
                    let statusUrl = URL(string: data.statusUrl.url)
                {
                    send(.seBankIDStateAction(action: .setAutoStartTokenWith(autoStartToken: data.autoStartToken)))
                    send(
                        .seBankIDStateAction(
                            action: .setLiveQrCodeData(liveQrCodeData: data.liveQrCodeData, date: Date())
                        )
                    )
                    send(.observeLoginStatus(url: statusUrl))
                } else if let result = data as? AuthAttemptResultError {
                    var localizedMessage = L10n.General.errorBody
                    var logMessage = "Got Error when signing in with BankId"
                    if let result = result as? AuthAttemptResultErrorLocalised {
                        localizedMessage = result.reason
                        logMessage =
                            "Got AuthAttemptResultErrorLocalised when signing in with BankId. Reason:\(result.reason)."
                    } else if let result = result as? AuthAttemptResultErrorBackendErrorResponse {
                        logMessage =
                            "Got AuthAttemptResultErrorBackendErrorResponse when signing in with BankId. Message:\(result.message). Error code:\(result.httpStatusValue)"
                    } else if let result = result as? AuthAttemptResultErrorIOError {
                        logMessage =
                            "Got AuthAttemptResultErrorIOError when signing in with BankId. Message:\(result.message)"
                    } else if let result = result as? AuthAttemptResultErrorUnknownError {
                        logMessage =
                            "Got AuthAttemptResultErrorIOError when signing in with BankId. Message:\(result.message)"
                    }
                    let error = NSError(domain: logMessage, code: 1000)
                    log.error(
                        logMessage,
                        error: error,
                        attributes: [:]
                    )
                    send(.loginFailure(message: localizedMessage))
                }
            } catch let error {
                log.error(
                    "Got Error when signing in with BankId",
                    error: error,
                    attributes: [:]
                )
                send(.loginFailure(message: nil))
            }
        } else if case let .observeLoginStatus(statusUrl) = action {
            let poll = Poll { [weak self] in
                return try await self?.checkStatus(statusUrl: statusUrl)
            } shouldPull: { loginStatus in
                if case .pending = loginStatus {
                    return true
                } else if case .unknown = loginStatus {
                    return true
                }

                return false
            }
            do {
                let status = try await poll.getValue()
                if case let .completed(code) = status {
                    send(.exchange(code: code))
                } else if case let .failed(message) = status {
                    send(.loginFailure(message: message))
                }
            } catch {
                send(.loginFailure(message: nil))
            }
        } else if case let .exchange(code) = action {
            do {
                let successResult = try await self.exchange(code: code)
                ApolloClient.handleAuthTokenSuccessResult(result: successResult)
                send(.navigationAction(action: .authSuccess))
            } catch {

            }
        } else if case let .impersonate(code) = action {
            do {
                let successResult = try await self.exchange(code: code)
                ApolloClient.handleAuthTokenSuccessResult(result: successResult)
                send(.navigationAction(action: .impersonation))
            } catch {

            }
        } else if case .logout = action {
            do {
                if let token = try ApolloClient.retreiveToken() {
                    let data = try await self.networkAuthRepository.revoke(token: token.refreshToken)
                    if let data = data as? RevokeResultSuccess {
                        send(.logoutSuccess)
                    } else {
                        send(.logoutFailure)
                    }
                } else {
                    send(.logoutSuccess)
                }
            } catch {
                send(.logoutFailure)
            }
        }
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
            case let .setEmail(email):
                newState.otpState.email = email
                newState.otpState.otpInputErrorMessage = nil
                newState.otpState.personalNumber = nil
            case let .setOtpInputError(message):
                newState.otpState.otpInputErrorMessage = message
            case let .setPersonalNumber(personalNumber):
                newState.otpState.personalNumber = personalNumber
                newState.otpState.otpInputErrorMessage = nil
                newState.otpState.email = nil
            case let .startSession(verifyUrl, resendUrl):
                newState.otpState.code = ""
                newState.otpState.verifyUrl = verifyUrl
                newState.otpState.resendUrl = resendUrl
                newState.otpState.isLoading = false
                newState.otpState.codeErrorMessage = nil
                newState.otpState.otpInputErrorMessage = nil
                newState.otpState.canResendAt = Date().addingTimeInterval(60)
                newState.otpState.isResending = false
            case .resendCode:
                newState.otpState.code = ""
                newState.otpState.codeErrorMessage = nil
                newState.otpState.isResending = true
            case .showResentToast:
                newState.otpState.isResending = false
            case .submitOtpData:
                newState.otpState.otpInputErrorMessage = nil
            default:
                break
            }
        case let .seBankIDStateAction(action):
            switch action {
            case .startSession:
                newState.seBankIDState.autoStartToken = nil
            case let .setAutoStartTokenWith(autoStartToken):
                newState.seBankIDState.autoStartToken = autoStartToken
            case let .setLiveQrCodeData(liveQrCodeData, date):
                if (newState.seBankIDState.liveQrCodeDate?.addingTimeInterval(2) ?? date) <= date {
                    newState.seBankIDState.liveQrCodeData = liveQrCodeData
                    newState.seBankIDState.liveQrCodeDate = date
                }
            }
        case .cancel:
            newState.seBankIDState = SEBankIDState()
            newState.loginHasFailed = false
        case .loginFailure:
            newState.seBankIDState = SEBankIDState()
            newState.loginHasFailed = true
        default:
            break
        }

        return newState
    }

    private func exchange(code: String) async throws -> AuthTokenResultSuccess {
        let data = try await self.networkAuthRepository.exchange(grant: AuthorizationCodeGrant(code: code))
        if let successResult = data as? AuthTokenResultSuccess {
            return successResult
        }
        let error = NSError(domain: "", code: 1000)
        throw error
    }
}
