import Addons
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

                        addonsView(contract: contract)

                        VStack(spacing: .padding8) {
                            if contract.showEditInfo {
                                hButton(
                                    .large,
                                    .secondary,
                                    content: .init(title: vm.getButtonText(contract)),
                                    {
                                        if contract.onlyCoInsured() {
                                            let contract: StakeHoldersConfig = .init(
                                                contract: contract,
                                                stakeHolderType: .coInsured,
                                                        fromInfoCard: false
                                                    )

                                                    contractsNavigationVm.editCoInsuredVm.start(fromContract: contract)
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
        let nbOfMissingStakeHolders = contract.nbOfMissingCoInsured + contract.nbOfMissingCoOwners
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
                    !vm.getListToDisplay(contract: contract).isEmpty || nbOfMissingStakeHolders > 0
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
                    if item.stakeHolder.hasMissingInfo {
                        StakeHolderField(
                            accessoryView: getAccessoryView(contract: contract, stakeHolder: item.stakeHolder)
                                .foregroundColor(hSignalColor.Amber.element),
                            date: item.stakeHolder.terminatesOn ?? item.stakeHolder.activatesOn,
                            stakeHolderType: item.stakeHolderType,
                        )
                        .onTapGesture {
                            if (contract.showEditCoInsuredInfo || contract.showEditCoOwnersInfo),
                                item.stakeHolder.terminatesOn == nil
                            {
                                let contract: StakeHoldersConfig = .init(
                                    contract: contract,
                                    stakeHolderType: item.stakeHolderType,
                                    fromInfoCard: false
                                )
                                contractsNavigationVm.editCoInsuredVm.start(fromContract: contract)
                            }
                        }
                        .accessibilityAddTraits(.isButton)
                        .accessibilityAddTraits(
                            {
                                if (contract.showEditCoInsuredInfo || contract.showEditCoOwnersInfo)
                                    && item.stakeHolder.terminatesOn == nil
                                {
                                    return .isButton
                                }
                                return AccessibilityTraits()
                            }()
                        )
                    } else {
                        StakeHolderField(
                            stakeHolder: item.stakeHolder,
                            accessoryView: EmptyView(),
                            date: item.date,
                            stakeHolderType: item.stakeHolderType,
                        )
                    }
                }
            }

            stakeHolderSection(
                shouldShow: contract.showEditCoInsuredInfo,
                missingCount: contract.nbOfMissingCoInsuredWithoutTermination,
                contract: contract,
                stakeHolderType: .coInsured,
            )
            stakeHolderSection(
                shouldShow: contract.showEditCoInsuredInfo,
                missingCount: contract.nbOfMissingCoInsuredWithoutTermination,
                contract: contract,
                stakeHolderType: .coOwner,
            )
        }
    }

    @ViewBuilder
    private func stakeHolderSection(
        shouldShow: Bool,
        missingCount: Int,
        contract: Contract,
        stakeHolderType: StakeHolderType,
    ) -> some View {
        if shouldShow && missingCount > 0 {
            hSection {
                CoInsuredInfoView(
                    config: .init(contract: contract, stakeHolderType: stakeHolderType, fromInfoCard: true)
                )
                .padding(.bottom, .padding16)
                .accessibilityElement(children: .combine)
            }
            .accessibilityElement(children: .combine)
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
    private func getAccessoryView(contract: Contract, stakeHolder: StakeHolder) -> some View {
        if (contract.showEditCoInsuredInfo || contract.showEditCoOwnersInfo), stakeHolder.terminatesOn == nil {
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
    func getListToDisplay(contract: Contract) -> [StakeHolderListType] {
        contract.coInsured.map { $0.asCoInsuredListType(stakeHolderType: .coInsured) }
            + contract.coOwners.map { $0.asCoInsuredListType(stakeHolderType: .coOwner) }
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

extension StakeHolder {
    func asCoInsuredListType(stakeHolderType: StakeHolderType) -> StakeHolderListType {
        .init(
            stakeHolder: self,
            stakeHolderType: stakeHolderType,
            date: activatesOn ?? terminatesOn,
            locallyAdded: false
        )
    }
}

public struct CoInsuredInfoView: View {
    @EnvironmentObject private var contractsNavigationVm: ContractsNavigationViewModel

    let config: StakeHoldersConfig
    public init(config: StakeHoldersConfig) {
        self.config = config
    }

    public var body: some View {
        InfoCard(text: config.stakeHolderType.addPersonalInfo, type: .attention)
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
