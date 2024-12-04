import Foundation
import PresentableStore
import hCore
import hGraphQL

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
}

@MainActor
public protocol hFetchClaimDetailsClient {
    func get(for type: FetchClaimDetailsType) async throws -> ClaimModel
    func getFiles(for type: FetchClaimDetailsType) async throws -> (claimId: String, files: [File])
}

public enum FetchClaimDetailsType {
    case claim(id: String)
    case conversation(id: String)
}

enum FetchClaimDetailsError: Error {
    case noClaimFound
}

extension FetchClaimDetailsError: LocalizedError {
    var errorDescription: String? {
        return L10n.General.errorBody
    }

}
