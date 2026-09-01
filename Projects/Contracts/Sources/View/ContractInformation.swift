import Addons
import AppStateContainer
import Combine
import EditStakeholders
import Foundation
import SwiftUI
import UnleashProxyClientSwift
import hCore
import hCoreUI

struct ContractInformationView: View {
    @AppObservedObject var store: ContractStore
    @EnvironmentObject private var contractsNavigationVm: ContractsNavigationViewModel
    let id: String
    var body: some View {
        Group {
            if let contract = store.contractForId(id) {
                VStack(spacing: .padding16) {
                    updatedContractView(contract)
                        .transition(.opacity.combined(with: .scale))
                    hSection(contract.getDisplayItems()) { element in
                        switch element.type {
                        case let .coinsured(coInsured):
                            hRow {
                                if let coInsured {
                                    if coInsured.stakeholder.hasMissingInfo {
                                        StakeholderField(
                                            accessoryView: getAccessoryView(
                                                contract: contract,
                                                stakeholder: coInsured.stakeholder
                                            )
                                            .foregroundColor(hSignalColor.Amber.element),
                                            date: coInsured.stakeholder.terminatesOn
                                                ?? coInsured.stakeholder.activatesOn,
                                            stakeholderType: coInsured.stakeholderType,
                                        )
                                        .onTapGesture {
                                            if (contract.showEditCoInsuredInfo || contract.showEditCoOwnersInfo),
                                                coInsured.stakeholder.terminatesOn == nil
                                            {
                                                let contract: StakeholdersConfig = .init(
                                                    contract: contract,
                                                    stakeholderType: coInsured.stakeholderType,
                                                    fromInfoCard: false
                                                )
                                                contractsNavigationVm.editStakeholdersVm.start(fromContract: contract)
                                            }
                                        }
                                        .accessibilityAddTraits(.isButton)
                                        .accessibilityAddTraits(
                                            {
                                                if (contract.showEditCoInsuredInfo || contract.showEditCoOwnersInfo)
                                                    && coInsured.stakeholder.terminatesOn == nil
                                                {
                                                    return .isButton
                                                }
                                                return AccessibilityTraits()
                                            }()
                                        )
                                    } else {
                                        StakeholderField(
                                            stakeholder: coInsured.stakeholder,
                                            accessoryView: EmptyView(),
                                            date: coInsured.date,
                                            stakeholderType: coInsured.stakeholderType,
                                        )
                                    }
                                } else {
                                    ContractOwnerField(
                                        enabled: true,
                                        hasContentBelow: false,
                                        fullName: contract.fullName,
                                        SSN: contract.ssn ?? ""
                                    )
                                }
                            }
                        case let .itemCost(cost):
                            hRow {
                                ItemCostView(itemCost: cost)
                            }
                        case let .regular(title, value, subtitle):
                            hRow {
                                VStack(alignment: .leading, spacing: 0) {
                                    hText(title)
                                    if let subtitle {
                                        hText(subtitle, style: .label)
                                            .foregroundColor(hTextColor.Translucent.secondary)
                                    }
                                }
                            }
                            .withCustomAccessory {
                                Group {
                                    Spacer()
                                    if let date = value.localDateToDate?.displayDateDDMMMYYYYFormat {
                                        hText(date)
                                    } else {
                                        ZStack {
                                            hText(value)
                                            hText(" ")
                                        }
                                    }
                                }
                                .foregroundColor(hTextColor.Opaque.secondary)
                            }
                            .accessibilityElement(children: .combine)
                        }
                    }
                    .sectionContainerStyle(.opaque)
                    .hWithoutHorizontalPadding([.section])

                    missingStakeholderInfoCards(for: contract)
                    missingPetIdInfoCard(for: contract)

                    addonsView(contract: contract)

                    VStack(spacing: .padding8) {
                        if contract.showEditInfo {
                            hButton(
                                .large,
                                .secondary,
                                content: .init(title: contract.showEditInfoButtonText)
                            ) {
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
                        }
                        moveAddressButton(contract: contract)
                    }
                }
                .padding(.horizontal, .padding16)
                .padding(.bottom, .padding16)
            }
        }
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
    private func missingStakeholderInfoCards(for contract: Contract) -> some View {
        if contract.showEditCoInsuredInfo && contract.nbOfMissingCoInsuredWithoutTermination > 0 {
            MissingStakeholderInfoCard(contract: contract, type: .coInsured)
        }

        if contract.showEditCoOwnersInfo && contract.nbOfMissingCoOwnersWithoutTermination > 0 {
            MissingStakeholderInfoCard(contract: contract, type: .coOwner)
        }
    }

    @ViewBuilder
    private func missingPetIdInfoCard(for contract: Contract) -> some View {
        if contract.missingPetChipId {
            MissingPetChipIdInfoCard { [weak contractsNavigationVm] in
                contractsNavigationVm?.missingPetChipIdInput = .init(contracts: [contract])
            }
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
                    .accessibilityHint(L10n.voiceoverPressTo + " " + L10n.contractOverviewAddonAdd)
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
                    Task {
                        await delay(5)
                        await store.fetchContracts()
                    }
                }
                .frame(height: 0)
                .id(UUID().uuidString)
        }
    }

    @ViewBuilder
    private func moveAddressButton(contract: Contract) -> some View {
        let contractsThatSupportsMoving = store.activeContracts.filter(\.supportsAddressChange)
        if contract.supportsAddressChange,
            contractsThatSupportsMoving.count < 2, !contract.isTerminated
        {
            hButton(
                .large,
                .ghost,
                content: .init(title: L10n.InsuranceDetails.moveButton)
            ) { contractsNavigationVm.isChangeAddressPresented = true }
        }
    }
}

extension Stakeholder {
    func asStakeholderItem(type: StakeholderType) -> StakeholderItem {
        .init(
            stakeholder: self,
            stakeholderType: type,
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
}

#Preview {
    Dependencies.shared.add(module: Module { () -> DateService in DateService() })
    Dependencies.shared.add(module: Module { () -> FeatureFlags in FeatureFlags.shared })
    Dependencies.shared.add(module: Module { () -> FetchContractsClient in FetchContractsClientDemo() })

    let store: ContractStore = globalAppStateContainer.get()
    Task { await store.fetchContracts() }

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

extension Contract {
    func getDisplayItems() -> [ContractInformationDisplayItem] {
        var items = [ContractInformationDisplayItem]()
        if let displayItems = currentAgreement?.getDisplayItems() {
            items.append(contentsOf: displayItems)
        }
        if supportsCoInsured || supportsCoOwners {
            items.append(
                .init(
                    id: "owner",
                    type: .coinsured(
                        item: nil
                    )
                )
            )
            for stakeholder in stakeholderItems() {
                items.append(.init(id: stakeholder.id, type: .coinsured(item: stakeholder)))
            }
        }
        return items
    }
}

extension Agreement {
    func getDisplayItems() -> [ContractInformationDisplayItem] {
        let displayItems = displayItems.map { displayItem in
            ContractInformationDisplayItem(
                id: displayItem.id,
                type: .regular(
                    title: displayItem.displayTitle,
                    value: displayItem.displayValue,
                    subtitle: displayItem.displaySubtitle
                )
            )
        }

        let itemCostDisplayItem = itemCost.map({ itemCost in
            ContractInformationDisplayItem(id: "itemCost", type: .itemCost(cost: itemCost))
        })
        if let itemCostDisplayItem {
            return displayItems + [itemCostDisplayItem]
        }
        return displayItems
    }
}

struct ContractInformationDisplayItem: Identifiable {
    let id: String
    let type: ContractInformationDisplayItemType

    enum ContractInformationDisplayItemType {
        case coinsured(item: StakeholderItem?)
        case itemCost(cost: ItemCost)
        case regular(title: String, value: String, subtitle: String?)
    }
}

extension Contract {
    fileprivate func stakeholderItems() -> [StakeholderItem] {
        coInsured.map { $0.asStakeholderItem(type: .coInsured) }
            + coOwners.map { $0.asStakeholderItem(type: .coOwner) }
    }

    fileprivate var showEditInfoButtonText: String {
        switch true {
        case onlyCoInsured(): L10n.contractEditCoinsured
        case onlyCoOwners(): L10n.editCoownerTitle
        default: L10n.contractEditInfoLabel
        }
    }
}
