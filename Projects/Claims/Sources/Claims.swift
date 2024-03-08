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
                    .padding([.bottom, .top])
            } else {
                ClaimSection(claims: claims)
                    .padding([.bottom, .top])
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
        .onReceive(vm.pollTimer) { _ in
            if ApplicationContext.shared.isLoggedIn {
                vm.fetch()
            } else {
                vm.pollTimer.upstream.connect().cancel()
            }
        }
    }
}

class ClaimsViewModel: ObservableObject {
    @PresentableStore var store: ClaimsStore
    let pollTimer: Publishers.Autoconnect<Timer.TimerPublisher>

    public init() {
        let store: ClaimsStore = globalPresentableStoreContainer.get()
        let count = store.state.claims?.count ?? 1
        let refreshOn: Int = {
            if count == 0 {
                return 5
            } else {
                return min(count * 5, 20)
            }
        }()
        pollTimer = Timer.publish(every: TimeInterval(refreshOn), on: .main, in: .common).autoconnect()
        fetch()
    }

    func fetch() {
        store.send(.fetchClaims)
    }
}
