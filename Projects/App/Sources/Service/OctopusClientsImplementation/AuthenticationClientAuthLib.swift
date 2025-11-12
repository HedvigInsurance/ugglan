import Apollo
import Authentication
import Environment
import Foundation
@preconcurrency import HedvigShared
import KMPNativeCoroutinesAsync
import hCore
import hGraphQL

final class AuthenticationClientAuthLib: AuthenticationClient {
    private lazy var networkAuthRepository: NetworkAuthRepository = { [weak self] in
        return NetworkAuthRepository(
            environment: Environment.current.authEnvironment,
            additionalHttpHeadersProvider: {
                var headers = self?.getHeaders() ?? [:]
                return headers
            },
            httpClientEngine: nil
        )
    }()

    private func getHeaders() -> [String: String] {
        var headers = [String: String]()
        let semaphore = DispatchSemaphore(value: 0)
        Task {
            headers = await ApolloClient.headers()
            semaphore.signal()
        }
        semaphore.wait()
        return headers
    }

    func submit(otpState: OTPState) async throws -> String {
        if let verifyUrl = otpState.verifyUrl {
            do {
                try await Task.sleep(seconds: 0.5)
                let data = try await asyncFunction(
                    for: networkAuthRepository.submitOtp(
                        verifyUrl: verifyUrl.absoluteString,
                        otp: otpState.code
                    )
                )
                if let data = data as? SubmitOtpResultSuccess {
                    return data.loginAuthorizationCode.code
                } else {
                    throw AuthenticationError.codeError
                }
            } catch {
                throw AuthenticationError.codeError
            }
        }
        throw AuthenticationError.codeError
    }

    func start(with otpState: OTPState) async throws -> (verifyUrl: URL, resendUrl: URL, maskedEmail: String?) {
        let personalNumber: String? = nil

        let email: String? = otpState.input
        do {
            let data = try await asyncFunction(
                for: networkAuthRepository.startLoginAttempt(
                    loginMethod: .otp,
                    market: .se,
                    personalNumber: personalNumber,
                    email: email
                )
            )
            try await Task.sleep(seconds: 0.5)
            if let otpProperties = data as? AuthAttemptResultOtpProperties,
                let verifyUrl = URL(string: otpProperties.verifyUrl),
                let resendUrl = URL(string: otpProperties.resendUrl)
            {
                return (verifyUrl, resendUrl, otpProperties.maskedEmail)
            } else {
                throw AuthenticationError.otpInputError
            }
        } catch {
            throw AuthenticationError.otpInputError
        }
    }

    func resend(otp otpState: OTPState) async throws {
        if let resendUrl = otpState.resendUrl {
            _ = try await asyncFunction(
                for: networkAuthRepository.resendOtp(resendUrl: resendUrl.absoluteString)
            )
        } else {
            throw AuthenticationError.resendOtpFailed
        }
    }

    func startSeBankId(updateStatusTo: @escaping (_: ObserveStatusResponseType) -> Void) async throws {
        do {
            let authUrl = Environment.current.authUrl
            AuthenticationService.logAuthResourceStart(authUrl.absoluteString, authUrl)
            let data = try await asyncFunction(
                for: networkAuthRepository.startLoginAttempt(
                    loginMethod: .seBankid,
                    market: .se,
                    personalNumber: nil,
                    email: nil
                )
            )

            AuthenticationService.logAuthResourceStop(
                authUrl.absoluteString,
                HTTPURLResponse(url: authUrl, statusCode: 200, httpVersion: nil, headerFields: [:])!
            )

            switch data {
            case let properties as AuthAttemptResultBankIdProperties:
                updateStatusTo(.started(code: properties.autoStartToken))
                let sequence = asyncSequence(
                    for: networkAuthRepository.observeLoginStatus(statusUrl: .init(url: properties.statusUrl.url))
                )
                for try await status in sequence {
                    let key = UUID().uuidString
                    AuthenticationService.logAuthResourceStart(key, authUrl)

                    AuthenticationService.logAuthResourceStop(
                        key,
                        HTTPURLResponse(url: authUrl, statusCode: 200, httpVersion: nil, headerFields: [:])!
                    )

                    switch status {
                    case let failed as LoginStatusResultFailed:
                        let message = failed.localisedMessage
                        log.error(
                            "LOGIN FAILED",
                            error: NSError(domain: message, code: 1000),
                            attributes: [
                                "message": message,
                                "statusUrl": properties.statusUrl.url,
                            ]
                        )
                        throw AuthenticationError.loginFailure(message: failed.localisedMessage)
                    case _ as LoginStatusResultException:
                        throw AuthenticationError.loginFailure(message: nil)
                    case let completed as LoginStatusResultCompleted:
                        log.info(
                            "LOGIN AUTH FINISHED"
                        )
                        try await exchange(code: completed.authorizationCode.code)
                        updateStatusTo(.completed)
                        return
                    case let pending as LoginStatusResultPending:
                        updateStatusTo(.pending(qrCode: pending.bankIdProperties?.liveQrCodeData))
                    default:
                        throw AuthenticationError.loginFailure(message: nil)
                    }
                }
            case let error as AuthAttemptResultError:
                var localizedMessage = L10n.General.errorBody
                var logMessage = "Got Error when signing in with BankId"
                if let result = error as? AuthAttemptResultErrorLocalised {
                    localizedMessage = result.reason
                    logMessage =
                        "Got AuthAttemptResultErrorLocalised when signing in with BankId. Reason:\(result.reason)."
                } else if let result = error as? AuthAttemptResultErrorBackendErrorResponse {
                    logMessage =
                        "Got AuthAttemptResultErrorBackendErrorResponse when signing in with BankId. Message:\(result.message)"
                } else if let result = error as? AuthAttemptResultErrorIOError {
                    logMessage =
                        "Got AuthAttemptResultErrorIOError when signing in with BankId. Message:\(result.message)"
                } else if let result = error as? AuthAttemptResultErrorUnknownError {
                    logMessage =
                        "Got AuthAttemptResultErrorIOError when signing in with BankId. Message:\(result.message)"
                }
                let error = NSError(domain: logMessage, code: 1000)
                log.error(
                    logMessage,
                    error: error,
                    attributes: [:]
                )
                throw AuthenticationError.loginFailure(message: localizedMessage)
            case _ as AuthAttemptResultOtpProperties:
                break
            default:
                break
            }
        } catch {
            log.error(
                "Got Error when signing in with BankId",
                error: error,
                attributes: [:]
            )
            if let error = error as? AuthenticationError {
                throw error
            }
            throw AuthenticationError.loginFailure(message: nil)
        }
    }

