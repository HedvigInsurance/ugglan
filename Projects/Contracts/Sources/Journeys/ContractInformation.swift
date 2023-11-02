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
                upComingCoInsuredView(contract: contract)
                VStack(spacing: 0) {
                    if let displayItems = contract.currentAgreement?.displayItems {
                        hSection(displayItems, id: \.displayValue) { item in
                            hRow {
                                hText(item.displayTitle)
                            }
                            .noSpacing()
                            .withCustomAccessory({
                                Spacer()
                                hText(item.displayValue)
                                    .foregroundColor(hTextColor.secondary)
                            })
                        }
                        .withoutHorizontalPadding
                        hRowDivider()

                        addCoInsuredView(contract: contract)

                        VStack(spacing: 8) {
                            if contract.showEditInfo {
                                hSection {
                                    hButton.LargeButton(type: .secondary) {
                                        store.send(.contractEditInfo(id: id))
                                    } content: {
                                        hText(L10n.contractEditInfoLabel)
                                    }
                                }
                            }
                            displayTerminationButton
                        }
                        .padding(.bottom, 16)
                    }
                }
            }
        }
        .sectionContainerStyle(.transparent)
    }

    @ViewBuilder
    private func addCoInsuredView(contract: Contract) -> some View {
        let nbOfMissingCoInsured = contract.currentAgreement?.nbOfMissingCoInsured ?? 0
        VStack(spacing: 0) {
            hSection {
                hRow {
                    VStack {
                        HStack {
                            hText(L10n.changeAddressCoInsuredLabel)
                            Spacer()
                            hText(L10n.changeAddressYouPlus(contract.currentAgreement?.coInsured.count ?? 0))
                                .foregroundColor(hTextColor.secondary)
                        }

                        HStack {
                            VStack(alignment: .leading) {
                                hText("Julia Andersson")
                                hText("SSN", style: .footnote)
                                    .foregroundColor(hTextColor.secondary)
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                            Spacer()
                            Image(uiImage: hCoreUIAssets.lockSmall.image)
                                .foregroundColor(hTextColor.tertiary)
                        }
                    }
                }
                ForEach(contract.currentAgreement?.coInsured ?? [], id: \.self) { coInsured in
                    VStack(alignment: .leading) {
                        hText(coInsured.fullName ?? "")
                        hText(coInsured.SSN ?? "", style: .footnote)
                            .foregroundColor(hTextColor.secondary)
                    }
                }

                ForEach(0..<nbOfMissingCoInsured, id: \.self) { index in
                    hRow {
                        HStack(alignment: .top) {
                            VStack(alignment: .leading) {
                                hText(L10n.contractCoinsured)
                                hText(L10n.contractNoInformation, style: .footnote)
                                    .foregroundColor(hTextColor.secondary)
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                            Spacer()
                            Image(uiImage: hCoreUIAssets.warningSmall.image)
                                .foregroundColor(hSignalColor.amberElement)
                        }
                    }
                    if index < nbOfMissingCoInsured - 1 {
                        hRowDivider()
                    }
                }
            }
            .withoutHorizontalPadding
            hSection {
                if nbOfMissingCoInsured != 0 {
                    CoInsuredInfoView(text: L10n.contractCoinsuredAddPersonalInfo, contractId: contract.id)
                        .padding(.bottom, 16)
                }
            }
        }
    }

    @ViewBuilder
    private var addMissingCoInsuredView: some View {
        hRow {
            HStack(alignment: .top) {
                VStack(alignment: .leading) {
                    hText(L10n.contractCoinsured)
                    hText(L10n.contractNoInformation, style: .footnote)
                        .foregroundColor(hTextColor.secondary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                Spacer()
                Image(uiImage: hCoreUIAssets.warningSmall.image)
                    .foregroundColor(hSignalColor.amberElement)
            }
        }
    }

    @ViewBuilder
    private func upComingCoInsuredView(contract: Contract) -> some View {
        // TODO: ADD PROPER DATA
        hSection {
            InfoCard(
                text: L10n.contractCoinsuredUpdateInFuture(
                    3,
                    "2023-11-16".localDateToDate?.displayDateDDMMMYYYYFormat ?? ""
                ),
                type: .info
            )
            .buttons([
                .init(
                    buttonTitle: L10n.contractViewCertificateButton,
                    buttonAction: {
                        /* TODO: CHANGE */
                        //                                let certificateURL = contract.upcomingChangedAgreement?.certificateUrl
                        let certificateURL = contract.currentAgreement?.certificateUrl
                        if let url = URL(string: certificateURL) {
                            store.send(
                                .contractDetailNavigationAction(
                                    action: .document(url: url, title: L10n.myDocumentsInsuranceCertificate)
                                )
                            )
                        }
                    }
                )
            ])
        }
        .padding(.top, 8)
    }

    @ViewBuilder
    private func changeAddressInfo(_ contract: Contract) -> some View {
        if let date = contract.upcomingChangedAgreement?.activeFrom {
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
                if contract?.canTerminate ?? false {
                    hSection {
                        hButton.LargeButton(type: .ghost) {
                            terminationContractStore.send(
                                .startTermination(contractId: id, contractName: contract?.exposureDisplayName ?? "")
                            )
                            vm.cancellable = terminationContractStore.actionSignal.publisher.sink { action in
                                if case let .navigationAction(navigationAction) = action {
                                    store.send(.startTermination(action: navigationAction))
                                    self.vm.cancellable = nil
                                }
                            }
                        } content: {
                            hText(L10n.terminationButton, style: .body)
                                .foregroundColor(hTextColor.secondary)
                        }
                        .trackLoading(TerminationContractStore.self, action: .startTermination)
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
                    .foregroundColor(hTextColor.secondary)
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
