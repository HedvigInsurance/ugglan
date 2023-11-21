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

                        if hAnalyticsExperiment.editCoinsured {
                            addCoInsuredView(contract: contract)
                        }

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
                            hText(L10n.coinsuredEditTitle)
                            Spacer()
                            hText(L10n.changeAddressYouPlus(contract.currentAgreement?.coInsured.count ?? 0))
                                .foregroundColor(hTextColor.secondary)
                        }
                    }
                }

                hRow {
                    ContractOwnerField(contractId: contract.id, enabled: true)
                }
                .verticalPadding(0)
                .padding(.top, 16)
            }
            .withoutHorizontalPadding

            if hAnalyticsExperiment.editCoinsured {
                let getListsToDisplay =
                    vm.coInsuredRemainingData(contract: contract) + vm.coInsuredDeletedData(contract: contract)
                    + vm.coInsuredAddedData(contract: contract)

                hSection(getListsToDisplay) { coInsured in

                    hRow {
                        CoInsuredField(
                            coInsured: coInsured.coInsured,
                            accessoryView: EmptyView(),
                            includeStatusPill: includeStatusPill(type: coInsured.type),
                            date: contract.upcomingChangedAgreement?.activeFrom
                        )
                    }
                }
                .withoutHorizontalPadding

                ForEach(0..<nbOfMissingCoInsured, id: \.self) { index in
                    addMissingCoInsuredView(contract: contract)
                    if index < nbOfMissingCoInsured - 1 {
                        hRowDivider()
                    }
                }
            }
            if hAnalyticsExperiment.editCoinsured {
                hSection {
                    if nbOfMissingCoInsured != 0 && contract.showEditInfo {
                        CoInsuredInfoView(text: L10n.contractCoinsuredAddPersonalInfo, contractId: contract.id)
                            .padding(.bottom, 16)
                    }
                }
            }
        }
    }

    private func includeStatusPill(type: StatusPillType?) -> StatusPillType? {
        if type == nil {
            return nil
        } else {
            return type
        }
    }

    @ViewBuilder
    private func addMissingCoInsuredView(contract: Contract) -> some View {
        hRow {
            CoInsuredField(
                accessoryView: getAccessorytView(contract: contract)
                    .foregroundColor(hSignalColor.amberElement),
                title: L10n.contractCoinsured,
                subTitle: L10n.contractNoInformation
            )
        }
        .onTapGesture {
            if contract.showEditInfo {
                store.send(
                    .openEditCoInsured(contractId: id, fromInfoCard: true)
                )
            }
        }
    }

    @ViewBuilder
    private func getAccessorytView(contract: Contract) -> some View {
        if contract.showEditInfo {
            Image(uiImage: hCoreUIAssets.warningSmall.image)
        } else {
            EmptyView()
        }
    }

    public func displayInfoCard(contract: Contract) -> Bool {
        let currentCoInsured = contract.currentAgreement?.coInsured
        let upComingCoInsured = contract.upcomingChangedAgreement?.coInsured
        return !(currentCoInsured?.contains(CoInsuredModel()) ?? false)
            && !(upComingCoInsured?.contains(CoInsuredModel()) ?? false)
    }

    @ViewBuilder
    private func upatedContractView(_ contract: Contract) -> some View {
        if let upcomingChangedAgreement = contract.upcomingChangedAgreement, displayInfoCard(contract: contract) {
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

    func coInsuredAddedData(contract: Contract) -> [CoInsuredListType] {
        let upcoming = Set(contract.upcomingChangedAgreement?.coInsured ?? [])
        if !upcoming.isEmpty {
            let current = Set(contract.currentAgreement?.coInsured ?? [])
            if !current.contains(CoInsuredModel()) {
                let result = upcoming.subtracting(current).filter { !$0.hasMissingData }
                return result.sorted(by: { $0.fullName ?? "" > $1.fullName ?? "" })
                    .map { CoInsuredListType(coInsured: $0, type: .added, locallyAdded: false) }
            } else {
                return []
            }
        } else {
            return []
        }
    }

    func coInsuredRemainingData(contract: Contract) -> [CoInsuredListType] {
        guard let upcomingHasValues = contract.upcomingChangedAgreement?.coInsured else {
            return contract.currentAgreement?.coInsured.map({ CoInsuredListType(coInsured: $0, locallyAdded: false) })
                ?? []
        }

        let upcoming = Set(contract.upcomingChangedAgreement?.coInsured ?? [])
        let current = Set(contract.currentAgreement?.coInsured ?? [])

        guard !current.contains(CoInsuredModel()) else {
            return upcoming.filter { !$0.hasMissingData }.sorted(by: { $0.fullName ?? "" > $1.fullName ?? "" })
                .map({
                    CoInsuredListType(coInsured: $0, locallyAdded: false)
                })
        }

        let result = current.intersection(upcoming).filter { !$0.hasMissingData }
        return result.sorted(by: { $0.fullName ?? "" > $1.fullName ?? "" })
            .map {
                CoInsuredListType(coInsured: $0, locallyAdded: false)
            }
    }

    func coInsuredDeletedData(contract: Contract) -> [CoInsuredListType] {
        guard let upcomingHasValues = contract.upcomingChangedAgreement?.coInsured else { return [] }
        let upcoming = Set(contract.upcomingChangedAgreement?.coInsured ?? [])
        let current = Set(contract.currentAgreement?.coInsured ?? [])
        let result = current.subtracting(upcoming).filter { !$0.hasMissingData }
        return result.sorted(by: { $0.fullName ?? "" > $1.fullName ?? "" })
            .map { CoInsuredListType(coInsured: $0, type: .deleted, locallyAdded: false) }
    }
}
