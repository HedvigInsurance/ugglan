import Combine
import Foundation
import Presentation
import SwiftUI
import hCore
import hCoreUI
import hGraphQL

public struct Claims {
    @StateObject var vm = ClaimsViewModel()

    public init() {}
}

extension Claims: View {
    @ViewBuilder
    func claimsSection(_ claims: [ClaimModel]) -> some View {
        VStack {
            if claims.isEmpty {
                Spacer().frame(height: 40)
            } else if claims.count == 1, let claim = claims.first {
                ClaimStatus(claim: claim, enableTap: true)
                    .padding(.vertical)
            } else {
                ClaimSection(claims: claims)
                    .padding(.vertical)
            }
        }
    }

    @ViewBuilder
    public var body: some View {
        PresentableStoreLens(
            ClaimsStore.self,
            getter: { state in
                state.claims ?? []
            },
            setter: { _ in
                .fetchClaims
            }
        ) { claims, _ in
            claimsSection(claims)
        }
        .onAppear {
            vm.fetch()
        }
        .onDisappear {
            vm.stopTimer()
        }
    }
}

class ClaimsViewModel: ObservableObject {
    @PresentableStore private var store: ClaimsStore
    private var pollTimerCancellable: AnyCancellable?
    private let refreshOn = 60

    func stopTimer() {
        pollTimerCancellable?.cancel()
    }

    private func configureTimer() {
        pollTimerCancellable = Timer.publish(every: TimeInterval(refreshOn), on: .main, in: .common)
            .autoconnect()
            .sink(receiveValue: { [weak self] _ in
                //added this check here because we have major memory leak in the tabjourney so when we logout this vm is still alive
                //TODO: remove after we fix memory leak
                if ApplicationContext.shared.isLoggedIn {
                    self?.fetch()
                } else {
                    self?.pollTimerCancellable?.cancel()
                }
            })
    }

    func fetch() {
        store.send(.fetchClaims)
        //added this to reset timer after we fetch becausae we could fetch from other places so we dont fetch too often
        configureTimer()
    }
}
