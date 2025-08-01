import EditCoInsuredShared
import Foundation
import PresentableStore
import SwiftUI
import TerminateContracts
import hCore
import hCoreUI

struct Contracts: View {
    @PresentableStore var store: ContractStore
    let pollTimer = Timer.publish(every: 60, on: .main, in: .common).autoconnect()
    let showTerminated: Bool

    init(
        showTerminated: Bool
    ) {
        self.showTerminated = showTerminated
    }

    func fetch() {
        store.send(.fetchContracts)
    }

    var body: some View {
        hForm {
            ContractTable(showTerminated: showTerminated)
                .padding(.top, .padding8)
                .padding(.bottom, .padding16)
        }
        .hSetScrollBounce(to: true)
        .onReceive(pollTimer) { _ in
            fetch()
        }
        .onAppear {
            fetch()
        }
        .onPullToRefresh {
            await store.sendAsync(.fetchContracts)
        }
    }
}
