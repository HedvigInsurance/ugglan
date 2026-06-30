import AppStateContainer
import Foundation
import SwiftUI
import hCoreUI

struct Contracts: View {
    @AppObservedObject var store: ContractStore
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
        .task {
            while !Task.isCancelled {
                await store.fetchContracts()
                try? await Task.sleep(seconds: 60)
            }
        }
        .onPullToRefresh {
            await store.fetchContracts()
        }
    }
}
