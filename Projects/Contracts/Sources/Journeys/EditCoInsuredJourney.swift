import Foundation
import Presentation
import hAnalytics
import hCore
import hCoreUI

public class EditCoInsuredJourney {
    @JourneyBuilder
    private static func getScreen(for action: ContractAction) -> some JourneyPresentation {
        if case let .coInsuredNavigationAction(navigationAction) = action {
            if case let .openInsuredPeopleScreen(contractId) = navigationAction {
                openInsuredPeopleScreen(id: contractId).withJourneyDismissButton
            } else if case let .openInsuredPeopleNewScreen(contractId) = navigationAction {
                openNewInsuredPeopleScreen(id: contractId).withJourneyDismissButton
            } else if case let .openCoInsuredInput(isDeletion, coInsuredModel, title, contractId) =
                navigationAction
            {
                openCoInsuredInput(
                    isDeletion: isDeletion,
                    coInsuredModel: coInsuredModel,
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
            } else if case let .openSelectInsuranceScreen(contractIds) = navigationAction {
                openSelectInsurance(contractIds: contractIds)
            }
        }
    }

    @JourneyBuilder
    static func openInsuredPeopleScreen(id: String) -> some JourneyPresentation {
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
    static func openCoInsuredInput(
        isDeletion: Bool,
        coInsuredModel: CoInsuredModel,
        title: String,
        contractId: String
    ) -> some JourneyPresentation {
        HostingJourney(
            ContractStore.self,
            rootView: CoInusuredInput(
                vm: .init(coInsuredModel: coInsuredModel, isDeletion: isDeletion, contractId: contractId)
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
    static func openProgress(showSuccess: Bool) -> some JourneyPresentation {
        HostingJourney(
            ContractStore.self,
            rootView: CoInsuredProcessingScreen(showSuccessScreen: showSuccess)
        ) { action in
            getScreen(for: action)
        }
    }

    @JourneyBuilder
    static func openRemoveCoInsuredScreen(id: String) -> some JourneyPresentation {
        HostingJourney(
            ContractStore.self,
            rootView: RemoveCoInsuredScreen(contractId: id)
        ) { action in
            getScreen(for: action)
        }
    }

    @JourneyBuilder
    static func openGenericErrorScreen() -> some JourneyPresentation {
        HostingJourney(
            ContractStore.self,
            rootView: CoInsuredErrorScreen()
        ) { action in
            getScreen(for: action)
        }
    }

    @JourneyBuilder
    static func openMissingCoInsuredAlert(contractId: String) -> some JourneyPresentation {
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
    static func openCoInsuredSelectScreen(contractId: String) -> some JourneyPresentation {
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
                onSelected: { selectedContracts in
                    if let selectedContract = selectedContracts.first {
                        let store: ContractStore = globalPresentableStoreContainer.get()
                        store.coInsuredViewModel.addCoInsured(
                            .init(
                                firstName: selectedContract.firstName,
                                lastName: selectedContract.lastName,
                                SSN: selectedContract.SSN
                            )
                        )
                        store.send(.coInsuredNavigationAction(action: .dismissEdit))
                    }
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
                                coInsuredModel: .init(),
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

    static func openInitialScreen(contractIds: [String]) {
        let store: ContractStore = globalPresentableStoreContainer.get()
        if contractIds.count > 1 {
            store.send(.coInsuredNavigationAction(action: .openSelectInsuranceScreen(contractIds: contractIds)))
        } else {
            store.send(
                .coInsuredNavigationAction(action: .openInsuredPeopleNewScreen(contractId: contractIds.first ?? ""))
            )
        }
    }
}
