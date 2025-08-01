import Foundation
import PresentableStore
import hCore

@MainActor
class FetchClaimDetailsService {
    @Inject var client: hFetchClaimDetailsClient
    @PresentableStore var store: ClaimsStore
    let type: FetchClaimDetailsType

    init(type: FetchClaimDetailsType) {
        self.type = type
    }

    func get() async throws -> ClaimModel {
        log.info("\(FetchClaimDetailsService.self): get for \(type)", error: nil, attributes: nil)
        return try await client.get(for: type)
    }

    func getFiles() async throws -> (claimId: String, files: [File]) {
        log.info("\(FetchClaimDetailsService.self): getFiles for \(type)", error: nil, attributes: nil)
        return try await client.getFiles(for: type)
    }

    func acknowledgeClosedStatus(statusId: String) async throws {
        log.info("\(FetchClaimDetailsService.self): acknowledgeClosedStatus for \(type)", error: nil, attributes: nil)
        return try await client.acknowledgeClosedStatus(claimId: statusId)
    }
}

@MainActor
public protocol hFetchClaimDetailsClient {
    func get(for type: FetchClaimDetailsType) async throws -> ClaimModel
    func getFiles(for type: FetchClaimDetailsType) async throws -> (claimId: String, files: [File])
    func acknowledgeClosedStatus(claimId: String) async throws
}

public enum FetchClaimDetailsType {
    case claim(id: String)
    case conversation(id: String)
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
