import SwiftUI
import hCore
import hCoreUI

struct StakeholdersScreen: View {
    @EnvironmentObject private var editStakeholdersNavigation: EditStakeholdersNavigationViewModel
    @ObservedObject var vm: StakeholdersViewModel
    @ObservedObject var intentViewModel: IntentViewModel
    let type: StakeholderFieldType?

    private var displayItems: [StakeholderItem] {
        vm.items(for: type, activationDate: intentViewModel.intent?.activationDate)
    }

    var body: some View {
        hForm {
            VStack(spacing: 0) {
                contractOwnerField(hasContentBelow: !displayItems.isEmpty || vm.hasContentBelow)
                stakeholderSection(list: displayItems)
                buttonSection
            }
            .hWithoutHorizontalPadding([.section])
            .sectionContainerStyle(.transparent)
            .padding(.bottom, .padding6)

            infoCardSection
        }
        .hFormAttachToBottom {
            bottomContent
        }
    }

    private var bottomContent: some View {
        hSection {
            VStack(spacing: .padding8) {
                buttonView
                CancelButton()
                    .disabled(intentViewModel.isLoading)
            }
        }
        .sectionContainerStyle(.transparent)
    }

    @ViewBuilder
    private var buttonView: some View {
        if vm.showConfirmChangesButton {
            ConfirmChangesView(editStakeholdersNavigation: editStakeholdersNavigation)
        }
    }

    private func contractOwnerField(hasContentBelow: Bool) -> some View {
        hSection {
            ContractOwnerField(
                hasContentBelow: hasContentBelow,
                config: vm.config
            )
            .padding(.top, .padding16)
        }
    }

    private func stakeholderSection(list: [StakeholderItem]) -> some View {
        hSection(list) { item in
            hRow {
                StakeholderField(
                    stakeholder: item.stakeholder,
                    accessoryView: getAccessoryView(stakeholder: item),
                    statusPill: item.type == .added ? .added : nil,
                    date: item.date,
                    stakeholderType: item.stakeholderType
                )
            }
            .accessibilityValue(accessoryType(for: item).accessibilityValue)
        }
    }

    @ViewBuilder
    private var buttonSection: (some View)? {
        if vm.config.numberOfMissingStakeholdersWithoutTermination == 0 {
            hSection {
                hButton(
                    .large,
                    .secondary,
                    content: .init(title: vm.config.stakeholderType.addButtonTitle),
                    {
                        if !vm.hasExistingStakeholders {
                            editStakeholdersNavigation.stakeholderInputModel = .init(
                                actionType: .add,
                                stakeholderModel: Stakeholder(),
                                title: vm.config.stakeholderType.addButtonTitle,
                                contractId: vm.config.contractId
                            )
                        } else {
                            editStakeholdersNavigation.selectStakeholder = .init(id: vm.config.contractId)
                        }
                    }
                )
            }
            .hWithoutHorizontalPadding([.row])
        }
    }

    @ViewBuilder
    private var infoCardSection: some View {
        if let infoCardType = vm.getInfoCardType(type: type) {
            hSection {
                InfoCard(
                    text: vm.config.stakeholderType.reviewInfo(
                        hasMissingStakeholders: vm.hasLocallyMissingStakeholders
                    ),
                    type: infoCardType
                )
            }
        }
    }

    func accessoryType(for stakeholder: StakeholderItem) -> StakeholderFieldType {
        if stakeholder.stakeholder.hasMissingData, type != .delete {
            .empty
        } else if stakeholder.locallyAdded {
            .localEdit
        } else {
            .delete
        }
    }

    @ViewBuilder
    private func getAccessoryView(stakeholder: StakeholderItem) -> some View {
        getAccessoryView(for: accessoryType(for: stakeholder), stakeholder: stakeholder.stakeholder)
    }

    private func getAccessoryView(for type: StakeholderFieldType, stakeholder: Stakeholder) -> some View {
        HStack {
            if let text = type.text {
                hText(text)
                    .accessibilityHidden(true)
            }
            if let icon = type.icon {
                icon.view
                    .foregroundColor(type.iconColor)
            }
        }
        .onTapGesture {
            onAccessoryViewTap(type: type, stakeholder: stakeholder)
        }
        .accessibilityAddTraits(.isButton)
    }

    private func onAccessoryViewTap(type: StakeholderFieldType, stakeholder: Stakeholder) {
        if type == .empty, vm.hasExistingStakeholders {
            editStakeholdersNavigation.selectStakeholder = .init(id: vm.config.contractId)
        } else {
            editStakeholdersNavigation.stakeholderInputModel = .init(
                actionType: type.action,
                stakeholderModel: type == .empty ? Stakeholder() : stakeholder,
                title: type.title(for: vm.config.stakeholderType),
                contractId: vm.config.contractId
            )
        }
    }
}

#Preview {
    Dependencies.shared.add(module: Module { () -> DateService in DateService() })
    let config = StakeholdersConfig(
        id: UUID().uuidString,
        stakeholders: [
            .init(
                firstName: "first name",
                lastName: "last name",
                SSN: "00000000-0000",
                birthDate: "2000-01-01",
                needsMissingInfo: false,
                activatesOn: "2025-04-22",
                terminatesOn: nil
            )
        ],
        contractId: "",
        activeFrom: nil,
        numberOfMissingStakeholders: 0,
        numberOfMissingStakeholdersWithoutTermination: 0,
        displayName: "",
        exposureDisplayName: nil,
        preSelectedStakeholders: [],
        contractDisplayName: "",
        holderFirstName: "First Name",
        holderLastName: "Last Name",
        holderSSN: "00000000-0000",
        fromInfoCard: false,
        stakeholderType: .coInsured
    )
    let vm = StakeholdersViewModel(with: config)
    return StakeholdersScreen(vm: vm, intentViewModel: IntentViewModel(), type: .localEdit)
}
