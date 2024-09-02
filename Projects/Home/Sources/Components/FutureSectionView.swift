import Apollo
import Foundation
import PresentableStore
import SwiftUI
import hCore
import hCoreUI
import hGraphQL

struct FutureSectionInfoView: View {

    var body: some View {
        PresentableStoreLens(
            HomeStore.self,
            getter: { state in
                state.futureStatus
            }
        ) { futureStatus in
            switch futureStatus {
            case .activeInFuture(let inceptionDate):
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

struct ActiveInFutureView_Previews: PreviewProvider {
    static var previews: some View {
        Localization.Locale.currentLocale.send(.en_SE)
        return VStack {
            FutureSectionInfoView()
                .onAppear {
                    let store: HomeStore = globalPresentableStoreContainer.get()
                    let contract = OctopusGraphQL.HomeQuery.Data.CurrentMember.ActiveContract(
                        _dataDict: .init(
                            data: [:],
                            fulfilledFragments: .init()
                        )
                    )

                    store.send(
                        .setMemberContractState(
                            state: .future,
                            contracts: [.init(contract: contract)]
                        )
                    )
                    store.send(.setFutureStatus(status: .activeInFuture(inceptionDate: "2023-11-23")))
                }
        }
    }
}

struct PendingSwitchableView_Previews: PreviewProvider {
    static var previews: some View {
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
}

struct PendingNonSwitchableView_Previews: PreviewProvider {
    static var previews: some View {
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
}
