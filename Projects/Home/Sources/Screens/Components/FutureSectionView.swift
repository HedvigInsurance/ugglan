import AppStateContainer
import Foundation
import SwiftUI
import hCore
import hCoreUI

struct FutureSectionInfoView: View {
    @AppObservedObject var store: HomeStore
    var body: some View {
        switch store.futureStatus {
        case let .activeInFuture(inceptionDate):
            InfoCard(
                text: L10n.HomeTab.activeInFutureInfo(inceptionDate),
                type: .info
            )
        case .pendingSwitchable:
            InfoCard(
                text: L10n.HomeTab.pendingSwitchableInfo,
                type: .info
            )
        case .pendingNonswitchable:
            InfoCard(
                text: L10n.HomeTab.pendingNonswitchableInfo,
                type: .info
            )
        case .none:
            EmptyView()
        }
    }
}

#Preview("ActiveInFutureView") {
    Localization.Locale.currentLocale.send(.en_SE)
    return VStack {
        FutureSectionInfoView()
            .onAppear {
                let store: HomeStore = globalAppStateContainer.get()
                let contract = HomeContract(upcomingRenewal: nil, displayName: "name")
                store.setMemberContractState(.future, contracts: [contract])
                store.setFutureStatus(.activeInFuture(inceptionDate: "2023-11-23"))
            }
    }
}

#Preview("PendingSwitchableView") {
    Localization.Locale.currentLocale.send(.en_SE)
    return VStack {
        FutureSectionInfoView()
            .onAppear {
                let store: HomeStore = globalAppStateContainer.get()
                store.setMemberContractState(.future, contracts: [])
                store.setFutureStatus(.pendingSwitchable)
            }
    }
}

#Preview("PendingNonSwitchableView") {
    Localization.Locale.currentLocale.send(.en_SE)
    return VStack {
        FutureSectionInfoView()
            .onAppear {
                let store: HomeStore = globalAppStateContainer.get()
                store.setMemberContractState(.future, contracts: [])
                store.setFutureStatus(.pendingNonswitchable)
            }
    }
}
