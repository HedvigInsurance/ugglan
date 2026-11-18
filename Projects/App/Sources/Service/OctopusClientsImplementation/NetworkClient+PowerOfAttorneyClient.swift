import Apollo
import ContractsCore
import EditStakeholdersCore
import Environment
import Foundation
import PowerOfAttorney
import hCore
import hGraphQL

/// Power of attorney is served by the auth service over plain HTTPS (not GraphQL).
/// Flow: `GET /power-of-attorney` lists the granted powers of attorney. `POST /power-of-attorney` starts a BankID sign
/// order, then `POST {pollUrl}` is polled until the status is `COMPLETED` (with the power of attorney id) or `FAILED`.
extension NetworkClient: @retroactive PowerOfAttorneyClient {
    public func getPowerOfAttorneys() async throws -> [PowerOfAttorney] {
        let request = try await PowerOfAttorneyRequest.list.asRequest()
        let (data, response) = try await sessionClient.data(for: request)
        let granted: [GrantedPowerOfAttorney] = try await handleResponseForced(
            data: data,
            response: response,
            error: nil
        )
        return granted.compactMap { powerOfAttorney -> PowerOfAttorney? in
            guard let level = PowerOfAttorney.Level(rawValue: powerOfAttorney.level) else { return nil }
            return PowerOfAttorney(
                id: powerOfAttorney.id,
                name: powerOfAttorney.name,
                ssn: powerOfAttorney.ssn,
                // TODO: Use the real status once the backend supports expiry/revocation, every signed one is active
                status: .active,
                level: level,
                shareUrl: powerOfAttorneyShareUrl(id: powerOfAttorney.id)
            )
        }
    }

    /// Co-insured on the member's active contracts that have a personal number (needed to grant a power of attorney).
    public func getCoInsured() async throws -> [PowerOfAttorneyUser] {
        let contractsClient: FetchContractsClient = Dependencies.shared.resolve()
        let contracts = try await contractsClient.getContracts()
        var seenPersonalNumbers = Set<String>()
        let coInsured = contracts.activeContracts
            .flatMap(\.coInsured)
            .compactMap { coInsured -> PowerOfAttorneyUser? in
                guard
                    let firstName = coInsured.firstName,
                    let lastName = coInsured.lastName,
                    let personalNumber = coInsured.formattedSSN,
                    !personalNumber.isEmpty,
                    seenPersonalNumbers.insert(personalNumber).inserted
                else { return nil }
                return PowerOfAttorneyUser(
                    id: personalNumber,
                    firstName: firstName,
                    lastName: lastName,
                    ssn: personalNumber
                )
            }
        return coInsured
    }

    /// Same personal number lookup as when adding a co-insured.
    public func getUser(personalNumber: String) async throws -> PowerOfAttorneyUser {
        let editStakeholdersClient: EditStakeholdersClient = Dependencies.shared.resolve()
        guard let personalData = try await editStakeholdersClient.fetchPersonalInformation(SSN: personalNumber) else {
            throw PowerOfAttorneyError.error(message: L10n.General.errorBody)
        }
        return PowerOfAttorneyUser(
            id: personalNumber,
            firstName: personalData.firstName,
            lastName: personalData.lastName,
            ssn: personalNumber
        )
    }

    public func startSigning(
        for user: PowerOfAttorneyUser,
        level: PowerOfAttorney.Level
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

    public func observeSigningStatus(pollUrl: URL) -> AsyncThrowingStream<PowerOfAttorneySigningStatus, Error> {
        AsyncThrowingStream { continuation in
            let task = Task {
                do {
                    while !Task.isCancelled {
                        let status = try await pollSigningStatus(pollUrl: pollUrl)
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

    /// The deep link the member shares with the person the power of attorney is granted to.
    private func powerOfAttorneyShareUrl(id: String) -> URL? {
        var components = URLComponents(
            url: Environment.current.deepLinkUrl.appending(path: "poa"),
            resolvingAgainstBaseURL: false
        )
        components?.queryItems = [URLQueryItem(name: "id", value: id)]
        return components?.url
    }
}

private enum PowerOfAttorneyRequest {
    case list
    case start(personalNumber: String, name: String, level: PowerOfAttorney.Level)
    case poll(url: URL)

    func asRequest() async throws -> URLRequest {
        var request: URLRequest
        switch self {
        case .list:
            request = URLRequest(url: Environment.current.authUrl.appending(path: "power-of-attorney"))
            request.httpMethod = "GET"
        case let .start(personalNumber, name, level):
            request = URLRequest(url: Environment.current.authUrl.appending(path: "power-of-attorney"))
            request.httpMethod = "POST"
            request.httpBody = try JSONEncoder()
                .encode(PowerOfAttorneyStartBody(personalNumber: personalNumber, name: name, level: level.rawValue))
        case let .poll(url):
            // Unlike the login status call (GET), this poll is a POST
            request = URLRequest(url: url)
            request.httpMethod = "POST"
        }
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        try await TokenRefresher.shared.refreshIfNeeded()
        let headers = await ApolloClient.headers()
        for element in headers {
            request.setValue(element.value, forHTTPHeaderField: element.key)
        }
        return request
    }
}

private struct PowerOfAttorneyStartBody: Encodable {
    let personalNumber: String
    let name: String
    let level: String
}

private struct GrantedPowerOfAttorney: Decodable, Sendable {
    let id: String
    let name: String
    let ssn: String
    let level: String
}

private struct PowerOfAttorneyBankIdProperties: Decodable, Sendable {
    let autoStartToken: String?
    let liveQrCodeData: String?
    let bankidAppOpened: Bool?
}

private struct PowerOfAttorneyStartResponse: Decodable, Sendable {
    let result: String
    let id: String?
    let pollUrl: String?
    let seBankIdProperties: PowerOfAttorneyBankIdProperties?
    let reason: String?
}

private struct PowerOfAttorneyPollResponse: Decodable, Sendable {
    let status: String
    let statusText: String?
    let seBankIdProperties: PowerOfAttorneyBankIdProperties?
    let powerOfAttorney: PowerOfAttorneyResult?

    struct PowerOfAttorneyResult: Decodable, Sendable {
        let id: String
    }
}
