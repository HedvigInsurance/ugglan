import Foundation
import Presentation
import SwiftUI
import hAnalytics
import hCore
import hCoreUI

public class EditCoInsuredJourney {
    @JourneyBuilder
    static func getScreen(for action: ContractAction) -> some JourneyPresentation {
        if case let .coInsuredNavigationAction(navigationAction) = action {
            if case let .openInsuredPeopleScreen(contractId) = navigationAction {
                openInsuredPeopleScreen(id: contractId)
            } else if case let .openInsuredPeopleNewScreen(contractId) = navigationAction {
                openNewInsuredPeopleScreen(id: contractId)
            } else if case let .openCoInsuredInput(actionType, coInsuredModel, title, contractId) = navigationAction {
                openCoInsuredInput(
                    actionType: actionType,
                    coInsuredModel: coInsuredModel,
                    title: title,
                    contractId: contractId,
                    style: .detented(.scrollViewContentSize)
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
    static func openNewInsuredPeopleScreen(id: String) -> some JourneyPresentation {
        HostingJourney(
            ContractStore.self,
            rootView: InsuredPeopleNewScreen(contractId: id),
            style: .modally(presentationStyle: .overFullScreen),
            options: [.defaults, .withAdditionalSpaceForProgressBar, .ignoreActionWhenNotOnTop]
        ) { action in
            getScreen(for: action)
        }
        .configureTitle(L10n.changeAddressCoInsuredLabel)
        .withJourneyDismissButton
    }

    @JourneyBuilder
    static func openCoInsuredInput(
        actionType: CoInsuredAction,
        coInsuredModel: CoInsuredModel,
        title: String,
        contractId: String,
        style: PresentationStyle
    ) -> some JourneyPresentation {
        HostingJourney(
            ContractStore.self,
            rootView: CoInusuredInput(
                vm: .init(coInsuredModel: coInsuredModel, actionType: actionType, contractId: contractId)
            ),
            style: style,
            options: [.largeNavigationBar, .blurredBackground]
        ) { action in
            if case .coInsuredNavigationAction(.dismissEdit) = action {
                DismissJourney()
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
            rootView: CoInsuredProcessingScreen(showSuccessScreen: showSuccess),
            style: .modally(presentationStyle: .overFullScreen),
            options: [.defaults, .withAdditionalSpaceForProgressBar]
        ) { action in
            getScreen(for: action)
        }
    }

    @JourneyBuilder
    static func openRemoveCoInsuredScreen(id: String) -> some JourneyPresentation {
        HostingJourney(
            ContractStore.self,
            rootView: RemoveCoInsuredScreen(contractId: id),
            style: .modally(presentationStyle: .overFullScreen),
            options: [.defaults, .withAdditionalSpaceForProgressBar]
        ) { action in
            getScreen(for: action)
        }
    }

    @JourneyBuilder
    static func openGenericErrorScreen() -> some JourneyPresentation {
        HostingJourney(
            ContractStore.self,
            rootView: CoInsuredErrorScreen(),
            style: .modally(presentationStyle: .overFullScreen),
            options: [.defaults, .withAdditionalSpaceForProgressBar]
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
    static func openSelectInsurance(contractIds: [String]) -> some JourneyPresentation {
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

    static func openCoInsuredSelectScreen(contractId: String) -> some JourneyPresentation {
        HostingJourney(
            ContractStore.self,
            rootView: CoInsuredSelectScreen(contractId: contractId),
            style: .detented(.scrollViewContentSize),
            options: [.largeNavigationBar, .blurredBackground]
        ) { action in
            if case .coInsuredNavigationAction(action: .dismissEdit) = action {
                PopJourney()
            } else if case let .coInsuredNavigationAction(navigationAction) = action {
                if case let .openCoInsuredInput(actionType, coInsuredModel, title, contractId) = navigationAction {
                    openCoInsuredInput(
                        actionType: actionType,
                        coInsuredModel: coInsuredModel,
                        title: title,
                        contractId: contractId,
                        style: .detented(.scrollViewContentSize, modally: false)
                    )
                } else {
                    getScreen(for: action)
                }
            } else {
                getScreen(for: action)
            }
        }
        .onAction(ContractStore.self) { action in
            if case .coInsuredNavigationAction(action: .dismissEdit) = action {
                PopJourney()
            }
        }
        .configureTitle(L10n.contractAddConisuredInfo)
    }

    @JourneyBuilder
    public static func openInitialScreen(contractIds: [String]) -> some JourneyPresentation {
        if contractIds.count > 1 {
            openSelectInsurance(contractIds: contractIds)
        } else if let contractId = contractIds.first {
            openNewInsuredPeopleScreen(id: contractId)
        }
    }

    @JourneyBuilder
    public static func handleOpenEditCoInsured(for contractId: String, fromInfoCard: Bool) -> some JourneyPresentation {
        let store: ContractStore = globalPresentableStoreContainer.get()
        if let canChangeCoInsured = store.state.contractForId(contractId)?.supportsCoInsured,
            canChangeCoInsured
        {
            if store.state.contractForId(contractId)?.nbOfMissingCoInsured ?? 0 > 0 {
                if fromInfoCard {
                    EditCoInsuredJourney.openNewInsuredPeopleScreen(id: contractId)
                } else {
                    EditCoInsuredJourney.openRemoveCoInsuredScreen(id: contractId)
                }
            } else {
                EditCoInsuredJourney.openInsuredPeopleScreen(id: contractId)
            }
        } else {
            EditCoInsuredJourney.openGenericErrorScreen()
        }
    }
}
