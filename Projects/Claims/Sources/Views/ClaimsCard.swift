import Combine
import Foundation
import PresentableStore
import SwiftUI

@MainActor
public struct ClaimsCard: View {
    @StateObject var vm = ClaimsViewModel()

    public init() {}

    public var body: some View {
        VStack {
            if vm.claims.isEmpty {
                Spacer().frame(height: 40)
            } else if vm.claims.count == 1, let claim = vm.claims.first {
                ClaimStatusCard(claimType: claim, enableTap: true)
                    .padding(.vertical)
            } else {
                ClaimSection(claims: $vm.claims)
                    .padding(.vertical)
            }
        }
        .onAppear {
            vm.fetch()
        }
        .onDisappear {
            vm.stopTimer()
        }
    }
}

@MainActor
class ClaimsViewModel: ObservableObject {
    @PresentableStore private var store: ClaimsStore
    private var pollTimerCancellable: AnyCancellable?
    private var cancellables = Set<AnyCancellable>()
    private let refreshOn = 60
    @Published var claims: [ClaimType] = []

    init() {
        store.stateSignal
            .receive(on: RunLoop.main)
            .map { state -> [ClaimType] in
                var combined: [ClaimType] = []
                if let inProgress = state.claimInProgress {
                    combined.append(.claimInProgress(model: inProgress))
                }
                combined.append(contentsOf: (state.activeClaims ?? []).map { .claim(model: $0) })
                return combined
            }
            .removeDuplicates()
            .sink { [weak self] claims in
                withAnimation {
                    self?.claims = claims
                }
            }
            .store(in: &cancellables)
    }

    func stopTimer() {
        pollTimerCancellable?.cancel()
    }

    private func configureTimer() {
        pollTimerCancellable = Timer.publish(every: TimeInterval(refreshOn), on: .main, in: .common)
            .autoconnect()
            .sink(receiveValue: { _ in
                Task { [weak self] in
                    self?.fetch()
                }
            })
    }

    func fetch() {
        store.send(.fetchActiveClaims)
        store.send(.fetchClaimInProgress)
        // reset poll window so external fetches (deep links, refresh) don't double up
        configureTimer()
    }
}

enum ClaimType: Equatable, Identifiable {
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
