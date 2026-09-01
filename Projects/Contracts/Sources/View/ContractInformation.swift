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
                    hSection(contract.getDisplayItems()) { item in
                        ContractDisplayItemRow(item: item) { stakeholderItem in
                            stakeholderRow(stakeholderItem, contract: contract)
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

    private func stakeholderRow(_ stakeholderItem: StakeholderItem?, contract: Contract) -> some View {
        hRow {
            if let stakeholderItem {
                let isEditable = contract.canEditStakeholder(stakeholderItem.stakeholder)
                if stakeholderItem.stakeholder.hasMissingInfo {
                    StakeholderField(
                        accessoryView: missingInfoAccessory(isEditable: isEditable),
                        date: stakeholderItem.stakeholder.terminatesOn
                            ?? stakeholderItem.stakeholder.activatesOn,
                        stakeholderType: stakeholderItem.stakeholderType
                    )
                    .onTapGesture {
                        guard isEditable else { return }
                        let config: StakeholdersConfig = .init(
                            contract: contract,
                            stakeholderType: stakeholderItem.stakeholderType,
                            fromInfoCard: false
                        )
                        contractsNavigationVm.editStakeholdersVm.start(fromContract: config)
                    }
                    .accessibilityAddTraits(.isButton)
                } else {
                    StakeholderField(
                        stakeholder: stakeholderItem.stakeholder,
                        accessoryView: EmptyView(),
                        date: stakeholderItem.date,
                        stakeholderType: stakeholderItem.stakeholderType
                    )
                }
            } else {
                ContractOwnerField(
                    enabled: true,
                    fullName: contract.fullName,
                    SSN: contract.ssn ?? ""
                )
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
    private func missingInfoAccessory(isEditable: Bool) -> some View {
        if isEditable {
            hCoreUIAssets.warningTriangleFilledSmall.view
                .foregroundColor(hSignalColor.Amber.element)
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
    fileprivate var showEditInfoButtonText: String {
        switch true {
        case onlyCoInsured(): L10n.contractEditCoinsured
        case onlyCoOwners(): L10n.editCoownerTitle
        default: L10n.contractEditInfoLabel
        }
    }

    /// A stakeholder row is only actionable while the contract allows editing and the person is not being removed.
    fileprivate func canEditStakeholder(_ stakeholder: Stakeholder) -> Bool {
        (showEditCoInsuredInfo || showEditCoOwnersInfo) && stakeholder.terminatesOn == nil
    }
}
