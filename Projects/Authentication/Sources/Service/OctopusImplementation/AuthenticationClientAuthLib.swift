import Apollo
import Foundation
@preconcurrency import authlib
import hCore
import hGraphQL

@MainActor
public class AuthenticationService {
    @Inject var client: AuthenticationClient

    public init() {}

    func submit(otpState: OTPState) async throws -> String {
        log.info("AuthenticationService: submit", error: nil, attributes: nil)
        return try await client.submit(otpState: otpState)
    }

    func start(with otpState: OTPState) async throws -> (verifyUrl: URL, resendUrl: URL, maskedEmail: String?) {
        log.info("AuthenticationService: start", error: nil, attributes: nil)
        return try await client.start(with: otpState)
    }

    func resend(otp otpState: OTPState) async throws {
        log.info("AuthenticationService: resend", error: nil, attributes: nil)
        try await client.resend(otp: otpState)
    }

    func startSeBankId(updateStatusTo: @escaping (_: ObserveStatusResponseType) -> Void) async throws {
        log.info("AuthenticationService: startSeBankId", error: nil, attributes: nil)
        return try await client.startSeBankId(updateStatusTo: updateStatusTo)
    }

    public func logout() async throws {
        log.info("AuthenticationService: logout", error: nil, attributes: nil)
        try await client.logout()
    }

    public func exchange(code: String) async throws {
        log.info("AuthenticationService: exchange code", error: nil, attributes: nil)
        try await client.exchange(code: code)
    }

    public func exchange(refreshToken: String) async throws {
        log.info("AuthenticationService: exchange refresh token", error: nil, attributes: nil)
        try await client.exchange(refreshToken: refreshToken)
    }

    public static var logAuthResourceStart: ((_ key: String, _ URL: URL) -> Void) = { _, _ in }
    public static var logAuthResourceStop: ((_ key: String, _ response: URLResponse) -> Void) = { _, _ in }
}

final public class AuthenticationClientAuthLib: AuthenticationClient {
    public init() {}

    @MainActor
    private var networkAuthRepository: NetworkAuthRepository = {
        NetworkAuthRepository(
            environment: Environment.current.authEnvironment,
            additionalHttpHeadersProvider: {
                var headers = [String: String]()
                let semaphore = DispatchSemaphore(value: 0)
                Task {
                    headers = await ApolloClient.headers()
                    semaphore.signal()
                }
                semaphore.wait()
                return headers
            },
            httpClientEngine: nil
        )
    }()

    public func submit(otpState: OTPState) async throws -> String {
        if let verifyUrl = otpState.verifyUrl {
            do {
                try await Task.sleep(nanoseconds: 5 * 100_000_000)
                let data = try await networkAuthRepository.submitOtp(
                    verifyUrl: verifyUrl.absoluteString,
                    otp: otpState.code
                )
                if let data = data as? SubmitOtpResultSuccess {
                    return data.loginAuthorizationCode.code
                } else {
                    throw AuthentificationError.codeError
                }
            } catch {
                throw AuthentificationError.codeError
            }
        }
        throw AuthentificationError.codeError

    }

    public func start(with otpState: OTPState) async throws -> (verifyUrl: URL, resendUrl: URL, maskedEmail: String?) {
        let personalNumber: String? = {
            switch Localization.Locale.currentLocale.value.market {
            case .no, .dk:
                return otpState.input.replacingOccurrences(of: "-", with: "")
            case .se:
                return nil
            }
        }()

        let email: String? = {
            switch Localization.Locale.currentLocale.value.market {
            case .no, .dk:
                return nil
            case .se:
                return otpState.input
            }
        }()
        do {
            let data = try await self.networkAuthRepository.startLoginAttempt(
                loginMethod: .otp,
                market: Localization.Locale.currentLocale.value.market.asOtpMarket,
                personalNumber: personalNumber,
                email: email
            )
            try await Task.sleep(nanoseconds: 5 * 100_000_000)
            if let otpProperties = data as? AuthAttemptResultOtpProperties,
                let verifyUrl = URL(string: otpProperties.verifyUrl),
                let resendUrl = URL(string: otpProperties.resendUrl)
            {
                return (verifyUrl, resendUrl, otpProperties.maskedEmail)
            } else {
                throw AuthentificationError.otpInputError
            }
        } catch {
            throw AuthentificationError.otpInputError
        }
    }

    public func resend(otp otpState: OTPState) async throws {
        if let resendUrl = otpState.resendUrl {
            _ = try await self.networkAuthRepository.resendOtp(resendUrl: resendUrl.absoluteString)
        } else {
            throw AuthentificationError.resendOtpFailed
        }
    }

