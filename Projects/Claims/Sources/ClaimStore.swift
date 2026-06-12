import AppStateContainer
import Foundation
import hCore

@MainActor
@PersistableStore
public final class ClaimsStore: AppStore {
    @Inject private var fetchClaimsClient: hFetchClaimsClient

    @Published public internal(set) var activeClaims: [ClaimModel] = []
    @Published public internal(set) var historyClaims: [ClaimModel] = []
    @Published public internal(set) var files: [String: [File]] = [:]

    public init() {}

    public var hasActiveClaims: Bool {
        guard !activeClaims.isEmpty else { return false }
        return activeClaims.contains {
            $0.status == .beingHandled || $0.status == .reopened || $0.status == .submitted
        }
    }

    public func getClaimFor(id: String) -> ClaimModel? {
        activeClaims.first(where: { $0.id == id })
    }

    public func fetchActiveClaims() async {
        do {
            activeClaims = try await fetchClaimsClient.getActiveClaims()
        } catch {
        }
    }

    public func fetchHistoryClaims() async {
        do {
            historyClaims = try await fetchClaimsClient.getHistoryClaims()
        } catch {
        }
    }

    public func setFiles(_ files: [File], for claimId: String) {
        self.files[claimId] = files
    }
}
