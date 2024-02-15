import Foundation
import Presentation
import SwiftUI
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
        .addDismissEditCoInsuredFlow()
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
        .addDismissEditCoInsuredFlow()
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
                SuccessScreen<EmptyView>.journey(with: L10n.contractCoinsuredRemoved)
                    .onPresent {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                            let store: EditCoInsuredStore = globalPresentableStoreContainer.get()
                            store.send(.coInsuredNavigationAction(action: .dismissEdit))
                        }
                    }
            } else if case .coInsuredNavigationAction(.addSuccess) = action {
                SuccessScreen<EmptyView>.journey(with: L10n.contractCoinsuredAdded)
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
            if case .coInsuredNavigationAction(action: .dismissEdit) = action {
                PopJourney()
            } else {
                getScreen(for: action)
            }
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
            rootView: GenericErrorView(
                description: L10n.coinsuredErrorText,
                icon: .circle,
                buttons: .init(
                    actionButton:
                        .init(
                            buttonTitle: L10n.openChat,
                            buttonAction: {
                                let store: EditCoInsuredStore = globalPresentableStoreContainer.get()
                                store.send(.coInsuredNavigationAction(action: .dismissEditCoInsuredFlow))
                                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                    store.send(.goToFreeTextChat)
                                }
                            }
                        ),
                    dismissButton:
                        .init(
                            buttonTitle: L10n.generalCancelButton,
                            buttonAction: {
                                let store: EditCoInsuredStore = globalPresentableStoreContainer.get()
                                store.send(.coInsuredNavigationAction(action: .dismissEditCoInsuredFlow))
                            }
                        )
                )
            ),
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
            rootView: GenericErrorView(
                title: config.contractDisplayName,
                description: L10n.contractCoinsuredMissingInformationLabel,
                buttons: .init(
                    actionButtonAttachedToBottom:
                        .init(
                            buttonTitle: L10n.contractCoinsuredMissingAddInfo,
                            buttonAction: {
                                let store: EditCoInsuredStore = globalPresentableStoreContainer.get()
                                store.send(.coInsuredNavigationAction(action: .dismissEdit))
                                store.send(.openEditCoInsured(config: config, fromInfoCard: true))
                            }
                        ),
                    dismissButton:
                        .init(
                            buttonTitle: L10n.contractCoinsuredMissingLater,
                            buttonAction: {
                                let store: EditCoInsuredStore = globalPresentableStoreContainer.get()
                                store.send(.coInsuredNavigationAction(action: .dismissEditCoInsuredFlow))
                            }
                        )
                )
            )
            .hExtraBottomPadding,

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
                            if object.numberOfMissingCoInsuredWithoutTermination > 0 {
                                store.send(
                                    .coInsuredNavigationAction(
                                        action: .openInsuredPeopleNewScreen(config: object)
                                    )
                                )
                            } else {
                                store.send(
                                    .coInsuredNavigationAction(
                                        action: .openInsuredPeopleScreen(config: object)
                                    )
                                )
                            }
                        }
                    }
                },
                onCancel: {
                    let contractStore: EditCoInsuredStore = globalPresentableStoreContainer.get()
                    contractStore.send(.coInsuredNavigationAction(action: .dismissEdit))
                },
                singleSelect: true,
                hButtonText: L10n.generalContinueButton
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
        .configureTitle(L10n.SelectInsurance.NavigationBar.CenterElement.title)
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
            if configs.first?.numberOfMissingCoInsuredWithoutTermination ?? 0 > 0 {
                openNewInsuredPeopleScreen(config: config)
            } else {
                openInsuredPeopleScreen(with: config)
            }
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

extension JourneyPresentation {
    func addDismissEditCoInsuredFlow() -> some JourneyPresentation {
        self.withJourneyDismissButtonWithConfirmation(
            withTitle: L10n.General.areYouSure,
            andBody: L10n.Claims.Alert.body,
            andCancelText: L10n.General.no,
            andConfirmText: L10n.General.yes
        )
    }
}
