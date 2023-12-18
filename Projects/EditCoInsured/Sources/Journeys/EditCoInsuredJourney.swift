import Foundation
import Presentation
import SwiftUI
import hAnalytics
import hCore
import hCoreUI

public class EditCoInsuredJourney {
    @JourneyBuilder
    private static func getScreen(for action: EditCoInsuredAction) -> some JourneyPresentation {
        if case let .coInsuredNavigationAction(navigationAction) = action {
            if case let .openInsuredPeopleScreen(config) = navigationAction {
                openInsuredPeopleScreen(with: config)
            } else if case let .openInsuredPeopleNewScreen(config) = navigationAction {
                openNewInsuredPeopleScreen(config: config)
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
            } else if case let .openMissingCoInsuredAlert(config) = navigationAction {
                openMissingCoInsuredAlert(config: config)
            } else if case .openErrorScreen = navigationAction {
                openGenericErrorScreen()
            } else if case let .openSelectInsuranceScreen(configs) = navigationAction {
                openSelectInsurance(configs: configs)
            }
        }
    }

    static func openInsuredPeopleScreen(with config: InsuredPeopleConfig) -> some JourneyPresentation {
        let store: EditCoInsuredStore = globalPresentableStoreContainer.get()
        store.coInsuredViewModel.initializeCoInsured(with: config)
        return HostingJourney(
            EditCoInsuredStore.self,
            rootView: InsuredPeopleScreen(vm: store.coInsuredViewModel, intentVm: store.intentViewModel),
            style: .modally(presentationStyle: .overFullScreen),
            options: [.defaults, .withAdditionalSpaceForProgressBar, .ignoreActionWhenNotOnTop]
        ) { action in
            getScreen(for: action)
        }
        .configureTitle(L10n.coinsuredEditTitle)
        .withJourneyDismissButton
    }