    public func startSeBankId(updateStatusTo: @escaping (_: ObserveStatusResponseType) -> Void) async throws {
        do {
            let authUrl = Environment.current.authUrl
            AuthenticationService.logAuthResourceStart(authUrl.absoluteString, authUrl)
            let data = try await self.networkAuthRepository.startLoginAttempt(
                loginMethod: .seBankid,
                market: Localization.Locale.currentLocale.value.market.asOtpMarket,
                personalNumber: nil,
                email: nil
            )
            AuthenticationService.logAuthResourceStop(
                authUrl.absoluteString,
                HTTPURLResponse(url: authUrl, statusCode: 200, httpVersion: nil, headerFields: [:])!
            )

            switch onEnum(of: data) {
            case let .bankIdProperties(data):
                updateStatusTo(.started(code: data.autoStartToken))
                for await status in self.networkAuthRepository.observeLoginStatus(
                    statusUrl: .init(url: data.statusUrl.url)
                ) {
                    let key = UUID().uuidString
                    AuthenticationService.logAuthResourceStart(key, authUrl)

                    AuthenticationService.logAuthResourceStop(
                        key,
                        HTTPURLResponse(url: authUrl, statusCode: 200, httpVersion: nil, headerFields: [:])!
                    )

                    switch onEnum(of: status) {
                    case .failed(let failed):
                        let message = failed.localisedMessage
                        log.error(
                            "LOGIN FAILED",
                            error: NSError(domain: message, code: 1000),
                            attributes: [
                                "message": message,
                                "statusUrl": data.statusUrl.url,
                            ]
                        )
                        throw AuthentificationError.loginFailure(message: failed.localisedMessage)
                    case .exception:
                        throw AuthentificationError.loginFailure(message: nil)
                    case let .completed(completed):
                        log.info(
                            "LOGIN AUTH FINISHED"
                        )
                        try await exchange(code: completed.authorizationCode.code)
                        updateStatusTo(.completed)
                        return
                    case .pending(let pending):
                        updateStatusTo(.pending(qrCode: pending.bankIdProperties?.liveQrCodeData))
                    }
                }
            case let .error(error):
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
                throw AuthentificationError.loginFailure(message: localizedMessage)
            case .otpProperties:
                break
            }
        } catch let error {
            log.error(
                "Got Error when signing in with BankId",
                error: error,
                attributes: [:]
            )
            if let error = error as? AuthentificationError {
                throw error
            }
            throw AuthentificationError.loginFailure(message: nil)
        }
    }

    public func logout() async throws {
        do {
            if let token = try await ApolloClient.retreiveToken() {
                let data = try await self.networkAuthRepository.revoke(token: token.refreshToken)
                switch onEnum(of: data) {
                case .error:
                    throw AuthentificationError.logoutFailure
                case .success:
                    return
                }
            } else {
                return
            }
        } catch {
            throw AuthentificationError.logoutFailure
        }
    }

    public func exchange(code: String) async throws {
        let data = try await self.networkAuthRepository.exchange(grant: AuthorizationCodeGrant(code: code))
        if let successResult = data as? AuthTokenResultSuccess {
            let tokenData = AuthorizationTokenDto.init(
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

    public func exchange(refreshToken: String) async throws {
        let data = try await self.networkAuthRepository.exchange(grant: RefreshTokenGrant(code: refreshToken))
        switch onEnum(of: data) {
        case .success(let success):
            log.info("Refresh was sucessfull")
            let accessTokenDto: AuthorizationTokenDto = .init(
                accessToken: success.accessToken.token,
                accessTokenExpiryIn: Int(success.accessToken.expiryInSeconds),
                refreshToken: success.refreshToken.token,
                refreshTokenExpiryIn: Int(success.refreshToken.expiryInSeconds)
            )
            ApolloClient.handleAuthTokenSuccessResult(result: accessTokenDto)
        case .error(let error):
            log.error("Refreshing failed \(error.errorMessage), forcing logout")
            switch onEnum(of: error) {
            case .iOError:
                throw AuthError.networkIssue
            case .backendErrorResponse, .unknownError:
                throw AuthError.refreshFailed
            }
        }
    }
}

public enum ObserveStatusResponseType {
    case started(code: String)
    case pending(qrCode: String?)
    case completed
}

enum AuthentificationError: Error {
    case codeError
    case otpInputError
    case resendOtpFailed
    case loginFailure(message: String?)
    case logoutFailure
}

extension hGraphQL.Environment {
    fileprivate var authEnvironment: AuthEnvironment {
        switch self {
        case .staging: return .staging
        case .production: return .production
        case .custom(_, _, _, _): return .staging
        }
    }
}

extension Localization.Locale.Market {
    fileprivate var asOtpMarket: OtpMarket {
        switch self {
        case .no: return .no
        case .se: return .se
        case .dk: return .dk
        }
    }
}

extension AuthentificationError: LocalizedError {
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

extension authlib.AuthTokenResultError {
    public var errorMessage: String {
        switch onEnum(of: self) {
        case .backendErrorResponse(let error): return error.message
        case .iOError(let ioError): return ioError.message
        case .unknownError(let unknownError): return unknownError.message
        }
    }
}
