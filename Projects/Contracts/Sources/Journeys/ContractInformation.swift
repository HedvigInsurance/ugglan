import Combine
import EditCoInsured
import Flow
import Form
import Foundation
import Presentation
import SwiftUI
import TerminateContracts
import UIKit
import UnleashProxyClientSwift
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
                        if contract.supportsCoInsured {
                            hRowDivider()
                            addCoInsuredView(contract: contract)
                        }

                        VStack(spacing: 8) {
                            if contract.showEditInfo {
                                hSection {
                                    hButton.LargeButton(type: .secondary) {
                                        if onlyCoInsured(contract)
                                            && FeatureFlags.shared.isEditCoInsuredEnabled
                                        {
                                            store.send(
                                                .openEditCoInsured(
                                                    config: .init(contract: contract),
                                                    fromInfoCard: false
                                                )
                                            )
                                        } else {
                                            store.send(.contractEditInfo(id: id))
                                        }
                                    } content: {
                                        if onlyCoInsured(contract)
                                            && FeatureFlags.shared.isEditCoInsuredEnabled
                                        {
                                            hText(L10n.contractEditCoinsured)
                                        } else {
                                            hText(L10n.contractEditInfoLabel)
                                        }
                                    }
                                }
                            }
                            if contract.canTerminate {
                                displayTerminationButton
                            }
                        }
                        .padding(.bottom, 16)
                    }
                }
            }
        }
        .sectionContainerStyle(.transparent)
    }

    func onlyCoInsured(_ contract: Contract) -> Bool {
        let editTypes: [EditType] = EditType.getTypes(for: contract)
        return editTypes.count == 1 && editTypes.first == .coInsured
    }

    func insuredField(contract: Contract) -> some View {
        VStack {
            HStack {
                hText(L10n.coinsuredEditTitle)
                Spacer()
                hText(L10n.changeAddressYouPlus(contract.coInsured.count))
                    .foregroundColor(hTextColor.secondary)
            }
        }
    }

    @ViewBuilder
    private func addCoInsuredView(contract: Contract) -> some View {
        let nbOfMissingCoInsured = contract.nbOfMissingCoInsured
        VStack(spacing: 0) {
            hSection {
                HStack {
                    if FeatureFlags.shared.isEditCoInsuredEnabled {
                        hRow {
                            insuredField(contract: contract)
                        }
                    } else {
                        hRow {
                            insuredField(contract: contract)
                        }
                        .hWithoutDivider
                    }

                }

                if FeatureFlags.shared.isEditCoInsuredEnabled {
                    hRow {
                        let hasContentBelow =
                            !vm.getListToDisplay(contract: contract).isEmpty || nbOfMissingCoInsured > 0
                        ContractOwnerField(
                            enabled: true,
                            hasContentBelow: hasContentBelow,
                            fullName: contract.fullName,
                            SSN: contract.ssn ?? ""
                        )
                    }
                    .verticalPadding(0)
                    .padding(.top, 16)
                }
            }
            .withoutHorizontalPadding

            if FeatureFlags.shared.isEditCoInsuredEnabled {
                hSection(vm.getListToDisplay(contract: contract)) { coInsured in
                    hRow {
                        if coInsured.coInsured.hasMissingInfo {
                            addMissingCoInsuredView(contract: contract, coInsured: coInsured.coInsured)
                        } else {
                            CoInsuredField(
                                coInsured: coInsured.coInsured,
                                accessoryView: EmptyView(),
                                includeStatusPill: includeStatusPill(type: coInsured.type),
                                date: coInsured.date
                            )
                        }
                    }
                }
                .withoutHorizontalPadding

                if contract.nbOfMissingCoInsuredWithoutTermination != 0 && contract.showEditCoInsuredInfo {
                    hSection {
                        CoInsuredInfoView(
                            text: L10n.contractCoinsuredAddPersonalInfo,
                            config: .init(contract: contract)
                        )
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
    private func addMissingCoInsuredView(contract: Contract, coInsured: CoInsuredModel) -> some View {
        var statusPill: StatusPillType? {
            if coInsured.terminatesOn != nil {
                return .deleted
            } else if coInsured.activatesOn != nil {
                return .added
            }
            return nil
        }

        CoInsuredField(
            accessoryView: getAccessorytView(contract: contract, coInsured: coInsured)
                .foregroundColor(hSignalColor.amberElement),
            includeStatusPill: statusPill,
            date: coInsured.terminatesOn ?? coInsured.activatesOn,
            title: L10n.contractCoinsured,
            subTitle: L10n.contractNoInformation
        )
        .onTapGesture {
            if contract.showEditCoInsuredInfo && coInsured.terminatesOn == nil {
                store.send(
                    .openEditCoInsured(config: .init(contract: contract), fromInfoCard: true)
                )
            }
        }
    }

    @ViewBuilder
    private func getAccessorytView(contract: Contract, coInsured: CoInsuredModel) -> some View {
        if contract.showEditCoInsuredInfo && coInsured.terminatesOn == nil {
            Image(uiImage: hCoreUIAssets.warningSmall.image)
        } else {
            EmptyView()
        }
    }

    @ViewBuilder
    private func upatedContractView(_ contract: Contract) -> some View {
        if let upcomingRenewal = contract.upcomingRenewal,
            let days = upcomingRenewal.renewalDate.localDateToDate?.daysBetween(start: Date())
        {
            hSection {
                InfoCard(
                    text: days == 0
                        ? L10n.dashboardRenewalPrompterBodyTomorrow : L10n.dashboardRenewalPrompterBody(days),
                    type: .info
                )
                .buttons([
                    .init(
                        buttonTitle: L10n.dashboardRenewalPrompterBodyButton,
                        buttonAction: {
                            if let url = URL(string: upcomingRenewal.draftCertificateUrl) {
                                store.send(
                                    .contractDetailNavigationAction(
                                        action: .document(url: url, title: L10n.insuranceCertificateTitle)
                                    )
                                )
                            }
                        }
                    )
                ])
            }
            .padding(.top, 8)
        } else if let upcomingChangedAgreement = contract.upcomingChangedAgreement {
            hSection {
                HStack {
                    if let hasUpCoimingCoInsuredChanges = contract.coInsured.first(where: {
                        return ($0.activatesOn != nil || $0.terminatesOn != nil)
                    }), FeatureFlags.shared.isEditCoInsuredEnabled {
                        InfoCard(
                            text: L10n.contractCoinsuredUpdateInFuture(
                                contract.coInsured.count,
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
                        .padding(.top, 8)
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
                        .padding(.top, 8)
                    }
                }
            }
        }
    }

    @ViewBuilder
    private var displayTerminationButton: some View {
        if FeatureFlags.shared.isTerminationFlowEnabled {
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

    func getListToDisplay(contract: Contract) -> [CoInsuredListType] {
        return contract.coInsured
            .map {
                CoInsuredListType(
                    coInsured: $0,
                    date: $0.activatesOn ?? $0.terminatesOn,
                    locallyAdded: false
                )
            }
    }
}
