import AppStateContainer
import Foundation
import hCore

@MainActor
@PersistableStore
public final class ClaimsStore: AppStore {
    @Inject private var fetchClaimsClient: hFetchClaimsClient

    @Published public internal(set) var activeClaims: [ClaimModel] = [] {
        didSet {
            setAllActiveClaims()
        }
    }
    @Published public internal(set) var historyClaims: [ClaimModel] = []
    @Published public internal(set) var files: [String: [File]] = [:]
    @Published public var claimInProgress: ClaimInProgressModel? {
        didSet {
            setAllActiveClaims()
        }
    }
    @Published var allActiveClaims: [ActiveClaimType] = []

    public init() {}

    public var hasActiveClaims: Bool {
        activeClaims.map(\.status).contains { $0 != .closed }
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

    public func fetchClaimInProgress() async {
        do {
            claimInProgress = try await fetchClaimsClient.getClaimInProgress()
        } catch {
        }
    }

    private func setAllActiveClaims() {
        var claims = [ActiveClaimType]()
        if let claimInProgress {
            claims.append(.claimInProgress(model: claimInProgress))
        }
        claims.append(contentsOf: activeClaims.map({ .claim(model: $0) }))
        self.allActiveClaims = claims
    }

    enum ActiveClaimType: Equatable, Identifiable, Codable {
        case claim(model: ClaimModel)
        case claimInProgress(model: ClaimInProgressModel)

        var id: String {
            switch self {
            case .claim(let model):
                return model.id
            case .claimInProgress(let model):
                return model.title ?? "title"
            }
        }
    }
}
