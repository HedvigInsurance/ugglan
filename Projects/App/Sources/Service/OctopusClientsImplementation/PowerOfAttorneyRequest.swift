import Apollo
import Environment
import Foundation
import hCore
import hGraphQL

/// Power of attorney is served by the auth service over plain HTTPS (not GraphQL).
enum PowerOfAttorneyRequest {
    /// `GET /power-of-attorney`: the powers of attorney the member has granted.
    case list
    /// `GET /power-of-attorney/received`: the powers of attorney other members have granted to the member.
    case received
    /// `POST /power-of-attorney`: starts a BankID sign order for a new power of attorney.
    case start(personalNumber: String, name: String, level: PowerOfAttorneyLevel)
    /// `POST {pollUrl}`: the sign order's status. Unlike the login status call (GET), this poll is a POST.
    case poll(url: URL)
    /// `POST /member-login`: starts a BankID login with the id from a power of attorney link. Sent logged out.
    case memberLogin(powerOfAttorneyId: String)
    /// `GET /power-of-attorney/current`: the power of attorney the caller is logged in with. 404 for the member.
    case current

    func asRequest() async throws -> URLRequest {
        let authUrl = Environment.current.authUrl
        var request: URLRequest
        switch self {
        case .list:
            request = URLRequest(url: authUrl.appending(path: "power-of-attorney"))
            request.httpMethod = "GET"
        case .received:
            request = URLRequest(url: authUrl.appending(path: "power-of-attorney/received"))
            request.httpMethod = "GET"
        case let .start(personalNumber, name, level):
            request = URLRequest(url: authUrl.appending(path: "power-of-attorney"))
            request.httpMethod = "POST"
            request.httpBody = try JSONEncoder()
                .encode(StartBody(personalNumber: personalNumber, name: name, level: level.rawValue))
        case let .poll(url):
            request = URLRequest(url: url)
            request.httpMethod = "POST"
        case let .memberLogin(powerOfAttorneyId):
            request = URLRequest(url: authUrl.appending(path: "member-login"))
            request.httpMethod = "POST"
            request.httpBody = try JSONEncoder()
                .encode(MemberLoginBody(method: "SE_BANKID", powerOfAttorneyId: powerOfAttorneyId))
            if BankIDSandboxState.isEnabled {
                request.setValue("true", forHTTPHeaderField: "Hedvig-Bankid-Sandbox")
            }
        case .current:
            request = URLRequest(url: authUrl.appending(path: "power-of-attorney/current"))
            request.httpMethod = "GET"
        }
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        if requiresAuthorization {
            try await TokenRefresher.shared.refreshIfNeeded()
        }
        for (key, value) in await ApolloClient.headers() {
            request.setValue(value, forHTTPHeaderField: key)
        }
        return request
    }

    private var requiresAuthorization: Bool {
        switch self {
        case .memberLogin: false
        case .list, .received, .start, .poll, .current: true
        }
    }
}

// MARK: - Request bodies

private struct StartBody: Encodable {
    let personalNumber: String
    let name: String
    let level: String
}

private struct MemberLoginBody: Encodable {
    let method: String
    let powerOfAttorneyId: String
}

// MARK: - Responses

struct PowerOfAttorneyBankIdProperties: Decodable, Sendable {
    let autoStartToken: String?
    let liveQrCodeData: String?
}

struct GrantedPowerOfAttorneyResponse: Decodable, Sendable {
    let id: String
    let name: String
    let ssn: String
    let level: String
}

struct ReceivedPowerOfAttorneyResponse: Decodable, Sendable {
    let id: String
    /// The member who granted the power of attorney.
    let memberId: String
    let name: String
    let level: String
}

struct PowerOfAttorneyStartResponse: Decodable, Sendable {
    let result: String
    let id: String?
    let pollUrl: String?
    let seBankIdProperties: PowerOfAttorneyBankIdProperties?
    let reason: String?
}

struct PowerOfAttorneyPollResponse: Decodable, Sendable {
    let status: String
    let statusText: String?
    let seBankIdProperties: PowerOfAttorneyBankIdProperties?
    let powerOfAttorney: PowerOfAttorneyResult?

    struct PowerOfAttorneyResult: Decodable, Sendable {
        let id: String
    }
}

struct PowerOfAttorneyMemberLoginResponse: Decodable, Sendable {
    let result: String
    let statusUrl: String?
    let seBankIdProperties: PowerOfAttorneyBankIdProperties?
    let reason: String?
}
