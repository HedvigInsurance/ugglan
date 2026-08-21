import Contracts
import EditStakeholders
import SwiftUI
import hCore
import hCoreUI

enum OnboardingMissingInfoType {
    case coInsured
    case coOwner
    case petChipIds

    /// The stakeholder edit flow this type maps to, if any.
    var stakeholderType: StakeholderType? {
        switch self {
        case .coInsured: .coInsured
        case .coOwner: .coOwner
        case .petChipIds: nil
        }
    }
}

struct OnboardingMissingInfoScreen: View {
    let type: OnboardingMissingInfoType
    @EnvironmentObject var vm: OnboardingNavigationViewModel
    private var step: OnboardingStep {
        switch type {
        case .coInsured: .coInsured(contracts: contracts)
        case .coOwner: .coOwners(contracts: contracts)
        case .petChipIds: .petChipIds(contracts: contracts)
        }
    }

    /// Read from `vm.steps` rather than the pushed payload, so contracts marked as added
    /// (`missingData` cleared) re-render with the checkmark.
    private var contracts: [OnboardingContract] {
        for step in vm.steps {
            if case let .coInsured(contracts) = step, type == .coInsured { return contracts }
            if case let .coOwners(contracts) = step, type == .coOwner { return contracts }
            if case let .petChipIds(contracts) = step, type == .petChipIds { return contracts }
        }
        return []
    }

    /// Whether any contract still needs info added, gating the "add later" affordances.
    private var hasMissingInfo: Bool {
        contracts.contains(where: { $0.missingData })
    }

    private var headerTitle: String {
        switch type {
        case .coInsured: L10n.onboardingAddCoinsuredTitle
        case .coOwner: L10n.onboardingAddCoownersTitle
        case .petChipIds: L10n.onboardingAddPetChipIdsTitle
        }
    }

    private var subtitle: String {
        switch type {
        case .coInsured, .coOwner: L10n.onboardingMissingInfoSubtitle
        case .petChipIds: L10n.onboardingMissingInfoPetSubtitle
        }
    }

    var body: some View {
        hForm {
            hSection(contracts) { onboardingContract in
                hRow {
                    ContractInformation(
                        title: onboardingContract.contract.currentAgreement?.productVariant.displayName,
                        subtitle: onboardingContract.getSubtitle(),
                        pillowImage: onboardingContract.contract.pillowType?.bgImage
                    )
                }
                .horizontalPadding(.padding12)
                .verticalPadding(.padding12)
                .withCustomAccessory {
                    if !onboardingContract.missingData {
                        ZStack {
                            RoundedRectangle(cornerRadius: .cornerRadiusS)
                                .fill(hSignalColor.Green.element)
                            hCoreUIAssets.checkmark.view
                                .foregroundColor(hTextColor.Opaque.negative)
                        }
                        .frame(width: 20, height: 20)
                        .transition(.scale.animation(.bouncy))
                    } else {
                        hButton(.small, .primary, content: .init(title: L10n.generalAddButton)) {
                            add(onboardingContract)
                        }
                        .accessibilityLabel(
                            L10n.generalAddButton + ", " + onboardingContract.contract.exposureDisplayNameShort
                        )
                        .transition(.scale(scale: 0, anchor: .trailing).combined(with: .opacity).animation(.easeInOut))
                    }
                }
                .hRowContentAlignment(.center)
            }
        }
        .hFormTitle(
            title: .init(.small, .body1, headerTitle, alignment: .leading),
            subTitle: .init(
                .small,
                .body1,
                subtitle,
                alignment: .leading
            )
        )
        .hFormContentPosition(.center)
        .hFormAttachToBottom {
            hSection {
                VStack(spacing: .padding16) {
                    hText(L10n.onboardingAddInfoLaterLabel, style: .label)
                        .foregroundColor(hTextColor.Opaque.secondary)
                        .opacity(hasMissingInfo ? 1 : 0)
                    VStack(spacing: .padding8) {
                        hContinueButton { vm.advance(after: step) }
                    }
                }
            }
            .sectionContainerStyle(.transparent)
        }
        .onReceive(EditStakeholdersViewModel.updatedStakeholderForContractId) { contractId in
            guard let contractId, let stakeholderType = type.stakeholderType else { return }
            Task {
                await delay(1)
                vm.markStakeholderAdded(contractId: contractId, type: stakeholderType)
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: .petChipIdAdded)) { notification in
            guard type == .petChipIds, let model = notification.object as? PetIdAddedModel else { return }
            Task {
                await delay(0.4)
                vm.markPetChipIdAdded(model)
            }
        }
    }

