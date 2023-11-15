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
                upatedContractView(contract)
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
        let nbOfMissingCoInsured = contract.nbOfMissingCoInsured
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
                                hText(contract.fullName)
                                hText(contract.ssn ?? "", style: .footnote)
                                    .foregroundColor(hTextColor.secondary)
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                            Spacer()
                            Image(uiImage: hCoreUIAssets.lockSmall.image)
                                .foregroundColor(hTextColor.tertiary)
                        }
                    }
                }
                VStack(spacing: 0) {
                    ForEach(vm.coInsuredRemainingData(contract: contract), id: \.self) { coInsuredd in
                        CoInsuredField(
                            coInsured: coInsuredd,
                            accessoryView: EmptyView()
                        )
                    }
                    ForEach(vm.coInsuredDeletedData(contract: contract), id: \.self) { coInsured in
                        CoInsuredField(
                            coInsured: coInsured,
                            accessoryView: EmptyView(),
                            includeStatusPill: StatusPillType.deleted,
                            date: contract.upcomingChangedAgreement?.activeFrom
                        )
                    }
                    ForEach(vm.coInsuredAddedData(contract: contract), id: \.self) { coInsured in
                        CoInsuredField(
                            coInsured: coInsured,
                            accessoryView: EmptyView(),
                            includeStatusPill: StatusPillType.added,
                            date: contract.upcomingChangedAgreement?.activeFrom
                        )
                    }
                }
                .padding(.leading, 16)

                ForEach(0..<nbOfMissingCoInsured, id: \.self) { index in
                    addMissingCoInsuredView(contract: contract)
                    if index < nbOfMissingCoInsured - 1 {
                        hRowDivider()
                    }
                }
            }
            .withoutHorizontalPadding
            hSection {
                if nbOfMissingCoInsured != 0 && contract.supportsCoInsured && contract.terminationDate == nil {
                    CoInsuredInfoView(text: L10n.contractCoinsuredAddPersonalInfo, contractId: contract.id)
                        .padding(.bottom, 16)
                }
            }
        }
    }

    @ViewBuilder
    private func addMissingCoInsuredView(contract: Contract) -> some View {
        CoInsuredField(
            accessoryView: Image(uiImage: hCoreUIAssets.warningSmall.image)
                .foregroundColor(hSignalColor.amberElement),
            title: L10n.contractCoinsured,
            subTitle: L10n.contractNoInformation
        )
        .padding(.horizontal, 16)
        .onTapGesture {
            if contract.supportsCoInsured && contract.terminationDate == nil {
                store.send(
                    .openEditCoInsured(contractId: id, fromInfoCard: true)
                )
            }
        }
    }

    @ViewBuilder
    private func upatedContractView(_ contract: Contract) -> some View {
        if let upcomingChangedAgreement = contract.upcomingChangedAgreement {
            hSection {
                HStack {
                    if upcomingChangedAgreement.coInsured != contract.currentAgreement?.coInsured {
                        InfoCard(
                            text: L10n.contractCoinsuredUpdateInFuture(
                                upcomingChangedAgreement.coInsured.count,
                                upcomingChangedAgreement.activeFrom?.localDateToDate?
                                    .displayDateDDMMMYYYYFormat ?? ""
                            ),
                            type: .info
                        )
                        .buttons([
                            .init(
                                buttonTitle: L10n.contractViewCertificateButton,
                                buttonAction: {
                                    let certificateURL = upcomingChangedAgreement.certificateUrl
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
                    } else {
                        InfoCard(
                            text: L10n.InsurancesTab.yourInsuranceWillBeUpdated(
                                upcomingChangedAgreement.activeFrom ?? ""
                            ),
                            type: .info
                        )
                        .buttons([
                            .init(
                                buttonTitle: L10n.InsurancesTab.viewDetails,
                                buttonAction: {
                                    store.send(
                                        .contractDetailNavigationAction(
                                            action: .openInsuranceUpdate(contract: contract)
                                        )
                                    )
                                }
                            )
                        ])
                    }
                }
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

    func coInsuredAddedData(contract: Contract) -> [CoInsuredModel] {
        let upcoming = Set(contract.upcomingChangedAgreement?.coInsured ?? [])
        let current = Set(contract.currentAgreement?.coInsured ?? [])
        let result = upcoming.subtracting(current).filter { !$0.hasMissingData }
        return result.sorted(by: { $0.fullName ?? "" > $1.fullName ?? "" })
    }

    func coInsuredRemainingData(contract: Contract) -> [CoInsuredModel] {
        guard let upcomingHasValues = contract.upcomingChangedAgreement?.coInsured else {
            return contract.currentAgreement?.coInsured.filter({ !$0.hasMissingData }) ?? []
        }
        let upcoming = Set(contract.upcomingChangedAgreement?.coInsured ?? [])
        let current = Set(contract.currentAgreement?.coInsured ?? [])
        let result = current.intersection(upcoming).filter { !$0.hasMissingData }
        return result.sorted(by: { $0.fullName ?? "" > $1.fullName ?? "" })
    }

    func coInsuredDeletedData(contract: Contract) -> [CoInsuredModel] {
        guard let upcomingHasValues = contract.upcomingChangedAgreement?.coInsured else { return [] }
        let upcoming = Set(contract.upcomingChangedAgreement?.coInsured ?? [])
        let current = Set(contract.currentAgreement?.coInsured ?? [])
        let result = current.subtracting(upcoming).filter { !$0.hasMissingData }
        return result.sorted(by: { $0.fullName ?? "" > $1.fullName ?? "" })
    }
}
