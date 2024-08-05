import Apollo
import Foundation
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
        LoadingViewWithContent(ContractStore.self, [.fetchContracts], [.fetchContracts], showLoading: false) {
            hSection {
                PresentableStoreLens(
                    ContractStore.self,
                    getter: { state in
                        getContractsToShow(for: state)

                    }
                ) { contracts in
                    VStack(spacing: 0) {
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
                            .padding(.bottom, .padding8)
                            .transition(.slide)
                        }
                    }
                }
            }
            .hSectionMinimumPadding
            .presentableStoreLensAnimation(.spring())
            .sectionContainerStyle(.transparent)
        }
        if !showTerminated {
            VStack(spacing: 16) {
                CrossSellingStack(withHeader: true)
                    .padding(.top, .padding24)
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
                                            L10n.InsurancesTab.cancelledInsurancesLabel("\(terminatedContracts.count)")
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
                        .hSectionMinimumPadding
                        .transition(.slide)
                    }
                }
                .presentableStoreLensAnimation(.spring())
                .sectionContainerStyle(.transparent)
                .padding(.bottom, .padding24)
            }
        }
    }
}
