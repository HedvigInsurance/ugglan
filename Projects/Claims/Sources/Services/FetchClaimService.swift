import Foundation

protocol FetchClaimService {
    func get() async throws -> [ClaimModel]
}

class FetchClaimServiceDemo: FetchClaimService {
    func get() async throws -> [ClaimModel] {
        return []
    }
}

class FetchClaimServiceOctopus: FetchClaimService {
    func get() async throws -> [ClaimModel] {
        return []
    }
}
