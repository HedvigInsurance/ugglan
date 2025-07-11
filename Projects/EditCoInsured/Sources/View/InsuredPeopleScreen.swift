import EditCoInsuredShared
import SwiftUI
import hCore
import hCoreUI

struct InsuredPeopleScreen: View {
    @EnvironmentObject private var editCoInsuredNavigation: EditCoInsuredNavigationViewModel
    @ObservedObject var vm: InsuredPeopleScreenViewModel
    @ObservedObject var intentViewModel: IntentViewModel
    let type: CoInsuredFieldType?

    var body: some View {
        hForm {
            VStack(spacing: 0) {
                let listToDisplay = vm.listToDisplay(type: type, activationDate: intentViewModel.intent.activationDate)

                let hasContentBelow = vm.nbOfMissingCoInsuredExcludingDeleted > 0

                Group {
                    contractOwnerField(hasContentBelow: !listToDisplay.isEmpty || hasContentBelow)
                    coInsuredSection(list: listToDisplay)
                    buttonSection
                }
                .hWithoutHorizontalPadding([.section])
            }
            .sectionContainerStyle(.transparent)

            infoCardSection
        }
        .hFormAttachToBottom {
            VStack(spacing: .padding8) {
                if vm.showSavebutton {
                    saveChangesButton
                }

                if vm.showConfirmChangesButton {
                    ConfirmChangesView(editCoInsuredNavigation: editCoInsuredNavigation)
                }
                hSection {
                    CancelButton()
                        .disabled(intentViewModel.isLoading)
                }
                .sectionContainerStyle(.transparent)
            }
        }
    }

    private var saveChangesButton: some View {
        hSection {
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
            .disabled(
                (vm.config.contractCoInsured.count + vm.coInsuredAdded.count)
                    < vm.config.numberOfMissingCoInsuredWithoutTermination
            )
        }
        .sectionContainerStyle(.transparent)
    }

    private func contractOwnerField(hasContentBelow: Bool) -> some View {
        hSection {
            hRow {
                ContractOwnerField(
                    hasContentBelow: hasContentBelow,
                    config: vm.config
                )
            }
            .verticalPadding(0)
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
                        let hasExistingCoInsured = vm.config.preSelectedCoInsuredList
                            .filter { !vm.coInsuredAdded.contains($0) }
                        if hasExistingCoInsured.isEmpty {
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
        if coInsured.coInsured.hasMissingData && type != .delete {
            getAccesoryView(for: .empty, coInsured: coInsured.coInsured)
        } else if coInsured.locallyAdded {
            getAccesoryView(for: .localEdit, coInsured: coInsured.coInsured)
        } else {
            getAccesoryView(for: .delete, coInsured: coInsured.coInsured)
        }
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
            let hasExistingCoInsured = vm.config.preSelectedCoInsuredList.filter { !vm.coInsuredAdded.contains($0) }
            if type == .empty && !hasExistingCoInsured.isEmpty {
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
