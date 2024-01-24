import Apollo
import Flow
import Form
import Foundation
import SwiftUI
import UIKit
import hCore
import hCoreUI
import hGraphQL

struct ContractTable {
    @PresentableStore var store: ContractStore
    let showTerminated: Bool
    @State var onlyTerminatedInsurances = false

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
}

extension ContractTable: View {
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
                        if onlyTerminatedInsurances {
                            InfoCard(text: L10n.InsurancesTab.cancelledInsurancesNote, type: .info)
                                .padding(.bottom, 16)

                        }
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
                                    store.send(
                                        .openDetail(
                                            contractId: contract.id,
                                            title: contract.currentAgreement?.productVariant.displayName ?? ""
                                        )
                                    )
                                }
                            )
                            .fixedSize(horizontal: false, vertical: true)
                            .padding(.bottom, 8)
                            .transition(.slide)
                        }
                    }
                }
            }
            .presentableStoreLensAnimation(.spring())
            .sectionContainerStyle(.transparent)
        }
        if !showTerminated {
            VStack(spacing: 16) {
                CrossSellingStack(withHeader: true)
                    .padding(.top, 24)
                PresentableStoreLens(
                    ContractStore.self,
                    getter: { state in
                        state.terminatedContracts
                    }
                ) { terminatedContracts in
                    if !(terminatedContracts.isEmpty || onlyTerminatedInsurances) {
                        hSection {
                            hButton.LargeButton(type: .secondary) {
                                store.send(.openTerminatedContracts)
                            } content: {
                                hRow {
                                    hText(L10n.InsurancesTab.cancelledInsurancesLabel("\(terminatedContracts.count)"))
                                        .foregroundColor(hTextColor.primary)
                                }
                                .withChevronAccessory
                                .foregroundColor(hTextColor.secondary)
                            }
                        }
                        .transition(.slide)
                    }
                }
                .presentableStoreLensAnimation(.spring())
                .sectionContainerStyle(.transparent)
                .padding(.bottom, 24)
            }
        }
    }
}
