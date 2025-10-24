import Foundation
import PresentableStore
import hCore

@MainActor
class FetchClaimDetailsService {
    @Inject var client: hFetchClaimDetailsClient
    let id: String

    init(id: String) {
        self.id = id
    }

    func get() async throws -> ClaimModel {
        log.info("\(FetchClaimDetailsService.self): get for \(id)", error: nil, attributes: nil)
        return try await client.get(for: id)
    }

    func getFiles() async throws -> [File] {
        log.info("\(FetchClaimDetailsService.self): getFiles for \(id)", error: nil, attributes: nil)
        return try await client.getFiles(for: id)
    }

    func acknowledgeClosedStatus(for id: String) async throws {
        log.info("\(FetchClaimDetailsService.self): acknowledgeClosedStatus for \(id)", error: nil, attributes: nil)
        return try await client.acknowledgeClosedStatus(for: id)
    }
}

@MainActor
public protocol hFetchClaimDetailsClient {
    func get(for id: String) async throws -> ClaimModel
    func getFiles(for id: String) async throws -> [File]
    func acknowledgeClosedStatus(for id: String) async throws
}

public enum ClaimDetailsType {
    case claim(id: String)
    case conversation(claimId: String)

    var claimId: String {
        switch self {
        case let .claim(id):
            return id
        case let .conversation(claimId):
            return claimId
        }
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
