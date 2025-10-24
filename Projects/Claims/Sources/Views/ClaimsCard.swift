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
            if vm.activeClaims.isEmpty {
                Spacer().frame(height: 40)
            } else if vm.activeClaims.count == 1, let claim = vm.activeClaims.first {
                ClaimStatusCard(claim: claim, enableTap: true)
                    .padding(.vertical)
            } else {
                ClaimSection(claims: $vm.activeClaims)
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
    private var stateObserver: AnyCancellable?
    private let refreshOn = 60
    @Published var activeClaims: [ClaimModel] = []

    init() {
        stateObserver = store.stateSignal
            .receive(on: RunLoop.main)
            .map(\.activeClaims)
            .removeDuplicates()
            .sink { [weak self] state in
                self?.activeClaims = state ?? []
            }
        activeClaims = store.state.activeClaims ?? []
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
        // added this to reset timer after we fetch becausae we could fetch from other places so we dont fetch too often
        configureTimer()
    }
}
