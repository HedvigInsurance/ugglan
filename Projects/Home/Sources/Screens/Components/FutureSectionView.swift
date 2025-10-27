import Apollo
import Foundation
import PresentableStore
import SwiftUI
import hCore
import hCoreUI

struct FutureSectionInfoView: View {
    var body: some View {
        PresentableStoreLens(
            HomeStore.self,
            getter: { state in
                state.futureStatus
            }
        ) { futureStatus in
            switch futureStatus {
            case let .activeInFuture(inceptionDate):
                InfoCard(
                    text:
                        L10n.HomeTab.activeInFutureInfo(inceptionDate),
                    type: .info
                )
            case .pendingSwitchable:
                InfoCard(
                    text: L10n.HomeTab.pendingSwitchableInfo,
                    type: .info
                )
            case .pendingNonswitchable:
                InfoCard(
                    text:
                        L10n.HomeTab.pendingNonswitchableInfo,
                    type: .info
                )
            case .none:
                EmptyView()
            }
        }
    }
}

#Preview("ActiveInFutureView") {
    Localization.Locale.currentLocale.send(.en_SE)
    return VStack {
        FutureSectionInfoView()
            .onAppear {
                let store: HomeStore = globalPresentableStoreContainer.get()
                let contract = HomeContract(upcomingRenewal: nil, displayName: "name")

                store.send(
                    .setMemberContractState(
                        state: .future,
                        contracts: [contract]
                    )
                )
                store.send(.setFutureStatus(status: .activeInFuture(inceptionDate: "2023-11-23")))
            }
    }
}

#Preview("PendingSwitchableView") {
    Localization.Locale.currentLocale.send(.en_SE)
    return VStack {
        FutureSectionInfoView()
            .onAppear {
                let store: HomeStore = globalPresentableStoreContainer.get()
                store.send(
                    .setMemberContractState(
                        state: .future,
                        contracts: []
                    )
                )
                store.send(.setFutureStatus(status: .pendingSwitchable))
            }
    }
}

#Preview("PendingNonSwitchableView") {
    Localization.Locale.currentLocale.send(.en_SE)
    return VStack {
        FutureSectionInfoView()
            .onAppear {
                let store: HomeStore = globalPresentableStoreContainer.get()
                store.send(
                    .setMemberContractState(
                        state: .future,
                        contracts: []
                    )
                )
                store.send(.setFutureStatus(status: .pendingNonswitchable))
            }
    }
}
