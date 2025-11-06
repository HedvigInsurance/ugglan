import Combine
import EditCoInsured
import Foundation
import PresentableStore
import SwiftUI
import UnleashProxyClientSwift
import hCore
import hCoreUI

struct ContractInformationView: View {
    @PresentableStore var store: ContractStore
    @StateObject private var vm = ContractsInformationViewModel()
    @EnvironmentObject private var contractsNavigationVm: ContractsNavigationViewModel
    @InjectObservableObject private var featureFlags: FeatureFlags
    let id: String
    var body: some View {
        PresentableStoreLens(
            ContractStore.self,
            getter: { state in
                state.contractForId(id)
            }
        ) { contract in
            if let contract {
                VStack(spacing: 0) {
                    updatedContractView(contract)
                        .transition(.opacity.combined(with: .scale))
                    VStack(spacing: 0) {
                        if let displayItems = contract.currentAgreement?.displayItems {
                            hSection(displayItems, id: \.id) { item in
                                hRow {
                                    hText(item.displayTitle)
                                }
                                .withCustomAccessory {
                                    Spacer()
                                    Group {
                                        if let date = item.displayValue.localDateToDate?.displayDateDDMMMYYYYFormat {
                                            hText(date)
                                        } else {
                                            ZStack {
                                                hText(item.displayValue)
                                                hText(" ")
                                            }
                                        }
                                    }
                                    .foregroundColor(hTextColor.Opaque.secondary)
                                }
                                .accessibilityElement(children: .combine)
                            }

                            if let currentAgreementCost = contract.currentAgreement?.itemCost {
                                hRowDivider()
                                    .padding(.horizontal, .padding16)
                                ItemCostView(itemCost: currentAgreementCost)
                            }

                            if contract.supportsCoInsured {
                                hRowDivider()
                                    .padding(.horizontal, .padding16)
                                addCoInsuredView(contract: contract)
                            }

                            VStack(spacing: .padding8) {
                                if contract.showEditInfo {
                                    hSection {
                                        hButton(
                                            .large,
                                            .secondary,
                                            content: .init(title: vm.getButtonText(contract)),
                                            {
                                                if contract.onlyCoInsured() {
                                                    let contract: InsuredPeopleConfig = .init(
                                                        contract: contract,
                                                        fromInfoCard: false
                                                    )

                                                    contractsNavigationVm.editCoInsuredVm.start(fromContract: contract)
                                                } else {
                                                    contractsNavigationVm.changeYourInformationContract = contract
                                                }
                                            }
                                        )
                                    }
                                }
                                moveAddressButton(contract: contract)
                            }
                            .padding(.bottom, .padding16)
                        }
                    }
                    .hWithoutHorizontalPadding([.row, .divider])
                }
            }
        }
        .sectionContainerStyle(.transparent)
    }

    func insuredField(contract: Contract) -> some View {
        VStack {
            HStack {
                hText(L10n.coinsuredEditTitle)
                Spacer()
                hText(
                    contract.coInsured.count > 0
                        ? L10n.changeAddressYouPlus(contract.coInsured.count) : L10n.changeAddressOnlyYou
                )
                .foregroundColor(hTextColor.Opaque.secondary)
            }
        }
        .accessibilityElement(children: .combine)
    }

    @ViewBuilder
    private func addCoInsuredView(contract: Contract) -> some View {
        let nbOfMissingCoInsured = contract.nbOfMissingCoInsured
        VStack(spacing: 0) {
            hSection {
                HStack {
                    hRow {
                        insuredField(contract: contract)
                    }
                }

                let hasContentBelow =
                    !vm.getListToDisplay(contract: contract).isEmpty || nbOfMissingCoInsured > 0
                ContractOwnerField(
                    enabled: true,
                    hasContentBelow: hasContentBelow,
                    fullName: contract.fullName,
                    SSN: contract.ssn ?? ""
                )
                .padding(.top, .padding16)
            }

            hSection(vm.getListToDisplay(contract: contract)) { coInsured in
                hRow {
                    if coInsured.coInsured.hasMissingInfo {
                        CoInsuredField(
                            accessoryView: getAccessoryView(contract: contract, coInsured: coInsured.coInsured)
                                .foregroundColor(hSignalColor.Amber.element),
                            date: coInsured.coInsured.terminatesOn ?? coInsured.coInsured.activatesOn
                        )
                        .onTapGesture {
                            if contract.showEditCoInsuredInfo, coInsured.coInsured.terminatesOn == nil {
                                let contract: InsuredPeopleConfig = .init(
                                    contract: contract,
                                    fromInfoCard: false
                                )
                                contractsNavigationVm.editCoInsuredVm.start(fromContract: contract)
                            }
                        }
                        .accessibilityElement(children: .combine)
                    } else {
                        CoInsuredField(
                            coInsured: coInsured.coInsured,
                            accessoryView: EmptyView(),
                            date: coInsured.date
                        )
                    }
                }
            }

            if contract.nbOfMissingCoInsuredWithoutTermination != 0, contract.showEditCoInsuredInfo {
                hSection {
                    CoInsuredInfoView(
                        text: L10n.contractCoinsuredAddPersonalInfo,
                        config: .init(contract: contract, fromInfoCard: true)
                    )
                    .padding(.bottom, .padding16)
                    .accessibilityElement(children: .combine)
                }
                .accessibilityElement(children: .combine)
            }
        }
    }

