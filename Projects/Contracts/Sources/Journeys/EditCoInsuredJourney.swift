import Foundation
import Presentation
import hAnalytics
import hCore
import hCoreUI

public class EditCoInsuredJourney {
    @JourneyBuilder
    public static func getScreenForAction(
        for action: ContractAction,
        withHidesBack: Bool = false
    ) -> some JourneyPresentation {
        if withHidesBack {
            getScreen(for: action).hidesBackButton
        } else {
            getScreen(for: action).showsBackButton
        }
    }

    @JourneyBuilder
    private static func getScreen(for action: ContractAction) -> some JourneyPresentation {
        if case let .coInsuredNavigationAction(navigationAction) = action {
            if case let .openInsuredPeopleScreen(contractId) = navigationAction {
                openInsuredPeopleScreen(id: contractId).withJourneyDismissButton
            } else if case let .openInsuredPeopleNewScreen(contractId) = navigationAction {
                openNewInsuredPeopleScreen(id: contractId).withJourneyDismissButton
            } else if case let .openCoInsuredInput(isDeletion, firstName, lastName, personalNumber, title, contractId) =
                navigationAction
            {
                openCoInsuredInput(
                    isDeletion: isDeletion,
                    firstName: firstName,
                    lastName: lastName,
                    personalNumber: personalNumber,
                    title: title,
                    contractId: contractId
                )
            } else if case .dismissEditCoInsuredFlow = navigationAction {
                DismissJourney()
            } else if case let .openCoInsuredProcessScreen(showSuccess) = navigationAction {
                openProgress(showSuccess: showSuccess).hidesBackButton
            } else if case let .openCoInsuredSelectScreen(contractId) = navigationAction {
                openCoInsuredSelectScreen(contractId: contractId)
            } else if case let .openMissingCoInsuredAlert(contractId) = navigationAction {
                openMissingCoInsuredAlert(contractId: contractId)
            } else if case .openErrorScreen = navigationAction {
                openGenericErrorScreen()
            }
        }
    }

    @JourneyBuilder
    public static func openInsuredPeopleScreen(id: String) -> some JourneyPresentation {
        HostingJourney(
            ContractStore.self,
            rootView: InsuredPeopleScreen(contractId: id),
            style: .modally(presentationStyle: .overFullScreen),
            options: [.defaults, .withAdditionalSpaceForProgressBar]
        ) { action in
            getScreen(for: action)
        }
        .configureTitle(L10n.changeAddressCoInsuredLabel)
        .withJourneyDismissButton
    }

    @JourneyBuilder
    public static func openNewInsuredPeopleScreen(id: String) -> some JourneyPresentation {
        HostingJourney(
            ContractStore.self,
            rootView: InsuredPeopleNewScreen(contractId: id),
            style: .modally(presentationStyle: .overFullScreen),
            options: [.defaults, .withAdditionalSpaceForProgressBar]
        ) { action in
            getScreen(for: action)
        }
        .configureTitle(L10n.changeAddressCoInsuredLabel)
        .withJourneyDismissButton
    }

