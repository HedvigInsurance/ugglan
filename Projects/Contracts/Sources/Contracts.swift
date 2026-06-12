import AppStateContainer
import Foundation
import SwiftUI
import hCoreUI

struct Contracts: View {
    @AppObservedObject var store: ContractStore
    let pollTimer = Timer.publish(every: 60, on: .main, in: .common).autoconnect()
    let showTerminated: Bool

    init(
        showTerminated: Bool
    ) {
        self.showTerminated = showTerminated
    }

    var body: some View {
        hForm {
            ContractTable(showTerminated: showTerminated)
                .padding(.top, .padding8)
                .padding(.bottom, .padding16)
        }
        .hSetScrollBounce(to: true)
        .onReceive(pollTimer) { _ in
            Task { await store.fetchContracts() }
        }
        .task {
            await store.fetchContracts()
        }
        .onPullToRefresh {
            await store.fetchContracts()
        }
    }
}
