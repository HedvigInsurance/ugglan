import EditCoInsuredShared
import Foundation
import StoreContainer
import SwiftUI
import TerminateContracts
import hCore
import hCoreUI
import hGraphQL

struct Contracts: View {
    @PresentableStore var store: ContractStore
    let pollTimer = Timer.publish(every: 60, on: .main, in: .common).autoconnect()
    let showTerminated: Bool

    public init(
        showTerminated: Bool
    ) {
        self.showTerminated = showTerminated
    }

    func fetch() {
        store.send(.fetchContracts)
    }

    public var body: some View {
        hForm {
            ContractTable(showTerminated: showTerminated)
                .padding(.top, .padding8)
        }
        .hFormBottomBackgroundColor(.gradient(from: hBackgroundColor.primary, to: hBackgroundColor.primary))
        .onReceive(pollTimer) { _ in
            fetch()
        }
        .onAppear {
            fetch()
        }
        .onPullToRefresh {
            await store.sendAsync(.fetch)
        }
    }
}
