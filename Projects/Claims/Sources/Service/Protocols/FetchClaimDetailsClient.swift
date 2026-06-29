import AutomaticLog
import Foundation
import hCore

@MainActor
public class FetchClaimDetailsService {
    @Inject var client: hFetchClaimDetailsClient
    let id: String

    public init(id: String) {
        self.id = id
    }

    @Log
    public func get() async throws -> ClaimModel {
        try await client.get(for: id)
    }

    @Log
    public func getPartnerClaim() async throws -> ClaimModel {
        try await client.getPartnerClaim(for: id)
    }

    public func getWithPartnerFallback() async throws -> ClaimModel {
        do {
            return try await client.get(for: id)
        } catch FetchClaimDetailsError.noClaimFound {
            return try await client.getPartnerClaim(for: id)
        }
    }

    @Log
    public func getFiles() async throws -> [File] {
        try await client.getFiles(for: id)
    }

    @Log
    public func acknowledgeClosedStatus(for id: String) async throws {
        try await client.acknowledgeClosedStatus(for: id)
    }
}

@MainActor
public protocol hFetchClaimDetailsClient {
    func get(for id: String) async throws -> ClaimModel
    func getPartnerClaim(for id: String) async throws -> ClaimModel
    func getFiles(for id: String) async throws -> [File]
    func acknowledgeClosedStatus(for id: String) async throws
}

public enum ClaimDetailsType {
    case claim(id: String)
    case conversation(claimId: String)
    case partnerClaim(id: String)

    var claimId: String {
        switch self {
        case let .claim(id):
            return id
        case let .conversation(claimId):
            return claimId
        case let .partnerClaim(id):
            return id
        }
    }

    var isPartnerClaim: Bool {
        if case .partnerClaim = self { return true }
        return false
    }
}

public enum FetchClaimDetailsError: Error {
    case noClaimFound
    case serviceError(message: String)
}

extension FetchClaimDetailsError: LocalizedError {
    public var errorDescription: String? {
        L10n.General.errorBody
    }
}