    @JourneyBuilder
    public static func openCoInsuredInput(
        isDeletion: Bool,
        firstName: String?,
        lastName: String?,
        personalNumber: String?,
        title: String,
        contractId: String
    ) -> some JourneyPresentation {
        HostingJourney(
            ContractStore.self,
            rootView: CoInusuredInput(
                isDeletion: isDeletion,
                firstName: firstName,
                lastName: lastName,
                SSN: personalNumber,
                contractId: contractId
            ),
            style: .detented(.scrollViewContentSize),
            options: [.largeNavigationBar, .blurredBackground]
        ) { action in
            if case .coInsuredNavigationAction(.dismissEdit) = action {
                PopJourney()
            } else if case .coInsuredNavigationAction(.deletionSuccess) = action {
                SuccessScreen.journey(with: L10n.contractCoinsuredRemoved)
                    .onPresent {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                            let store: ContractStore = globalPresentableStoreContainer.get()
                            store.send(.coInsuredNavigationAction(action: .dismissEdit))
                        }
                    }
            } else if case .coInsuredNavigationAction(.addSuccess) = action {
                SuccessScreen.journey(with: L10n.contractCoinsuredAdded)
                    .onPresent {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                            let store: ContractStore = globalPresentableStoreContainer.get()
                            store.send(.coInsuredNavigationAction(action: .dismissEdit))
                        }
                    }
            } else {
                getScreen(for: action)
            }
        }
        .configureTitle(title)
        .onAction(ContractStore.self) { action in
            if case .coInsuredNavigationAction(action: .dismissEdit) = action {
                PopJourney()
            }
        }
    }

    @JourneyBuilder
    public static func openProgress(showSuccess: Bool) -> some JourneyPresentation {
        HostingJourney(
            ContractStore.self,
            rootView: CoInsuredProcessingScreen(showSuccessScreen: showSuccess)
        ) { action in
            getScreen(for: action)
        }
    }

    @JourneyBuilder
    public static func openRemoveCoInsuredScreen(id: String) -> some JourneyPresentation {
        HostingJourney(
            ContractStore.self,
            rootView: RemoveCoInsuredScreen(contractId: id)
        ) { action in
            getScreen(for: action)
        }
    }

    @JourneyBuilder
    public static func openGenericErrorScreen() -> some JourneyPresentation {
        HostingJourney(
            ContractStore.self,
            rootView: CoInsuredErrorScreen()
        ) { action in
            getScreen(for: action)
        }
    }

    @JourneyBuilder
    public static func openMissingCoInsuredAlert(contractId: String) -> some JourneyPresentation {
        HostingJourney(
            ContractStore.self,
            rootView: CoInsuredMissingAlertView(contractId: contractId),
            style: .detented(.scrollViewContentSize),
            options: [.largeNavigationBar, .blurredBackground]
        ) { action in
            getScreen(for: action)
        }
        .onAction(ContractStore.self) { action in
            if case .coInsuredNavigationAction(action: .dismissEdit) = action {
                PopJourney()
            } else {
                getScreen(for: action)
            }
        }
    }

    @JourneyBuilder
    public static func openSelectInsurance(contractIds: [String]) -> some JourneyPresentation {
        HostingJourney(
            ContractStore.self,
            rootView: CheckboxPickerScreen<Contract>(
                items: {
                    let contractStore: ContractStore = globalPresentableStoreContainer.get()
                    let contracts: [Contract] = contractIds.compactMap { id in
                        contractStore.state.contractForId(id)
                    }
                    return contracts.compactMap({
                        (object: $0, displayName: $0.currentAgreement?.productVariant.displayName ?? "")
                    })
                }(),
                preSelectedItems: {
                    let contractStore: ContractStore = globalPresentableStoreContainer.get()
                    let preSelectedItem = contractStore.state.contractForId(contractIds.first ?? "")
                    if let preSelectedItem {
                        return [preSelectedItem]
                    } else {
                        return []
                    }
                },
                onSelected: { selectedContract in
                    let store: ContractStore = globalPresentableStoreContainer.get()
                    store.send(
                        .coInsuredNavigationAction(
                            action: .openInsuredPeopleNewScreen(contractId: selectedContract.first?.id ?? "")
                        )
                    )
                },
                onCancel: {
                    let contractStore: ContractStore = globalPresentableStoreContainer.get()
                    contractStore.send(.coInsuredNavigationAction(action: .dismissEdit))
                },
                singleSelect: true
            ),
            style: .detented(.scrollViewContentSize),
            options: [.largeNavigationBar, .blurredBackground]
        ) { action in
            getScreen(for: action)
        }
    }

    @JourneyBuilder
    public static func openCoInsuredSelectScreen(contractId: String) -> some JourneyPresentation {
        HostingJourney(
            ContractStore.self,
            rootView: CheckboxPickerScreen<CoInsuredModel>(
                items: {
                    let contractStore: ContractStore = globalPresentableStoreContainer.get()
                    return contractStore.state.fetchAllCoInsured.compactMap { ((object: $0, displayName: $0.fullName)) }
                }(),
                preSelectedItems: {
                    let contractStore: ContractStore = globalPresentableStoreContainer.get()
                    let preSelectedItem = contractStore.state.fetchAllCoInsured.first
                    if let preSelectedItem {
                        return [preSelectedItem]
                    } else {
                        return []
                    }
                },
                onSelected: { selectedContract in
                    let store: ContractStore = globalPresentableStoreContainer.get()
                    store.coInsuredViewModel.addCoInsured(
                        firstName: selectedContract.first?.firstName ?? "",
                        lastName: selectedContract.first?.lastName ?? "",
                        personalNumber: selectedContract.first?.SSN ?? ""
                    )
                    store.send(.coInsuredNavigationAction(action: .dismissEdit))
                },
                onCancel: {
                    let contractStore: ContractStore = globalPresentableStoreContainer.get()
                    contractStore.send(.coInsuredNavigationAction(action: .dismissEdit))
                },
                singleSelect: true,
                actionOnAddedOption: {
                    let contractStore: ContractStore = globalPresentableStoreContainer.get()
                    contractStore.send(
                        .coInsuredNavigationAction(
                            action: .openCoInsuredInput(
                                isDeletion: false,
                                firstName: nil,
                                lastName: nil,
                                personalNumber: nil,
                                title: L10n.contractAddCoinsured,
                                contractId: contractId
                            )
                        )
                    )
                }
            ),
            style: .detented(.scrollViewContentSize),
            options: [.largeNavigationBar, .blurredBackground]
        ) { action in
            if case .coInsuredNavigationAction(action: .dismissEdit) = action {
                PopJourney()
            } else {
                getScreen(for: action)
            }
        }
        .configureTitle(L10n.contractAddConisuredInfo)
    }
}
