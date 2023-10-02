import Combine
import Flow
import Form
import Foundation
import Presentation
import SwiftUI
import TerminateContracts
import UIKit
import hAnalytics
import hCore
import hCoreUI
import hGraphQL

struct ContractInformationView: View {
    @PresentableStore var store: ContractStore
    @PresentableStore var terminationContractStore: TerminationContractStore
    @StateObject private var vm = ContractsInformationViewModel()

    let id: String
    var body: some View {
        PresentableStoreLens(
            ContractStore.self,
            getter: { state in
                state.contractForId(id)
            }
        ) { contract in
            if let contract {
                changeAddressInfo(contract)
                VStack(spacing: 0) {
                    if let table = contract.currentAgreementsTable {
                        ForEach(table.sections) { section in
                            hSection(section.rows, id: \.title) { row in
                                hRow {
                                    hText(row.title)
                                }
                                .noSpacing()
                                .withCustomAccessory({
                                    Spacer()
                                    hText(row.value)
                                        .foregroundColor(hTextColorNew.secondary)
                                })
                            }
                            .withoutHorizontalPadding
                            .padding(.bottom, 16)
                        }
                    }

                    hSection {
                        VStack(spacing: 8) {
                            if contract.showEditButton {
                                hButton.LargeButton(type: .secondary) {
                                    store.send(.contractEditInfo(id: id))
                                } content: {
                                    hText(L10n.contractEditInfoLabel)
                                }
                            }
                        }
                    }
                    .padding(.bottom, 16)

                }
                displayTerminationButton
            }
        }
        .sectionContainerStyle(.transparent)
    }

    @ViewBuilder
    private func changeAddressInfo(_ contract: Contract) -> some View {
        if let date = contract.upcomingAgreementDate?.displayDateDotFormat {
            hSection {
                InfoCard(text: L10n.InsurancesTab.yourInsuranceWillBeUpdated(date), type: .info)
                    .buttons([
                        .init(
                            buttonTitle: L10n.InsurancesTab.viewDetails,
                            buttonAction: {
                                store.send(
                                    .contractDetailNavigationAction(action: .openInsuranceUpdate(contract: contract))
                                )
                            }
                        )
                    ])
            }
            .padding(.bottom, 16)
        }
    }

    @ViewBuilder
    private var displayTerminationButton: some View {
        if hAnalyticsExperiment.terminationFlow {
            PresentableStoreLens(
                ContractStore.self,
                getter: { state in
                    state.contractForId(id)
                }
            ) { contract in
                if (contract?.currentAgreement?.activeTo) == nil {
                    hSection {
                        LoadingButtonWithContent(
                            TerminationContractStore.self,
                            .startTermination,
                            buttonAction: {
                                terminationContractStore.send(
                                    .startTermination(contractId: id, contractName: contract?.displayName ?? "")
                                )
                                vm.cancellable = terminationContractStore.actionSignal.publisher.sink { action in
                                    if case let .navigationAction(navigationAction) = action {
                                        store.send(.startTermination(action: navigationAction))
                                        self.vm.cancellable = nil
                                    }
                                }
                            },
                            content: {
                                hText(L10n.terminationButton, style: .body)
                                    .foregroundColor(hTextColorNew.secondary)
                            },
                            buttonStyleSelect: .textButton
                        )
                    }
                    .sectionContainerStyle(.transparent)
                }
            }
        }
    }
}

struct ChangePeopleView: View {
    @PresentableStore var store: ContractStore

    var body: some View {
        hSection {
            VStack(alignment: .leading, spacing: 16) {
                L10n.InsuranceDetailsViewYourInfo.editInsuranceTitle
                    .hText(.title2)
                L10n.InsuranceDetailsViewYourInfo.editInsuranceDescription
                    .hText(.subheadline)
                    .foregroundColor(hTextColorNew.secondary)
                    .fixedSize(horizontal: false, vertical: true)
                    .multilineTextAlignment(.leading)
                    .padding(.bottom, 10)
                hButton.LargeButton(type: .primary) {
                    store.send(.goToFreeTextChat)
                } content: {
                    L10n.InsuranceDetailsViewYourInfo.editInsuranceButton.hText()
                }
            }
        }
        .sectionContainerStyle(.transparent)
    }
}

private class ContractsInformationViewModel: ObservableObject {
    var cancellable: AnyCancellable?
}
