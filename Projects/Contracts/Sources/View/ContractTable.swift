import Apollo
import Foundation
import PresentableStore
import SwiftUI
import hCore
import hCoreUI
import hGraphQL

struct ContractTable: View {
    @PresentableStore var store: ContractStore
    let showTerminated: Bool
    @State var onlyTerminatedInsurances = false

    @EnvironmentObject var contractsNavigationVm: ContractsNavigationViewModel
    @EnvironmentObject var router: Router
    func getContractsToShow(for state: ContractState) -> [Contract] {
        if showTerminated {
            return state.terminatedContracts.compactMap { $0 }
        } else {
            let activeContractsToShow = state.activeContracts.compactMap { $0 }
            let pendingContractsToShow = state.pendingContracts.compactMap { $0 }
            if !(activeContractsToShow + pendingContractsToShow).isEmpty {
                DispatchQueue.main.async {
                    onlyTerminatedInsurances = false
                }
                return activeContractsToShow + pendingContractsToShow
            } else {
                DispatchQueue.main.async {
                    onlyTerminatedInsurances = true
                }
                return state.terminatedContracts.compactMap { $0 }
            }
        }
    }

    var body: some View {
        VStack(spacing: 0) {
            hLoadingViewWithContent(ContractStore.self, [.fetchContracts], [.fetchContracts], showLoading: false) {
                hSection {
                    PresentableStoreLens(
                        ContractStore.self,
                        getter: { state in
                            getContractsToShow(for: state)

                        }
                    ) { contracts in
                        VStack(spacing: .padding8) {
                            ForEach(contracts, id: \.id) { contract in
                                ContractRow(
                                    image: contract.pillowType?.bgImage,
                                    terminationMessage: contract.terminationMessage,
                                    contractDisplayName: contract.currentAgreement?.productVariant.displayName ?? "",
                                    contractExposureName: contract.exposureDisplayName,
                                    activeFrom: contract.upcomingChangedAgreement?.activeFrom,
                                    activeInFuture: contract.activeInFuture,
                                    masterInceptionDate: contract.masterInceptionDate,
                                    onClick: {
                                        router.push(contract)
                                    }
                                )
                                .fixedSize(horizontal: false, vertical: true)
                                .transition(.slide)
                            }
                        }
                    }
                }
                .presentableStoreLensAnimation(.spring())
                .sectionContainerStyle(.transparent)
            }
            if !showTerminated {
                VStack(spacing: 24) {
                    movingToANewHomeView
                    CrossSellingStack(withHeader: true)

                    PresentableStoreLens(
                        ContractStore.self,
                        getter: { state in
                            state.terminatedContracts
                        }
                    ) { terminatedContracts in
                        if !(terminatedContracts.isEmpty || onlyTerminatedInsurances) {
                            hSection {
                                hButton.LargeButton(type: .secondary) {
                                    router.push(ContractsRouterType.terminatedContracts)
                                } content: {
                                    hRow {
                                        HStack {
                                            hText(
                                                L10n.InsurancesTab.cancelledInsurancesLabel(
                                                    "\(terminatedContracts.count)"
                                                )
                                            )
                                            .foregroundColor(hTextColor.Opaque.primary)
                                            Spacer()
                                        }
                                    }
                                    .withChevronAccessory
                                    .verticalPadding(0)
                                    .foregroundColor(hTextColor.Opaque.secondary)
                                }
                            }
                            .transition(.slide)
                        }
                    }
                    .presentableStoreLensAnimation(.spring())
                    .sectionContainerStyle(.transparent)
                }
                .padding(.vertical, .padding24)
            }
        }
    }

    @ViewBuilder
    private var movingToANewHomeView: some View {
        PresentableStoreLens(
            ContractStore.self,
            getter: { state in
                state.activeContracts
            }
        ) { activeContracts in
            if !activeContracts.filter({ $0.typeOfContract.isHomeInsurance && !$0.isTerminated }).isEmpty {
                hSection {
                    InfoCard(text: L10n.insurancesTabMovingFlowInfoTitle, type: .campaign)
                        .buttons([
                            .init(
                                buttonTitle: L10n.insurancesTabMovingFlowInfoButtonTitle,
                                buttonAction: {
                                    contractsNavigationVm.isChangeAddressPresented = true
                                }
                            )
                        ])
                }
                .withHeader {
                    hText(L10n.insurancesTabMovingFlowSectionTitle)
                        .foregroundColor(hTextColor.Opaque.primary)
                        .padding(.leading, 2)
                    //                        .padding(.top, .padding8)
                }
            }
        }
    }
}