    @ViewBuilder
    private func getAccessoryView(contract: Contract, coInsured: CoInsuredModel) -> some View {
        if contract.showEditCoInsuredInfo, coInsured.terminatesOn == nil {
            hCoreUIAssets.warningTriangleFilledSmall.view
        } else {
            EmptyView()
        }
    }

    @ViewBuilder
    private func updatedContractView(_ contract: Contract) -> some View {
        if let upcomingRenewal = contract.upcomingRenewal,
            let days = upcomingRenewal.renewalDate.localDateToDate?.daysBetween(start: Date()),
            URL(string: upcomingRenewal.certificateUrl) != nil
        {
            hSection {
                InfoCard(
                    text: days == 1
                        ? L10n.dashboardRenewalPrompterBodyTomorrow : L10n.dashboardRenewalPrompterBody(days + 1),
                    type: .info
                )
                .buttons([
                    .init(
                        buttonTitle: L10n.dashboardRenewalPrompterBodyButton,
                        buttonAction: {
                            contractsNavigationVm.document = hPDFDocument(
                                displayName: L10n.insuranceCertificateTitle,
                                url: upcomingRenewal.certificateUrl ?? "",
                                type: .unknown
                            )
                        }
                    )
                ])
            }
        } else if let upcomingChangedAgreement = contract.upcomingChangedAgreement,
            URL(string: upcomingChangedAgreement.certificateUrl) != nil
        {
            hSection {
                InfoCard(
                    text: L10n.InsurancesTab.yourInsuranceWillBeUpdated(
                        upcomingChangedAgreement.agreementDate.activeFrom?.localDateToDate?
                            .displayDateDDMMMYYYYFormat ?? ""
                    ),
                    type: .info
                )
                .buttons([
                    .init(
                        buttonTitle: L10n.InsurancesTab.viewDetails,
                        buttonAction: {
                            contractsNavigationVm.insuranceUpdate = upcomingChangedAgreement
                        }
                    )
                ])
            }
        } else if let upcomingChangedAgreement = contract.upcomingChangedAgreement,
            upcomingChangedAgreement.certificateUrl == nil
        {
            Rectangle()
                .onAppear {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                        store.send(.fetchContracts)
                    }
                }
                .frame(height: 0)
                .id(UUID().uuidString)
        }
    }

    @ViewBuilder
    private func moveAddressButton(contract: Contract) -> some View {
        let contractsThatSupportsMoving = store.state.activeContracts.filter(\.supportsAddressChange)
        if contract.supportsAddressChange, featureFlags.isMovingFlowEnabled,
            contractsThatSupportsMoving.count < 2, !contract.isTerminated
        {
            hSection {
                hButton(
                    .large,
                    .ghost,
                    content: .init(title: L10n.InsuranceDetails.moveButton),
                    {
                        contractsNavigationVm.isChangeAddressPresented = true
                    }
                )
            }
            .sectionContainerStyle(.transparent)
        }
    }
}

@MainActor
private class ContractsInformationViewModel: ObservableObject {
    func getListToDisplay(contract: Contract) -> [CoInsuredListType] {
        contract.coInsured
            .map {
                CoInsuredListType(
                    coInsured: $0,
                    date: $0.activatesOn ?? $0.terminatesOn,
                    locallyAdded: false
                )
            }
    }

    @MainActor
    func getButtonText(_ contract: Contract) -> String {
        if contract.onlyCoInsured() {
            return L10n.contractEditCoinsured
        } else {
            return L10n.contractEditInfoLabel
        }
    }
}

public struct CoInsuredInfoView: View {
    @EnvironmentObject private var contractsNavigationVm: ContractsNavigationViewModel

    let text: String
    let config: InsuredPeopleConfig
    public init(
        text: String,
        config: InsuredPeopleConfig
    ) {
        self.text = text
        self.config = config
    }

    public var body: some View {
        InfoCard(text: text, type: .attention)
            .buttons([
                .init(
                    buttonTitle: L10n.contractCoinsuredMissingAddInfo,
                    buttonAction: { [weak contractsNavigationVm] in
                        contractsNavigationVm?.editCoInsuredVm.start(fromContract: config)
                    }
                )
            ])
    }
}
