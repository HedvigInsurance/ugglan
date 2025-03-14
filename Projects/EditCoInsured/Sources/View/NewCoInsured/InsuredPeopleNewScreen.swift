import EditCoInsuredShared
import SwiftUI
import hCore
import hCoreUI
import hGraphQL

struct InsuredPeopleNewScreen: View {
    @ObservedObject var vm: InsuredPeopleNewScreenModel
    @EnvironmentObject private var editCoInsuredNavigation: EditCoInsuredNavigationViewModel
    @EnvironmentObject var router: Router
    @ObservedObject var intentViewModel: IntentViewModel
    var body: some View {
        hForm {
            VStack(spacing: 0) {
                let listToDisplay = listToDisplay()
                let hasContentBelow = !listToDisplay.isEmpty

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
                .hWithoutHorizontalPadding([.section])
                .sectionContainerStyle(.transparent)

                hSection {
                    ForEach(Array(listToDisplay.enumerated()), id: \.0) {
                        index,
                        coInsured in
                        hRow {
                            CoInsuredField(
                                coInsured: coInsured.coInsured,
                                accessoryView: getAccView(coInsured: coInsured),
                                title: coInsured.coInsured.hasMissingData ? L10n.contractCoinsured : nil,
                                subTitle: coInsured.coInsured.hasMissingData ? L10n.contractNoInformation : nil
                            )
                        }
                        if index != listToDisplay.count - 1 {
                            hRowDivider()
                        }
                    }
                }
                .hWithoutHorizontalPadding([.section])
                .sectionContainerStyle(.transparent)

                if vm.coInsuredAdded.count >= vm.config.numberOfMissingCoInsured {
                    hSection {
                        InfoCard(text: L10n.contractAddCoinsuredReviewInfo, type: .attention)
                    }
                }
            }
        }
        .hFormAttachToBottom {
            VStack(spacing: 8) {
                let nbOfMissingCoInsured = vm.config.numberOfMissingCoInsuredWithoutTermination
                if vm.coInsuredAdded.count >= nbOfMissingCoInsured {
                    hSection {
                        hButton.LargeButton(type: .primary) {
                            Task {
                                await intentViewModel.performCoInsuredChanges(
                                    commitId: intentViewModel.intent.id
                                )
                            }
                            editCoInsuredNavigation.showProgressScreenWithoutSuccess = true
                            editCoInsuredNavigation.editCoInsuredConfig = nil
                        } content: {
                            hText(L10n.generalSaveChangesButton)
                        }
                        .hButtonIsLoading(intentViewModel.isLoading)
                        .disabled(
                            (vm.config.contractCoInsured.count + vm.coInsuredAdded.count)
                                < nbOfMissingCoInsured
                        )
                    }
                    .sectionContainerStyle(.transparent)
                }

                hButton.LargeButton(type: .ghost) {
                    router.dismiss()
                } content: {
                    hText(L10n.generalCancelButton)
                }
                .disabled(intentViewModel.isLoading)
            }
        }
    }

    @ViewBuilder
    func getAccView(coInsured: CoInsuredListType) -> some View {
        if coInsured.coInsured.hasMissingData {
            emptyAccessoryView
        } else {
            localAccessoryView(coInsured: coInsured.coInsured)
        }
    }

    @ViewBuilder
    func localAccessoryView(coInsured: CoInsuredModel) -> some View {
        hText(L10n.Claims.Edit.Screen.title)
            .onTapGesture {
                editCoInsuredNavigation.coInsuredInputModel = .init(
                    actionType: .edit,
                    coInsuredModel: coInsured,
                    title: L10n.contractAddConisuredInfo,
                    contractId: vm.config.contractId
                )
            }
    }

    @ViewBuilder
    var emptyAccessoryView: some View {
        HStack {
            hText(L10n.generalAddInfoButton)
            Image(uiImage: hCoreUIAssets.plusSmall.image)
        }
        .onTapGesture {
            let hasExistingCoInsured = vm.config.preSelectedCoInsuredList.filter { !vm.coInsuredAdded.contains($0) }
            if !hasExistingCoInsured.isEmpty {
                editCoInsuredNavigation.selectCoInsured = .init(id: vm.config.contractId)
            } else {
                editCoInsuredNavigation.coInsuredInputModel = .init(
                    actionType: .add,
                    coInsuredModel: CoInsuredModel(),
                    title: L10n.contractAddConisuredInfo,
                    contractId: vm.config.contractId
                )
            }
        }
    }

    func listToDisplay() -> [CoInsuredListType] {
        var finalList: [CoInsuredListType] = []
        var addedCoInsured: [CoInsuredListType] = []

        vm.coInsuredAdded.forEach {
            addedCoInsured.append(CoInsuredListType(coInsured: $0, type: .added, locallyAdded: true))
        }

        let nbOfMissingCoInsured = vm.config.numberOfMissingCoInsuredWithoutTermination
        if vm.coInsuredAdded.count < nbOfMissingCoInsured {
            let nbOfFields = nbOfMissingCoInsured - vm.coInsuredAdded.count
            for _ in 1...nbOfFields {
                finalList.append(CoInsuredListType(coInsured: CoInsuredModel(), type: nil, locallyAdded: false))
            }
        }
        return addedCoInsured + finalList
    }
}

struct InsuredPeopleScreenNew_Previews: PreviewProvider {
    static var previews: some View {
        let vm = InsuredPeopleNewScreenModel()
        let config = InsuredPeopleConfig(
            id: UUID().uuidString,
            contractCoInsured: [],
            contractId: "",
            activeFrom: nil,
            numberOfMissingCoInsured: 0,
            numberOfMissingCoInsuredWithoutTermination: 0,
            displayName: "",
            preSelectedCoInsuredList: [],
            contractDisplayName: "",
            holderFirstName: "",
            holderLastName: "",
            holderSSN: nil,
            fromInfoCard: false
        )
        vm.initializeCoInsured(with: config)
        return InsuredPeopleScreen(vm: vm, intentViewModel: .init())
    }
}
