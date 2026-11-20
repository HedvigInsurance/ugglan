import Environment
import Foundation
import PowerOfAttorneyCore
import hCore

/// Flow: `GET /power-of-attorney` lists the granted powers of attorney, `GET /power-of-attorney/received` the ones
/// granted to the member. `POST /power-of-attorney/{id}/revoke` revokes one. `POST /power-of-attorney` starts a BankID sign
/// order, then `POST {pollUrl}` is polled until the status is `COMPLETED` (with the power of attorney id) or `FAILED`.
extension NetworkClient: @retroactive PowerOfAttorneyClient {
    public func getPowerOfAttorneys() async throws -> [PowerOfAttorney] {
        let request = try await PowerOfAttorneyRequest.list.asRequest()
        let (data, response) = try await sessionClient.data(for: request)
        let granted: [GrantedPowerOfAttorneyResponse] = try await handleResponseForced(
            data: data,
            response: response,
            error: nil
        )
        return granted.compactMap { powerOfAttorney -> PowerOfAttorney? in
            // Revoked powers of attorney are still returned, but there's no revoked state to show
            guard powerOfAttorney.revokedAt == nil else { return nil }
            guard let level = PowerOfAttorneyLevel(rawValue: powerOfAttorney.level) else { return nil }
            return PowerOfAttorney(
                id: powerOfAttorney.id,
                name: powerOfAttorney.name,
                ssn: powerOfAttorney.ssn,
                level: level,
                shareUrl: powerOfAttorneyShareUrl(id: powerOfAttorney.id)
            )
        }
    }

    public func getReceivedPowerOfAttorneys() async throws -> [ReceivedPowerOfAttorney] {
        let request = try await PowerOfAttorneyRequest.received.asRequest()
        let (data, response) = try await sessionClient.data(for: request)
        let received: [ReceivedPowerOfAttorneyResponse] = try await handleResponseForced(
            data: data,
            response: response,
            error: nil
        )
        return received.compactMap { powerOfAttorney -> ReceivedPowerOfAttorney? in
            guard let level = PowerOfAttorneyLevel(rawValue: powerOfAttorney.level) else { return nil }
            return ReceivedPowerOfAttorney(
                id: powerOfAttorney.id,
                memberId: powerOfAttorney.memberId,
                name: powerOfAttorney.name,
                level: level,
                loginUrl: powerOfAttorneyShareUrl(id: powerOfAttorney.id)
            )
        }
    }

    public func revokePowerOfAttorney(id: String) async throws {
        let request = try await PowerOfAttorneyRequest.revoke(id: id).asRequest()
        let (_, response) = try await sessionClient.data(for: request)
        // Success has an empty body, so only the status code is checked
        guard let statusCode = (response as? HTTPURLResponse)?.statusCode, (200...299).contains(statusCode) else {
            throw PowerOfAttorneyError.error(message: L10n.General.errorBody)
        }
    }

    public func startSigning(
        for user: PowerOfAttorneyUser,
        level: PowerOfAttorneyLevel
    ) async throws -> PowerOfAttorneySigningSession {
        guard let personalNumber = user.ssn else {
            throw PowerOfAttorneyError.error(message: L10n.General.errorBody)
        }
        let request =
            try await PowerOfAttorneyRequest
            .start(personalNumber: personalNumber, name: user.fullName, level: level)
            .asRequest()
        let (data, response) = try await sessionClient.data(for: request)
        let startResponse: PowerOfAttorneyStartResponse = try await handleResponseForced(
            data: data,
            response: response,
            error: nil
        )
        guard startResponse.result == "success" else {
            throw PowerOfAttorneyError.error(message: startResponse.reason ?? L10n.General.errorBody)
        }
        guard
            let id = startResponse.id,
            let pollUrlString = startResponse.pollUrl,
            let pollUrl = URL(string: pollUrlString, relativeTo: Environment.current.authUrl)?.absoluteURL,
            let autoStartToken = startResponse.seBankIdProperties?.autoStartToken
        else {
            throw PowerOfAttorneyError.error(message: L10n.General.errorBody)
        }
        return .init(
            id: id,
            pollUrl: pollUrl,
            autoStartToken: autoStartToken,
            liveQrCodeData: startResponse.seBankIdProperties?.liveQrCodeData
        )
    }

