import Apollo
import Foundation
import Presentation
import SwiftUI
import hAnalytics
import hCore
import hCoreUI
import hGraphQL

struct FutureSectionInfoView: View {
    var memberName: String

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
        Localization.Locale.currentLocale = .en_SE
        return VStack {
            FutureSectionInfoView(memberName: "NAME")
            //                .onAppear {
            //                    let store: HomeStore = globalPresentableStoreContainer.get()
            //                    let contract = OctopusGraphQL.HomeQuery.Data.Contract(
            //                        displayName: "DISPLAY NAME",
            //                        switchedFromInsuranceProvider: nil,
            //                        status: .makeActiveInFutureStatus(futureInception: "2023-11-22"),
            //                        upcomingRenewal: nil
            //                    )
            //                    store.send(
            //                        .setMemberContractState(
            //                            state: .init(state: .future, name: "NAME"),
            //                            contracts: [.init(contract: contract)]
            //                        )
            //                    )
            //                    store.send(.setFutureStatus(status: .activeInFuture(inceptionDate: "2023-11-23")))
            //                }
        }

    }
}

struct PendingSwitchableView_Previews: PreviewProvider {
    static var previews: some View {
        Localization.Locale.currentLocale = .en_SE
        return VStack {
            FutureSectionInfoView(memberName: "NAME")
            //                .onAppear {
            //                    let store: HomeStore = globalPresentableStoreContainer.get()
            //                    let contract = GiraffeGraphQL.HomeQuery.Data.Contract(
            //                        displayName: "DISPLAY NAME",
            //                        switchedFromInsuranceProvider: nil,
            //                        status: .makeActiveInFutureStatus(futureInception: "2023-11-22"),
            //                        upcomingRenewal: nil
            //                    )
            //                    store.send(
            //                        .setMemberContractState(
            //                            state: .init(state: .future, name: "NAME"),
            //                            contracts: [.init(contract: contract)]
            //                        )
            //                    )
            //                    store.send(.setFutureStatus(status: .pendingSwitchable))
            //                }
        }

    }
}

struct PendingNonSwitchableView_Previews: PreviewProvider {
    static var previews: some View {
        Localization.Locale.currentLocale = .en_SE
        return VStack {
            FutureSectionInfoView(memberName: "NAME")
            //                .onAppear {
            //                    let store: HomeStore = globalPresentableStoreContainer.get()
            //                    let contract = GiraffeGraphQL.HomeQuery.Data.Contract(
            //                        displayName: "DISPLAY NAME",
            //                        switchedFromInsuranceProvider: nil,
            //                        status: .makeActiveInFutureStatus(futureInception: "2023-11-22"),
            //                        upcomingRenewal: nil
            //                    )
            //                    store.send(
            //                        .setMemberContractState(
            //                            state: .init(state: .future, name: "NAME"),
            //                            contracts: [.init(contract: contract)]
            //                        )
            //                    )
            //                    store.send(.setFutureStatus(status: .pendingNonswitchable))
            //                }
        }

    }
}
