import SwiftUI
import hCore
import hCoreUI

struct InsuredPeopleScreen: View {
    @EnvironmentObject private var editCoInsuredNavigation: EditCoInsuredNavigationViewModel
    @ObservedObject var vm: InsuredPeopleScreenViewModel
    @ObservedObject var intentViewModel: IntentViewModel
    let type: CoInsuredFieldType?

    private var listToDisplay: [CoInsuredListType] {
        vm.listToDisplay(type: type, activationDate: intentViewModel.intent.activationDate)
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

            infoCardSection
        }
        .hFormAttachToBottom {
            bottomContent
        }
    }

    private var bottomContent: some View {
        VStack(spacing: .padding8) {
            hSection {
                if vm.showSavebutton {
                    saveChangesButton
                }

                if vm.showConfirmChangesButton {
                    ConfirmChangesView(editCoInsuredNavigation: editCoInsuredNavigation)
                }
                CancelButton()
                    .disabled(intentViewModel.isLoading)
            }
            .sectionContainerStyle(.transparent)
        }
    }

    private var saveChangesButton: some View {
        hButton(
            .large,
            .primary,
            content: .init(title: L10n.generalSaveChangesButton),
            {
                Task {
                    await intentViewModel.performCoInsuredChanges(
                        commitId: intentViewModel.intent.id
                    )
                }
                editCoInsuredNavigation.showProgressScreenWithoutSuccess = true
                editCoInsuredNavigation.editCoInsuredConfig = nil
            }
        )
        .hButtonIsLoading(intentViewModel.isLoading)
        .disabled(!vm.shouldShowSaveChangesButton)
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

    private func coInsuredSection(list: [CoInsuredListType]) -> some View {
        hSection(list) { coInsured in
            hRow {
                CoInsuredField(
                    coInsured: coInsured.coInsured,
                    accessoryView: getAccesoryView(coInsured: coInsured),
                    statusPill: coInsured.type == .added ? .added : nil,
                    date: coInsured.date
                )
            }
        }
    }

    @ViewBuilder
    private var buttonSection: (some View)? {
        if vm.config.numberOfMissingCoInsuredWithoutTermination == 0 {
            hSection {
                hButton(
                    .large,
                    .secondary,
                    content: .init(title: L10n.contractAddCoinsured),
                    {
                        if !vm.hasExistingCoInsured {
                            editCoInsuredNavigation.coInsuredInputModel = .init(
                                actionType: .add,
                                coInsuredModel: CoInsuredModel(),
                                title: L10n.contractAddCoinsured,
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
        if vm.showInfoCard(type: type) {
            hSection {
                InfoCard(text: L10n.contractAddCoinsuredReviewInfo, type: .attention)
            }
        }
    }

    @ViewBuilder
    private func getAccesoryView(coInsured: CoInsuredListType) -> some View {
        var accessoryType: CoInsuredFieldType {
            if coInsured.coInsured.hasMissingData && type != .delete {
                .empty
            } else if coInsured.locallyAdded {
                .localEdit
            } else {
                .delete
            }
        }
        getAccesoryView(for: accessoryType, coInsured: coInsured.coInsured)
    }

    private func getAccesoryView(for type: CoInsuredFieldType, coInsured: CoInsuredModel) -> some View {
        HStack {
            if let text = type.text {
                hText(text)
            }
            if let icon = type.icon {
                icon.view
                    .foregroundColor(type.iconColor)
            }
        }
        .onTapGesture {
            onAccessoryViewTap(type: type, coInsured: coInsured)
        }
    }

    private func onAccessoryViewTap(type: CoInsuredFieldType, coInsured: CoInsuredModel) {
        if type == .empty && vm.hasExistingCoInsured {
            editCoInsuredNavigation.selectCoInsured = .init(id: vm.config.contractId)
        } else {
            editCoInsuredNavigation.coInsuredInputModel = .init(
                actionType: type.action,
                coInsuredModel: type == .empty ? CoInsuredModel() : coInsured,
                title: type.title,
                contractId: vm.config.contractId
            )
        }
    }
}

#Preview {
    Dependencies.shared.add(module: Module { () -> DateService in DateService() })
    let vm = InsuredPeopleScreenViewModel()
    let config = InsuredPeopleConfig(
        id: UUID().uuidString,
        contractCoInsured: [
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
        numberOfMissingCoInsured: 0,
        numberOfMissingCoInsuredWithoutTermination: 0,
        displayName: "",
        exposureDisplayName: nil,
        preSelectedCoInsuredList: [],
        contractDisplayName: "",
        holderFirstName: "First Name",
        holderLastName: "Last Name",
        holderSSN: "00000000-0000",
        fromInfoCard: false
    )
    vm.initializeCoInsured(with: config)
    return InsuredPeopleScreen(vm: vm, intentViewModel: IntentViewModel(), type: .localEdit)
}