    // A dropped connection recovers on the next poll, so only give up once it stops recovering: about ten
    // seconds, well inside the BankID order's ~3 minute lifetime.
    private static let maxConsecutiveNetworkFailures = 10

    public func observeSigningStatus(pollUrl: URL) -> AsyncThrowingStream<PowerOfAttorneySigningStatus, Error> {
        AsyncThrowingStream { continuation in
            let task = Task {
                do {
                    var consecutiveNetworkFailures = 0
                    while !Task.isCancelled {
                        let status: PowerOfAttorneySigningStatus
                        do {
                            status = try await pollSigningStatus(pollUrl: pollUrl)
                            consecutiveNetworkFailures = 0
                        } catch let error as URLError where error.isTransient {
                            // connection a few seconds later (-1005). The BankID order is alive for ~3 minutes and
                            // the member may be signing it right now, so keep polling instead of failing the signing.
                            consecutiveNetworkFailures += 1
                            guard consecutiveNetworkFailures <= Self.maxConsecutiveNetworkFailures else { throw error }
                            try await Task.sleep(for: .seconds(1))
                            continue
                        }
                        continuation.yield(status)
                        if case .pending = status {
                            // liveQrCodeData changes on every poll, so poll often enough to keep the QR code fresh
                            try await Task.sleep(for: .seconds(1))
                        } else {
                            break
                        }
                    }
                    continuation.finish()
                } catch {
                    continuation.finish(throwing: error)
                }
            }
            continuation.onTermination = { _ in
                task.cancel()
            }
        }
    }

    private func pollSigningStatus(pollUrl: URL) async throws -> PowerOfAttorneySigningStatus {
        let request = try await PowerOfAttorneyRequest.poll(url: pollUrl).asRequest()
        let (data, response) = try await sessionClient.data(for: request)
        if (response as? HTTPURLResponse)?.statusCode == 404 {
            // The BankID order lives for about 3 minutes, after that the poll url is gone
            throw PowerOfAttorneyError.signingExpired
        }
        let pollResponse: PowerOfAttorneyPollResponse = try await handleResponseForced(
            data: data,
            response: response,
            error: nil
        )
        switch pollResponse.status {
        case "COMPLETED":
            guard
                let id = pollResponse.powerOfAttorney?.id,
                let shareUrl = powerOfAttorneyShareUrl(id: id)
            else {
                throw PowerOfAttorneyError.error(message: L10n.General.errorBody)
            }
            return .success(shareUrl: shareUrl)
        case "FAILED":
            return .failed(message: pollResponse.statusText ?? L10n.General.errorBody)
        default:
            return .pending(
                qrCode: pollResponse.seBankIdProperties?.liveQrCodeData,
                statusText: pollResponse.statusText
            )
        }
    }

    /// The deep link the member shares with the person the power of attorney is granted to. Opening it starts the
    /// power of attorney login.
    private func powerOfAttorneyShareUrl(id: String) -> URL? {
        var components = URLComponents(
            url: Environment.current.deepLinkUrl.appending(path: "poa"),
            resolvingAgainstBaseURL: false
        )
        components?.queryItems = [URLQueryItem(name: "id", value: id)]
        return components?.url
    }
}

extension URLError {
    // Polling is a read, so these are safe to repeat. `.cancelled` is deliberately missing: it means the screen
    // was left, and retrying it would keep the loop alive after the task was cancelled.
    fileprivate var isTransient: Bool {
        switch code {
        case .networkConnectionLost, .notConnectedToInternet, .timedOut, .cannotConnectToHost, .cannotFindHost,
            .dnsLookupFailed:
            return true
        default:
            return false
        }
    }
}
