import SwiftUI
import hCore
import hCoreUI

struct StakeholdersScreen: View {
    @EnvironmentObject private var editStakeholdersNavigation: EditStakeholdersNavigationViewModel
    @ObservedObject var vm: StakeholdersViewModel
    @ObservedObject var intentViewModel: IntentViewModel
    let type: StakeholderFieldType?

    private var displayItems: [StakeholderRowItem] {
        let stakeholders = vm.items(for: type, activationDate: intentViewModel.intent?.activationDate)
        let stakeholderRows = stakeholders.map { stakeholder in
            StakeholderRowItem.stakeholder(
                item: stakeholder,
                // No divider above the add button, so the last person in the list hides its own.
                hidesDivider: stakeholder.id == stakeholders.last?.id
            )
        }
        let showsAddButton = vm.config.numberOfMissingStakeholdersWithoutTermination == 0
        return [.owner] + stakeholderRows + (showsAddButton ? [.add] : [])
    }

    var body: some View {
        hForm {
            hSection(displayItems) { item in
                switch item {
                case .owner:
                    hRow {
                        ContractOwnerField(
                            config: vm.config
                        )
                    }
                case let .stakeholder(stakeholder, hidesDivider):
                    hRow {
                        StakeholderField(
                            stakeholder: stakeholder.stakeholder,
                            accessoryView: getAccessoryView(stakeholder: stakeholder),
                            statusPill: stakeholder.type == .added ? .added : nil,
                            date: stakeholder.date,
                            stakeholderType: stakeholder.stakeholderType
                        )
                    }
                    .shouldHideDivider(hidesDivider)
                    .accessibilityValue(accessoryType(for: stakeholder).accessibilityValue)
                case .add:
                    hRow {
                        hButton(
                            .large,
                            .secondary,
                            content: .init(title: vm.config.stakeholderType.addButtonTitle)
                        ) {
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
                    }
                }
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

private enum StakeholderRowItem: Identifiable {
    case owner
    case stakeholder(item: StakeholderItem, hidesDivider: Bool)
    case add

    var id: String {
        switch self {
        case .owner: "owner"
        case let .stakeholder(item, _): item.id
        case .add: "add"
        }
    }
}