    private func add(_ onboardingContract: OnboardingContract) {
        switch type {
        case .coInsured, .coOwner:
            guard let stakeholderType = type.stakeholderType else { return }
            let contract: StakeholdersConfig = .init(
                contract: onboardingContract.contract,
                stakeholderType: stakeholderType,
                fromInfoCard: true
            )
            vm.editStakeholdersVm.start(fromContract: contract)
        case .petChipIds:
            vm.missingPetChipIdInput = .init(contracts: [onboardingContract.contract])
        }
    }
}

#Preview("Co insured") {
    OnboardingMissingInfoScreen(type: .coInsured)
        .environmentObject(
            {
                let vm = OnboardingNavigationViewModel()
                vm.steps = [
                    .coInsured(contracts: [
                        .init(contract: .mock(id: "id1", exposureName: "Bellmansgatan 19")),
                        .init(contract: .mock(id: "id2", exposureName: "Bellmansgatan 19 2")),
                    ])
                ]
                return vm
            }()
        )
        .task {
            await delay(1)
            EditStakeholdersViewModel.updatedStakeholderForContractId.send("id1")
            await delay(2)
            EditStakeholdersViewModel.updatedStakeholderForContractId.send("id2")
        }
}

#Preview("Co Owners") {
    OnboardingMissingInfoScreen(type: .coOwner)
        .environmentObject(
            {
                let vm = OnboardingNavigationViewModel()
                vm.steps = [
                    .coOwners(contracts: [
                        .init(contract: .mock(id: "id1", exposureName: "Bellmansgatan 19")),
                        .init(contract: .mock(id: "id2", exposureName: "Bellmansgatan 19 2")),
                    ])
                ]
                return vm
            }()
        )
        .task {
            await delay(1)
            EditStakeholdersViewModel.updatedStakeholderForContractId.send("id1")
            await delay(2)
            EditStakeholdersViewModel.updatedStakeholderForContractId.send("id2")
        }
}

#Preview("Pet chip ids") {
    OnboardingMissingInfoScreen(type: .petChipIds)
        .environmentObject(
            {
                let vm = OnboardingNavigationViewModel()
                vm.steps = [
                    .petChipIds(contracts: [
                        .init(contract: .mock(id: "id1", exposureName: "Fido", typeOfContract: .seDogStandard)),
                        .init(contract: .mock(id: "id2", exposureName: "Rex", typeOfContract: .seDogBasic)),
                    ])
                ]
                return vm
            }()
        )
        .task {
            await delay(1)
            NotificationCenter.default.post(
                name: .petChipIdAdded,
                object: PetIdAddedModel(contractId: "id1", chipId: "chip 1")
            )
            await delay(2)
            NotificationCenter.default.post(
                name: .petChipIdAdded,
                object: PetIdAddedModel(contractId: "id2", chipId: "chip 2")
            )
        }
}

@MainActor
extension Contracts.Contract {
    fileprivate static func mock(
        id: String,
        exposureName: String,
        typeOfContract: TypeOfContract = .seHouse
    ) -> Contracts.Contract {
        .init(
            id: id,
            currentAgreement: .init(
                id: id,
                basePremium: .sek(100),
                itemCost: nil,
                displayItems: [],
                productVariant: .init(
                    termsVersion: "",
                    typeOfContract: typeOfContract.rawValue,
                    perils: [],
                    insurableLimits: [],
                    documents: [],
                    displayName: "display name",
                    displayNameTier: "display name tier",
                    tierDescription: "tier description"
                ),
                addonVariant: []
            ),
            exposureDisplayName: exposureName,
            exposureDisplayNameShort: exposureName,
            masterInceptionDate: nil,
            terminationDate: nil,
            supportsAddressChange: true,
            supportsCoInsured: true,
            supportsCoOwners: true,
            supportsTravelCertificate: true,
            supportsChangeTier: true,
            supportsTermination: true,
            upcomingChangedAgreement: nil,
            upcomingRenewal: nil,
            firstName: "first name",
            lastName: "last name",
            ssn: "ssn",
            typeOfContract: typeOfContract,
            coInsured: [.init(needsMissingInfo: true)],
            coOwners: [.init(needsMissingInfo: true)],
            missingPetChipId: true
        )
    }
}
