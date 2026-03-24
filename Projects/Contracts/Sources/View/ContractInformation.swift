import Addons
import Combine
import EditStakeholders
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
                VStack(spacing: .padding16) {
                    updatedContractView(contract)
                        .transition(.opacity.combined(with: .scale))

                    if let displayItems = contract.currentAgreement?.displayItems {
                        hSection {
                            hSection(displayItems, id: \.id) { item in
                                hRow {
                                    VStack(alignment: .leading, spacing: 0) {
                                        hText(item.displayTitle)
                                        if let subtitle = item.displaySubtitle {
                                            hText(subtitle, style: .label)
                                                .foregroundColor(hTextColor.Translucent.secondary)
                                        }
                                    }
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
                                    .hWithoutHorizontalPadding([.divider])
                                    .padding(.horizontal, .padding16)
                                ItemCostView(itemCost: currentAgreementCost)
                            }

                            if contract.supportsCoInsured || contract.supportsCoOwners {
                                hRowDivider()
                                    .padding(.horizontal, .padding16)
                                addCoInsuredView(contract: contract)
                            }
                        }
                        .sectionContainerStyle(.opaque)
                        .hWithoutHorizontalPadding([.section])

                        missingStakeholderInfoCards(for: contract)

                        addonsView(contract: contract)

                        VStack(spacing: .padding8) {
                            if contract.showEditInfo {
                                hButton(
                                    .large,
                                    .secondary,
                                    content: .init(title: vm.getButtonText(contract)),
                                    {
                                        if contract.onlyCoInsured() {
                                            let contract: StakeholdersConfig = .init(
                                                contract: contract,
                                                stakeholderType: .coInsured,
                                                fromInfoCard: false
                                            )

                                            contractsNavigationVm.editStakeholdersVm.start(fromContract: contract)
                                        } else {
                                            contractsNavigationVm.changeYourInformationContract = contract
                                        }
                                    }
                                )
                            }
                            moveAddressButton(contract: contract)
                        }
                    }
                }
                .padding(.horizontal, .padding16)
                .padding(.bottom, .padding16)
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
        let nbOfMissingStakeholders = contract.nbOfMissingCoInsured + contract.nbOfMissingCoOwners
        VStack(spacing: 0) {
            hSection {
                if contract.supportsCoInsured {
                    HStack {
                        hRow {
                            insuredField(contract: contract)
                        }
                    }
                }

                let hasContentBelow =
                    !vm.getListToDisplay(contract: contract).isEmpty || nbOfMissingStakeholders > 0
                ContractOwnerField(
                    enabled: true,
                    hasContentBelow: hasContentBelow,
                    fullName: contract.fullName,
                    SSN: contract.ssn ?? ""
                )
                .padding(.top, .padding16)
            }

            hSection(vm.getListToDisplay(contract: contract)) { item in
                hRow {
                    if item.stakeholder.hasMissingInfo {
                        StakeholderField(
                            accessoryView: getAccessoryView(contract: contract, stakeholder: item.stakeholder)
                                .foregroundColor(hSignalColor.Amber.element),
                            date: item.stakeholder.terminatesOn ?? item.stakeholder.activatesOn,
                            stakeholderType: item.stakeholderType,
                        )
                        .onTapGesture {
                            if (contract.showEditCoInsuredInfo || contract.showEditCoOwnersInfo),
                                item.stakeholder.terminatesOn == nil
                            {
                                let contract: StakeholdersConfig = .init(
                                    contract: contract,
                                    stakeholderType: item.stakeholderType,
                                    fromInfoCard: false
                                )
                                contractsNavigationVm.editStakeholdersVm.start(fromContract: contract)
                            }
                        }
                        .accessibilityAddTraits(.isButton)
                        .accessibilityAddTraits(
                            {
                                if (contract.showEditCoInsuredInfo || contract.showEditCoOwnersInfo)
                                    && item.stakeholder.terminatesOn == nil
                                {
                                    return .isButton
                                }
                                return AccessibilityTraits()
                            }()
                        )
                    } else {
                        StakeholderField(
                            stakeholder: item.stakeholder,
                            accessoryView: EmptyView(),
                            date: item.date,
                            stakeholderType: item.stakeholderType,
                        )
                    }
                }
            }
        }
    }

    @ViewBuilder
    private func missingStakeholderInfoCards(for contract: Contract) -> some View {
        if contract.showEditCoInsuredInfo && contract.nbOfMissingCoInsuredWithoutTermination > 0 {
            MissingStakeholderInfoCard(contract: contract, type: .coInsured)
        }

        if contract.showEditCoOwnersInfo && contract.nbOfMissingCoOwnersWithoutTermination > 0 {
            MissingStakeholderInfoCard(contract: contract, type: .coOwner)
        }
    }

    private func presentAddonUpgrade(contract: Contract, addonDisplayName: String) {
        withAnimation(.easeInOut(duration: 0.2)) {
            contractsNavigationVm.isAddonPresented = .init(
                addonSource: .insurances,
                contractInfos: [contract.asAddonContractInfo],
                preselectedAddonTitle: addonDisplayName
            )
        }
    }

    private func presentAddonActions(contract: Contract, addon: ExistingAddon) {
        contractsNavigationVm.addonActionPresented = .init(
            contract: contract,
            displayName: addon.displayName,
            types: addon.availableActions
        )
    }

    @ViewBuilder
    private func addonsView(contract: Contract) -> some View {
        if let addonsData = contract.addonsInfo {
            hSection(addonsData.all) { addon in
                switch (addon) {
                case .available(let available):
                    AddonViewRow(
                        title: available.displayName,
                        subtitle: available.description,
                        actionTitle: L10n.contractOverviewAddonAdd,
                        buttonType: .primaryAlt,
                        action: { presentAddonUpgrade(contract: contract, addonDisplayName: available.displayName) }
                    )
                    .hButtonIsLoading(
                        contractsNavigationVm.isAddonPresented?.preselectedAddonTitle == available.displayName
                    )
                    .accessibilityHint(L10n.voiceoverPressTo + L10n.contractOverviewAddonAdd)
                case .existing(let existing):
                    AddonViewRow(
                        title: existing.displayName,
                        subtitle: existing.description,
                        actionTitle: L10n.contractOverviewAddonIsAdded,
                        buttonType: .secondary,
                        activationDate: existing.startDate?.displayDateDDMMMYYYYFormat,
                        terminationDate: existing.endDate?.displayDateDDMMMYYYYFormat,
                        action: {
                            presentAddonActions(
                                contract: contract,
                                addon: existing
                            )
                        }
                    )
                    .disabled(existing.endDate != nil)
                    .hButtonIsLoading(
                        contractsNavigationVm.isRemoveAddonPresented?.preselectedAddons
                            .contains(existing.displayName) == true
                    )
                    .accessibilityHint(L10n.voiceoverMoreInfo)
                }
            }
            .sectionContainerStyle(.opaque)
            .hWithoutHorizontalPadding([.section])
        }
    }

    @ViewBuilder
    private func getAccessoryView(contract: Contract, stakeholder: Stakeholder) -> some View {
        if (contract.showEditCoInsuredInfo || contract.showEditCoOwnersInfo), stakeholder.terminatesOn == nil {
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
        } else if let upcomingChangedAgreement = contract.upcomingChangedAgreement,
            URL(string: upcomingChangedAgreement.certificateUrl) != nil
        {
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
            hButton(
                .large,
                .ghost,
                content: .init(title: L10n.InsuranceDetails.moveButton),
                {
                    contractsNavigationVm.isChangeAddressPresented = true
                }
            )
        }
    }
}

