import SwiftUI
import hCore
import hCoreUI

struct InsuredPeopleScreen: View {
    @EnvironmentObject private var editCoInsuredNavigation: EditCoInsuredNavigationViewModel
    @ObservedObject var vm: InsuredPeopleScreenViewModel
    @ObservedObject var intentViewModel: IntentViewModel
    let type: CoInsuredFieldType?

    private var listToDisplay: [StakeHolderListType] {
        vm.listToDisplay(type: type, activationDate: intentViewModel.intent?.activationDate)
    }

    var body: some View {
        hForm {
            VStack(spacing: 0) {
                contractOwnerField(hasContentBelow: !listToDisplay.isEmpty || vm.hasContentBelow)
                coInsuredSection(list: listToDisplay)
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
        if vm.showConfirmChangesButton && intentViewModel.intent != nil {
            ConfirmChangesView(editCoInsuredNavigation: editCoInsuredNavigation)
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

    private func coInsuredSection(list: [StakeHolderListType]) -> some View {
        hSection(list) { stakeHolder in
            hRow {
                StakeHolderField(
                    stakeHolder: stakeHolder.stakeHolder,
                    accessoryView: getAccesoryView(coInsured: stakeHolder),
                    statusPill: stakeHolder.type == .added ? .added : nil,
                    date: stakeHolder.date,
                    stakeHolderType: stakeHolder.stakeHolderType
                )
            }
            .accessibilityValue(accessoryType(for: stakeHolder).accessibilityValue)
        }
    }

    @ViewBuilder
    private var buttonSection: (some View)? {
        if vm.config.numberOfMissingStakeHoldersWithoutTermination == 0 {
            hSection {
                hButton(
                    .large,
                    .secondary,
                    content: .init(title: vm.config.stakeHolderType.addButtonTitle),
                    {
                        if !vm.hasExistingStakeHolders {
                            editCoInsuredNavigation.coInsuredInputModel = .init(
                                actionType: .add,
                                coInsuredModel: StakeHolder(),
                                title: vm.config.stakeHolderType.addButtonTitle,
                                contractId: vm.config.contractId
                            )
                        } else {
                            editCoInsuredNavigation.selectCoInsured = .init(id: vm.config.contractId)
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
                    text: vm.config.stakeHolderType.reviewInfo(
                        hasMissingStakeHolders: vm.hasLocallyMissingStakeHolders
                    ),
                    type: infoCardType
                )
            }
        }
    }

    func accessoryType(for coInsured: StakeHolderListType) -> CoInsuredFieldType {
        if coInsured.stakeHolder.hasMissingData, type != .delete {
            .empty
        } else if coInsured.locallyAdded {
            .localEdit
        } else {
            .delete
        }
    }

    @ViewBuilder
    private func getAccesoryView(coInsured: StakeHolderListType) -> some View {
        getAccesoryView(for: accessoryType(for: coInsured), coInsured: coInsured.stakeHolder)
    }

    private func getAccesoryView(for type: CoInsuredFieldType, coInsured: StakeHolder) -> some View {
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
            onAccessoryViewTap(type: type, coInsured: coInsured)
        }
        .accessibilityAddTraits(.isButton)
    }

    private func onAccessoryViewTap(type: CoInsuredFieldType, coInsured: StakeHolder) {
        if type == .empty, vm.hasExistingStakeHolders {
            editCoInsuredNavigation.selectCoInsured = .init(id: vm.config.contractId)
        } else {
            editCoInsuredNavigation.coInsuredInputModel = .init(
                actionType: type.action,
                coInsuredModel: type == .empty ? StakeHolder() : coInsured,
                title: type.title(for: vm.config.stakeHolderType),
                contractId: vm.config.contractId
            )
        }
    }
}

#Preview {
    Dependencies.shared.add(module: Module { () -> DateService in DateService() })
    let config = StakeHoldersConfig(
        id: UUID().uuidString,
        stakeHolders: [
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
        numberOfMissingStakeHolders: 0,
        numberOfMissingStakeHoldersWithoutTermination: 0,
        displayName: "",
        exposureDisplayName: nil,
        preSelectedStakeHolders: [],
        contractDisplayName: "",
        holderFirstName: "First Name",
        holderLastName: "Last Name",
        holderSSN: "00000000-0000",
        fromInfoCard: false,
        stakeHolderType: .coInsured
    )
    let vm = InsuredPeopleScreenViewModel(with: config)
    return InsuredPeopleScreen(vm: vm, intentViewModel: IntentViewModel(), type: .localEdit)
}