    static func openNewInsuredPeopleScreen(config: InsuredPeopleConfig) -> some JourneyPresentation {
        let store: EditCoInsuredStore = globalPresentableStoreContainer.get()
        store.coInsuredViewModel.initializeCoInsured(with: config)
        return HostingJourney(
            EditCoInsuredStore.self,
            rootView: InsuredPeopleNewScreen(vm: store.coInsuredViewModel, intentVm: store.intentViewModel),
            style: .modally(presentationStyle: .overFullScreen),
            options: [.defaults, .withAdditionalSpaceForProgressBar, .ignoreActionWhenNotOnTop]
        ) { action in
            getScreen(for: action)
        }
        .configureTitle(L10n.coinsuredEditTitle)
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
            EditCoInsuredStore.self,
            rootView: CoInusuredInput(
                vm: .init(coInsuredModel: coInsuredModel, actionType: actionType, contractId: contractId),
                title: title
            ),
            style: style,
            options: [.largeNavigationBar, .blurredBackground]
        ) { action in
            if case .coInsuredNavigationAction(.dismissEdit) = action {
                PopJourney()
            } else if case .coInsuredNavigationAction(.deletionSuccess) = action {
                SuccessScreen.journey(with: L10n.contractCoinsuredRemoved)
                    .onPresent {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                            let store: EditCoInsuredStore = globalPresentableStoreContainer.get()
                            store.send(.coInsuredNavigationAction(action: .dismissEdit))
                        }
                    }
            } else if case .coInsuredNavigationAction(.addSuccess) = action {
                SuccessScreen.journey(with: L10n.contractCoinsuredAdded)
                    .onPresent {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                            let store: EditCoInsuredStore = globalPresentableStoreContainer.get()
                            store.send(.coInsuredNavigationAction(action: .dismissEdit))
                        }
                    }
            } else {
                getScreen(for: action)
            }
        }
        .onAction(EditCoInsuredStore.self) { action in
            if case .coInsuredNavigationAction(action: .dismissEdit) = action {
                PopJourney()
            }
        }
    }

    @JourneyBuilder
    static func openProgress(showSuccess: Bool) -> some JourneyPresentation {
        HostingJourney(
            EditCoInsuredStore.self,
            rootView: CoInsuredProcessingScreen(showSuccessScreen: showSuccess),
            style: .modally(presentationStyle: .overFullScreen),
            options: [.defaults, .withAdditionalSpaceForProgressBar]
        ) { action in
            getScreen(for: action)
        }
    }

    static func openRemoveCoInsuredScreen(config: InsuredPeopleConfig) -> some JourneyPresentation {
        let store: EditCoInsuredStore = globalPresentableStoreContainer.get()
        store.coInsuredViewModel.initializeCoInsured(with: config)

        return HostingJourney(
            EditCoInsuredStore.self,
            rootView: RemoveCoInsuredScreen(vm: store.coInsuredViewModel),
            style: .modally(presentationStyle: .overFullScreen),
            options: [.defaults, .withAdditionalSpaceForProgressBar]
        ) { action in
            getScreen(for: action)
        }
        .configureTitle(L10n.coinsuredEditTitle)
    }

    @JourneyBuilder
    static func openGenericErrorScreen() -> some JourneyPresentation {
        HostingJourney(
            EditCoInsuredStore.self,
            rootView: CoInsuredErrorScreen(),
            style: .modally(presentationStyle: .overFullScreen),
            options: [.defaults, .withAdditionalSpaceForProgressBar]
        ) { action in
            getScreen(for: action)
        }
    }

    @JourneyBuilder
    public static func openMissingCoInsuredAlert(config: InsuredPeopleConfig) -> some JourneyPresentation {
        HostingJourney(
            EditCoInsuredStore.self,
            rootView: CoInsuredMissingAlertView(config: config),
            style: .detented(.scrollViewContentSize),
            options: [.largeNavigationBar, .blurredBackground]
        ) { action in
            getScreen(for: action)
        }
        .onAction(EditCoInsuredStore.self) { action in
            if case .coInsuredNavigationAction(action: .dismissEdit) = action {
                PopJourney()
            } else {
                getScreen(for: action)
            }
        }
    }

    @JourneyBuilder
    static func openSelectInsurance(configs: [InsuredPeopleConfig]) -> some JourneyPresentation {
        HostingJourney(
            EditCoInsuredStore.self,
            rootView: CheckboxPickerScreen<InsuredPeopleConfig>(
                items: {
                    return configs.compactMap({
                        (object: $0, displayName: $0.displayName)
                    })
                }(),
                preSelectedItems: {
                    if let first = configs.first {
                        return [first]
                    }
                    return []
                },
                onSelected: { selectedConfigs in
                    if let selectedConfig = selectedConfigs.first {
                        let store: EditCoInsuredStore = globalPresentableStoreContainer.get()
                        if let object = selectedConfig.0 {
                            store.send(
                                .coInsuredNavigationAction(
                                    action: .openInsuredPeopleNewScreen(config: object)
                                )
                            )
                        }
                    }
                },
                onCancel: {
                    let contractStore: EditCoInsuredStore = globalPresentableStoreContainer.get()
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
            EditCoInsuredStore.self,
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
        .onAction(EditCoInsuredStore.self) { action in
            if case .coInsuredNavigationAction(action: .dismissEdit) = action {
                PopJourney()
            }
        }
        .hidesBackButton
        .configureTitle(L10n.contractAddConisuredInfo)
    }

    @JourneyBuilder
    public static func openInitialScreen(configs: [InsuredPeopleConfig]) -> some JourneyPresentation {
        if configs.count > 1 {
            openSelectInsurance(configs: configs)
        } else if let config = configs.first {
            openNewInsuredPeopleScreen(config: config)
        }
    }

    @JourneyBuilder
    public static func handleOpenEditCoInsured(
        for config: InsuredPeopleConfig,
        fromInfoCard: Bool
    ) -> some JourneyPresentation {
        if config.numberOfMissingCoInsuredWithoutTermination > 0 {
            if fromInfoCard {
                EditCoInsuredJourney.openNewInsuredPeopleScreen(config: config)
            } else {
                EditCoInsuredJourney.openRemoveCoInsuredScreen(config: config)
            }
        } else {
            EditCoInsuredJourney.openInsuredPeopleScreen(with: config)
        }
    }
}
