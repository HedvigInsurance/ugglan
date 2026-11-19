import Apollo
import AuthenticationCore
import Environment
import Foundation
@preconcurrency import HedvigShared
import KMPNativeCoroutinesAsync
import hCore
import hGraphQL

final class AuthenticationClientAuthLib: AuthenticationClient {
    private let networkClient = NetworkClient(sessionClient: .shared)
    private lazy var networkAuthRepository: NetworkAuthRepository = { [weak self] in
        NetworkAuthRepository(
            environment: Environment.current.authEnvironment,
            additionalHttpHeadersProvider: {
                var headers = self?.getHeaders() ?? [:]
                return headers
            }
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
        if BankIDSandboxState.isEnabled {
            headers["Hedvig-Bankid-Sandbox"] = "true"
        }
        return headers
    }

    func submit(otpState: OTPState) async throws -> String {
        if let verifyUrl = otpState.verifyUrl {
            do {
                try await Task.sleep(for: .seconds(0.5))
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
            try await Task.sleep(for: .seconds(0.5))
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

    func startSeBankId(
        powerOfAttorneyId: String?,
        updateStatusTo: @escaping (_: ObserveStatusResponseType) -> Void
    ) async throws {
        if let powerOfAttorneyId {
            try await startPowerOfAttorneyBankIdLogin(id: powerOfAttorneyId, updateStatusTo: updateStatusTo)
            return
        }
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
                try await observeLoginStatus(
                    statusUrl: properties.statusUrl.url,
                    isPowerOfAttorneyLogin: false,
                    updateStatusTo: updateStatusTo
                )
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

    /// Polls the BankID login status until it completes (then exchanges the authorization code) or fails.
    private func observeLoginStatus(
        statusUrl: String,
        isPowerOfAttorneyLogin: Bool,
        updateStatusTo: @escaping (_: ObserveStatusResponseType) -> Void
    ) async throws {
        let authUrl = Environment.current.authUrl
        let sequence = asyncSequence(
            for: networkAuthRepository.observeLoginStatus(statusUrl: .init(url: statusUrl))
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
                        "statusUrl": statusUrl,
                    ]
                )
                throw AuthenticationError.loginFailure(message: failed.localisedMessage)
            case _ as LoginStatusResultException:
                throw AuthenticationError.loginFailure(message: nil)
            case let completed as LoginStatusResultCompleted:
                try await exchange(
                    code: completed.authorizationCode.code,
                    keepingSavedSession: isPowerOfAttorneyLogin
                )
                if isPowerOfAttorneyLogin {
                    try await storePowerOfAttorney()
                }
                updateStatusTo(.completed)
                return
            case let pending as LoginStatusResultPending:
                updateStatusTo(.pending(qrCode: pending.bankIdProperties?.liveQrCodeData))
            default:
                throw AuthenticationError.loginFailure(message: nil)
            }
        }
    }

    /// Power of attorney login (flow 2): like a normal BankID login, but started with the id from the power of attorney
    /// link instead of a personal number. The auth library can't start it, so `POST /member-login` is done here; the
    /// status polling and the code exchange are the same as for a normal login.
    private func startPowerOfAttorneyBankIdLogin(
        id: String,
        updateStatusTo: @escaping (_: ObserveStatusResponseType) -> Void
    ) async throws {
        do {
            let request = try await PowerOfAttorneyRequest.memberLogin(powerOfAttorneyId: id).asRequest()
            let (data, response) = try await networkClient.sessionClient.data(for: request)
            let isSuccessStatus = (response as? HTTPURLResponse).map { (200..<300).contains($0.statusCode) } ?? false
            // An invalid link comes back as an error status with a `reason` explaining why
            if !isSuccessStatus,
                let reason = (try? JSONDecoder().decode(PowerOfAttorneyMemberLoginResponse.self, from: data))?.reason
            {
                throw AuthenticationError.loginFailure(message: reason)
            }
            let loginResponse: PowerOfAttorneyMemberLoginResponse = try await networkClient.handleResponseForced(
                data: data,
                response: response,
                error: nil
            )
            guard loginResponse.result == "success",
                let statusUrl = loginResponse.statusUrl,
                let autoStartToken = loginResponse.seBankIdProperties?.autoStartToken
            else {
                throw AuthenticationError.loginFailure(message: loginResponse.reason ?? L10n.General.errorBody)
            }
            updateStatusTo(.started(code: autoStartToken))
            try await observeLoginStatus(
                statusUrl: statusUrl,
                isPowerOfAttorneyLogin: true,
                updateStatusTo: updateStatusTo
            )
        } catch {
            log.error("Got Error when signing in with power of attorney", error: error, attributes: [:])
            if let error = error as? AuthenticationError {
                throw error
            }
            throw AuthenticationError.loginFailure(message: nil)
        }
    }

    func logout(keepingSavedSession: Bool) async throws {
        await KeychainHelper.standard.delete(key: Self.powerOfAttorneyKey)
        let savedSession = await readSavedSession()
        if !keepingSavedSession {
            await dropSavedSession()
        }
        guard let token = try? await ApolloClient.retreiveToken(),
            token.refreshToken != savedSession?.refreshToken
        else {
            return
        }
        try await revoke(refreshToken: token.refreshToken)
    }

    private func revoke(refreshToken: String) async throws {
        do {
            let data = try await asyncFunction(
                for: networkAuthRepository.revoke(token: refreshToken)
            )
            switch data {
            case _ as RevokeResultSuccess:
                return
            default:
                throw AuthenticationError.logoutFailure
            }
        } catch {
            throw AuthenticationError.logoutFailure
        }
    }

    // MARK: - Switching back from a power of attorney session

    /// The member's own session, kept while they use the app with a power of attorney
    private static let savedSessionKey = "savedMemberSession"

    func saveSessionForSwitchBack() async {
        guard await getPowerOfAttorney() == nil, let token = try? await ApolloClient.retreiveToken() else { return }
        KeychainHelper.standard.save(token, key: Self.savedSessionKey)
    }

    func hasSavedSession() async -> Bool {
        await readSavedSession() != nil
    }

    func restoreSavedSession() async -> Bool {
        guard let savedSession = await readSavedSession() else { return false }
        let powerOfAttorneyToken = try? await ApolloClient.retreiveToken()
        await KeychainHelper.standard.delete(key: Self.powerOfAttorneyKey)
        await KeychainHelper.standard.delete(key: Self.savedSessionKey)
        // An expired access token is refreshed with the saved refresh token on the first request
        ApolloClient.saveToken(token: savedSession)
        if let powerOfAttorneyToken, powerOfAttorneyToken.refreshToken != savedSession.refreshToken {
            try? await revoke(refreshToken: powerOfAttorneyToken.refreshToken)
        }
        return true
    }

    /// The saved session, `nil` when there's none or its refresh token has expired.
    private func readSavedSession() async -> OAuthorizationToken? {
        guard
            let token = try? await KeychainHelper.standard.read(
                key: Self.savedSessionKey,
                type: OAuthorizationToken.self
            ),
            token.refreshTokenExpirationDate > Date()
        else {
            return nil
        }
        return token
    }

    /// Deletes the saved session and revokes it, so it can't be returned to.
    private func dropSavedSession() async {
        guard let savedSession = await readSavedSession() else { return }
        await KeychainHelper.standard.delete(key: Self.savedSessionKey)
        try? await revoke(refreshToken: savedSession.refreshToken)
    }

    private static let powerOfAttorneyKey = "powerOfAttorney"

    func getPowerOfAttorney() async -> ActingPowerOfAttorney? {
        try? await KeychainHelper.standard.read(key: Self.powerOfAttorneyKey, type: ActingPowerOfAttorney.self)
    }

    /// Right after a power of attorney login: stores who logged in. If it can't be fetched the login fails (and its
    /// tokens are dropped), so the app never opens without knowing what the person may see.
    private func storePowerOfAttorney() async throws {
        do {
            guard let powerOfAttorney = try await fetchCurrentPowerOfAttorney() else {
                throw URLError(.badServerResponse)
            }
            KeychainHelper.standard.save(powerOfAttorney, key: Self.powerOfAttorneyKey)
        } catch {
            log.error("Got Error when fetching the power of attorney after login", error: error, attributes: [:])
            try? await logout(keepingSavedSession: true)
            await ApolloClient.deleteToken()
            throw AuthenticationError.loginFailure(message: L10n.General.defaultError)
        }
    }

    /// The power of attorney the caller is logged in with, `nil` for a member logged in as themselves (404).
    private func fetchCurrentPowerOfAttorney() async throws -> ActingPowerOfAttorney? {
        let request = try await PowerOfAttorneyRequest.current.asRequest()
        let (data, response) = try await networkClient.sessionClient.data(for: request)
        if (response as? HTTPURLResponse)?.statusCode == 404 {
            return nil
        }
        let current: ActingPowerOfAttorney = try await networkClient.handleResponseForced(
            data: data,
            response: response,
            error: nil
        )
        return current
    }

    func exchange(code: String) async throws {
        try await exchange(code: code, keepingSavedSession: false)
    }

    /// Only a power of attorney login keeps the member's saved session; logging in any other way means it's no
    /// longer theirs to switch back to.
    private func exchange(code: String, keepingSavedSession: Bool) async throws {
        // Every login exchanges a code. A power of attorney login stores its own afterwards, so whatever an earlier
        // one stored never leaks into this session (e.g. an email login after a logout that didn't finish).
        await KeychainHelper.standard.delete(key: Self.powerOfAttorneyKey)
        if !keepingSavedSession {
            await dropSavedSession()
        }
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
            let accessTokenDto: AuthorizationTokenDto = .init(
                accessToken: success.accessToken.token,
                accessTokenExpiryIn: Int(success.accessToken.expiryInSeconds),
                refreshToken: success.refreshToken.token,
                refreshTokenExpiryIn: Int(success.refreshToken.expiryInSeconds)
            )
            ApolloClient.handleAuthTokenSuccessResult(result: accessTokenDto)
        case let error as AuthTokenResultError:
            switch error {
            case _ as AuthTokenResultErrorIOError:
                // A network failure is retried on the next request, it does not log the member out.
                log.info("Refreshing token postponed, network unavailable: \(error.errorMessage)")
                throw AuthError.networkIssue
            default:
                log.error("Refreshing failed \(error.errorMessage), forcing logout")
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
