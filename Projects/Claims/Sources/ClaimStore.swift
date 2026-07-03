import AppStateContainer
import Combine
import Foundation
import SwiftUI
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
    @Transient private var cancellables = Set<AnyCancellable>()

    public init() {
        FeatureFlags.shared.$data
            .map(\.isResumeClaimEnabled)
            .removeDuplicates()
            .dropFirst()
            .sink { [weak self] _ in
                Task { [weak self] in
                    await self?.fetchClaimInProgress()
                }
            }
            .store(in: &cancellables)
    }

    public var hasActiveClaims: Bool {
        activeClaims.map(\.status).contains { $0 != .closed }
    }

    public func getClaimFor(id: String) -> ClaimModel? {
        activeClaims.first(where: { $0.id == id })
    }

    public func fetchActiveClaims() async {
        do {
            let activeClaims = try await fetchClaimsClient.getActiveClaims()
            withAnimation {
                self.activeClaims = activeClaims
            }
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
        guard Dependencies.featureFlags().isResumeClaimEnabled else {
            withAnimation {
                claimInProgress = nil
            }
            return
        }
        do {
            let claimInProgress = try await fetchClaimsClient.getClaimInProgress()
            withAnimation {
                self.claimInProgress = claimInProgress
            }
        } catch {
        }
    }

    public func deleteClaimInProgress() async {
        guard let id = claimInProgress?.id else { return }
        do {
            try await fetchClaimsClient.deleteClaimInProgress(id: id)
            withAnimation {
                self.claimInProgress = nil
            }
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