@MainActor
private class ContractsInformationViewModel: ObservableObject {
    func getListToDisplay(contract: Contract) -> [StakeholderItem] {
        contract.coInsured.map { $0.asCoInsuredListType(stakeholderType: .coInsured) }
            + contract.coOwners.map { $0.asCoInsuredListType(stakeholderType: .coOwner) }
    }

    @MainActor
    func getButtonText(_ contract: Contract) -> String {
        switch true {
        case contract.onlyCoInsured(): L10n.contractEditCoinsured
        case contract.onlyCoOwners(): L10n.editCoownerTitle
        default: L10n.contractEditInfoLabel
        }
    }
}

extension Stakeholder {
    func asCoInsuredListType(stakeholderType: StakeholderType) -> StakeholderItem {
        .init(
            stakeholder: self,
            stakeholderType: stakeholderType,
            date: activatesOn ?? terminatesOn,
            locallyAdded: false
        )
    }
}

public struct MissingStakeholderInfoCard: View {
    @EnvironmentObject private var contractsNavigationVm: ContractsNavigationViewModel

    let config: StakeholdersConfig
    public init(contract: Contract, type: StakeholderType) {
        config = .init(contract: contract, stakeholderType: type, fromInfoCard: true)
    }

    public var body: some View {
        hSection {
            InfoCard(text: config.stakeholderType.addPersonalInfo, type: .attention)
                .buttons([
                    .init(
                        buttonTitle: L10n.contractCoinsuredMissingAddInfo,
                        buttonAction: { [weak contractsNavigationVm] in
                            contractsNavigationVm?.editStakeholdersVm.start(fromContract: config)
                        }
                    )
                ])
                .accessibilityElement(children: .combine)
        }
        .accessibilityElement(children: .combine)
        .hWithoutHorizontalPadding([.section])
    }
}

#Preview {
    Dependencies.shared.add(module: Module { () -> DateService in DateService() })
    Dependencies.shared.add(module: Module { () -> FeatureFlags in FeatureFlags.shared })
    Dependencies.shared.add(module: Module { () -> FetchContractsClient in FetchContractsClientDemo() })

    let store: ContractStore = globalPresentableStoreContainer.get()
    store.send(.fetchContracts)

    return ScrollView { ContractInformationView(id: "contractId") }
        .environmentObject(ContractsNavigationViewModel())
}

extension Contract {
    public var asAddonContractInfo: AddonContractInfo {
        .init(
            contractId: id,
            displayName: currentAgreement?.productVariant.displayName ?? "",
            exposureName: exposureDisplayNameShort
        )
    }
}

public struct AddonAction: Equatable, Identifiable {
    public var id: String { displayName }
    let contract: Contract
    let displayName: String
    let description: String
    let types: [AddonActionType]

    init(contract: Contract, displayName: String, types: [AddonActionType]) {
        self.contract = contract
        self.displayName = displayName
        self.types = types
        self.description = {
            if types.contains(.removal) && types.contains(.upgrade) {
                return L10n.addonFlowUpdateAddonDescription
            } else if types.contains(.removal) {
                return L10n.removeAddonDescription
            } else if types.contains(.upgrade) {
                return L10n.addonFlowUpgradeAddonDescription
            }
            return L10n.removeAddonDescriptionRenewal
        }()
    }

    enum AddonActionType: Identifiable {
        var id: Self { self }

        case upgrade
        case removal

        var title: String {
            switch self {
            case .upgrade: return L10n.addonFlowUpgradeAddon
            case .removal: return L10n.removeAddonButtonTitle
            }
        }
    }
}