    func logout() async throws {
        do {
            if let token = try await ApolloClient.retreiveToken() {
                let data = try await asyncFunction(
                    for: networkAuthRepository.revoke(token: token.refreshToken)
                )
                switch data {
                case _ as RevokeResultError:
                    throw AuthenticationError.logoutFailure
                case _ as RevokeResultSuccess:
                    return
                default:
                    throw AuthenticationError.logoutFailure
                }
            } else {
                return
            }
        } catch {
            throw AuthenticationError.logoutFailure
        }
    }

    func exchange(code: String) async throws {
        let data = try await asyncFunction(
            for: networkAuthRepository.exchange(grant: AuthorizationCodeGrant(code: code))
        )
        if let successResult = data as? AuthTokenResultSuccess {
            let tokenData = AuthorizationTokenDto(
                accessToken: successResult.accessToken.token,
                accessTokenExpiryIn: Int(successResult.accessToken.expiryInSeconds),
                refreshToken: successResult.refreshToken.token,
                refreshTokenExpiryIn: Int(successResult.refreshToken.expiryInSeconds)
            )
            ApolloClient.handleAuthTokenSuccessResult(result: tokenData)
            return
        }
        let error = NSError(domain: "", code: 1000)
        throw error
    }

    func exchange(refreshToken: String) async throws {
        let data = try await asyncFunction(
            for: networkAuthRepository.exchange(grant: RefreshTokenGrant(code: refreshToken))
        )
        switch data {
        case let success as AuthTokenResultSuccess:
            log.info("Refresh was sucessfull")
            let accessTokenDto: AuthorizationTokenDto = .init(
                accessToken: success.accessToken.token,
                accessTokenExpiryIn: Int(success.accessToken.expiryInSeconds),
                refreshToken: success.refreshToken.token,
                refreshTokenExpiryIn: Int(success.refreshToken.expiryInSeconds)
            )
            ApolloClient.handleAuthTokenSuccessResult(result: accessTokenDto)
        case let error as AuthTokenResultError:
            log.error("Refreshing failed \(error.errorMessage), forcing logout")
            switch error {
            case _ as AuthTokenResultErrorIOError:
                throw AuthError.networkIssue
            case _ as AuthTokenResultErrorBackendErrorResponse:
                throw AuthError.refreshFailed
            case _ as AuthTokenResultErrorUnknownError:
                throw AuthError.refreshFailed
            default:
                throw AuthError.refreshFailed
            }
        default:
            throw AuthError.refreshFailed
        }
    }
}

enum AuthenticationError: Error {
    case codeError
    case otpInputError
    case resendOtpFailed
    case loginFailure(message: String?)
    case logoutFailure
}

extension Environment {
    fileprivate var authEnvironment: AuthEnvironment {
        switch self {
        case .staging: return .staging
        case .production: return .production
        case .custom: return .staging
        }
    }
}

extension AuthenticationError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .codeError: return L10n.Login.CodeInput.ErrorMsg.codeNotValid
        case .otpInputError: return L10n.Login.TextInput.emailErrorNotValid
        case .resendOtpFailed: return nil
        case let .loginFailure(message): return message
        case .logoutFailure: return nil
        }
    }
}

extension HedvigShared.AuthTokenResultError {
    var errorMessage: String {
        switch self {
        case let error as AuthTokenResultErrorBackendErrorResponse: return error.message
        case let ioError as AuthTokenResultErrorIOError: return ioError.message
        case let unknownError as AuthTokenResultErrorUnknownError: return unknownError.message
        default: return "Unknown error"
        }
    }
}
