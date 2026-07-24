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

    private var headerTitle: String {
        switch type {
        case .coInsured: "Add co-insured"  // TODO: L10n
        case .coOwner: "Add co-owners"  // TODO: L10n
        case .petChipIds: "Add your pets ID numbers"  // TODO: L10n
        }
    }

    private var subtitle: String {
        switch type {
        case .coInsured, .coOwner: "So we know who's covered by your insurance"  // TODO: L10n
        case .petChipIds: "This makes it easier to help you if something happens"  // TODO: L10n
        }
    }

    var body: some View {
        hForm {
            hSection(contracts) { onboardingContract in
                hRow {
                    ContractInformation(
                        title: onboardingContract.contract.currentAgreement?.productVariant.displayName,
                        subtitle: onboardingContract.contract.exposureDisplayNameShort,
                        pillowImage: onboardingContract.contract.pillowType?.bgImage
                    )
                }
                .withCustomAccessory {
                    if !onboardingContract.missingData {
                        hCoreUIAssets.checkmark.view
                            .foregroundColor(hSignalColor.Green.element)
                            // TODO: L10n
                            .accessibilityLabel(
                                "Added" + ", " + onboardingContract.contract.exposureDisplayNameShort
                            )
                    } else {
                        hButton(.small, .secondary, content: .init(title: L10n.generalAddButton)) {
                            add(onboardingContract)
                        }
                        .accessibilityLabel(
                            L10n.generalAddButton + ", " + onboardingContract.contract.exposureDisplayNameShort
                        )
                    }
                }
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
                    hText("You can add this information later", style: .label)  // TODO: L10n
                        .foregroundColor(hTextColor.Opaque.secondary)
                    VStack(spacing: .padding8) {
                        hContinueButton { vm.advance(after: step) }
                        hButton(.large, .secondary, content: .init(title: "Do this later")) {  // TODO: L10n
                            vm.advance(after: step)
                        }
                    }
                }
            }
            .sectionContainerStyle(.transparent)
        }
        .onReceive(EditStakeholdersViewModel.updatedStakeholderForContractId) { contractId in
            guard let contractId, let stakeholderType = type.stakeholderType else { return }
            vm.markStakeholderAdded(contractId: contractId, type: stakeholderType)
        }
        .onReceive(NotificationCenter.default.publisher(for: .petChipIdAdded)) { notification in
            guard type == .petChipIds, let contractId = notification.object as? String else { return }
            vm.markPetChipIdAdded(contractId: contractId)
        }
    }

    private func add(_ onboardingContract: OnboardingContract) {
        switch type {
        case .coInsured, .coOwner:
            guard let stakeholderType = type.stakeholderType else { return }
            vm.editStakeholdersVm.start(stakeholderType: stakeholderType)
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
            NotificationCenter.default.post(name: .petChipIdAdded, object: "id1")
            await delay(2)
            NotificationCenter.default.post(name: .petChipIdAdded, object: "id2")
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
