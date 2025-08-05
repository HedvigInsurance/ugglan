import Combine
import Foundation
import PresentableStore
import SwiftUI
import hCore
import hCoreUI

@MainActor
public struct ClaimsCard: View {
    @StateObject var vm = ClaimsViewModel()
    @State var claims: [ClaimModel] = []

    public init() {}

    public var body: some View {
        VStack {
            if vm.claims.getClaims().isEmpty {
                Spacer().frame(height: 40)
            } else if vm.claims.getClaims().count == 1, let claim = vm.claims.getClaims().first {
                ClaimStatusCard(claim: claim, enableTap: true)
                    .padding(.vertical)
            } else {
                ClaimSection(claims: $claims)
                    .padding(.vertical)
            }
        }
        .onAppear {
            vm.fetch()
            self.claims = vm.claims.getClaims()
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
    @Published var claims: Claims = .init(claims: [], claimsActive: [], claimsHistory: [])

    init() {
        stateObserver = store.stateSignal
            .receive(on: RunLoop.main)
            .map(\.claims)
            .removeDuplicates()
            .sink { [weak self] state in
                self?.claims = state ?? .init(claims: [], claimsActive: [], claimsHistory: [])
            }
        claims = store.state.claims ?? .init(claims: [], claimsActive: [], claimsHistory: [])
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
        store.send(.fetchClaims)
        // added this to reset timer after we fetch becausae we could fetch from other places so we dont fetch too often
        configureTimer()
    }
}
