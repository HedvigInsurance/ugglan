import Combine
import Foundation
import PresentableStore
import SwiftUI
import hCore
import hCoreUI
import hGraphQL

public struct Claims {
    @StateObject var vm = ClaimsViewModel()

    public init() {}
}

extension Claims: View {
    public var body: some View {
        VStack {
            if vm.claims.isEmpty {
                Spacer().frame(height: 40)
            } else if vm.claims.count == 1, let claim = vm.claims.first {
                ClaimStatus(claim: claim, enableTap: true)
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
    private var stateObserver: AnyCancellable?
    private let refreshOn = 60
    @Published var claims = [ClaimModel]()

    init() {
        stateObserver = store.stateSignal
            .receive(on: RunLoop.main)
            .map(\.claims)
            .removeDuplicates()
            .sink { [weak self] state in
                self?.claims = state ?? []
            }
        claims = store.state.claims ?? []
    }

    func stopTimer() {
        pollTimerCancellable?.cancel()
    }

    private func configureTimer() {
        pollTimerCancellable = Timer.publish(every: TimeInterval(refreshOn), on: .main, in: .common)
            .autoconnect()
            .sink(receiveValue: { _ in
                //added this check here because we have major memory leak in the tabjourney so when we logout this vm is still alive
                //TODO: remove after we fix memory leak
                Task { [weak self] in
                    self?.fetch()
                }
            })
    }

    func fetch() {
        store.send(.fetchClaims)
        //added this to reset timer after we fetch becausae we could fetch from other places so we dont fetch too often
        configureTimer()
    }
}
