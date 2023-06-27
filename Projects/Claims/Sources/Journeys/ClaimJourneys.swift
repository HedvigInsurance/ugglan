import Foundation
import Presentation
import hAnalytics
import hCore
import hCoreUI

public class ClaimJourneys {
    @JourneyBuilder
    public static func getScreenForAction(
        for action: SubmitClaimsAction,
        withHidesBack: Bool = false
    ) -> some JourneyPresentation {
        if withHidesBack {
            getScreen(for: action).hidesBackButton
        } else {
            getScreen(for: action).showsBackButton
        }
    }

    @JourneyBuilder
    private static func getScreen(for action: SubmitClaimsAction) -> some JourneyPresentation {
        if case let .navigationAction(navigationAction) = action {
            if hAnalyticsExperiment.claimsFlowNewDesign {
                if case let .openPhoneNumberScreen(model) = navigationAction {
                    submitClaimPhoneNumberScreen(model: model).addDismissClaimsFlow()
                } else if case .openDateOfOccurrencePlusLocationScreen = navigationAction {
                    submitClaimOccurrancePlusLocationScreen().addDismissClaimsFlow()
                } else if case .openAudioRecordingScreen = navigationAction {
                    openAudioRecordingSceen().addDismissClaimsFlow()
                } else if case .openSuccessScreen = navigationAction {
                    openSuccessScreen()
                } else if case .openSingleItemScreen = navigationAction {
                    openSingleItemScreen().addDismissClaimsFlow()
                } else if case .openSummaryScreen = navigationAction {
                    openSummaryScreen().addDismissClaimsFlow().configureTitle(L10n.Claims.Summary.Screen.title)
                } else if case .openDamagePickerScreen = navigationAction {
                    openDamagePickerScreen().configureTitle(L10n.Claims.Item.Screen.Damage.button)
                } else if case .openCheckoutNoRepairScreen = navigationAction {
                    openCheckoutNoRepairScreen().addDismissClaimsFlow()
                        .configureTitle(L10n.Claims.Payout.Summary.title)
                } else if case .openFailureSceen = navigationAction {
                    showClaimFailureScreen().withJourneyDismissButton
                } else if case .openSummaryEditScreen = navigationAction {
                    openSummaryEditScreen().addDismissClaimsFlow().configureTitle(L10n.Claims.Edit.Screen.title)
                } else if case let .openLocationPicker(type) = navigationAction {
                    openLocationScreen(type: type).configureTitle(L10n.Claims.Incident.Screen.location)
                } else if case .openUpdateAppScreen = navigationAction {
                    openUpdateAppTerminationScreen().withJourneyDismissButton
                } else if case let .openDatePicker(type) = navigationAction {
                    openDatePickerScreen(type: type)
                }
            } else {
                if case let .openPhoneNumberScreen(model) = navigationAction {
                    submitClaimPhoneNumberScreenOld(model: model).addDismissClaimsFlow()
                } else if case .openDateOfOccurrencePlusLocationScreen = navigationAction {
                    submitClaimOccurrancePlusLocationScreenOld().addDismissClaimsFlow()
                } else if case .openAudioRecordingScreen = navigationAction {
                    openAudioRecordingSceenOld().addDismissClaimsFlow().configureTitle(L10n.embarkSubmitClaim)
                } else if case .openSuccessScreen = navigationAction {
                    openSuccessScreenOld().withJourneyDismissButton.configureTitle(L10n.embarkSubmitClaim)
                } else if case .openSingleItemScreen = navigationAction {
                    openSingleItemScreenOld().addDismissClaimsFlow()
                } else if case .openSummaryScreen = navigationAction {
                    openSummaryScreenOld().addDismissClaimsFlow().configureTitle(L10n.Claims.Summary.Screen.title)
                } else if case .openDamagePickerScreen = navigationAction {
                    openDamagePickerScreenOld().addDismissClaimsFlow()
                } else if case .openCheckoutNoRepairScreen = navigationAction {
                    openCheckoutNoRepairScreenOld().addDismissClaimsFlow()
                        .configureTitle(L10n.Claims.Payout.Summary.title)
                } else if case .openFailureSceen = navigationAction {
                    showClaimFailureScreenOld().withJourneyDismissButton
                } else if case .openSummaryEditScreen = navigationAction {
                    openSummaryEditScreen().addDismissClaimsFlow().configureTitle(L10n.Claims.Edit.Screen.title)
                } else if case let .openLocationPicker(type) = navigationAction {
                    openLocationScreenOld(type: type)
                } else if case .openUpdateAppScreen = navigationAction {
                    openUpdateAppTerminationScreenOld().withJourneyDismissButton
                } else if case let .openDatePicker(type) = navigationAction {
                    openDatePickerScreenOld(type: type)
                }
            }
        }
    }

    private static func submitClaimPhoneNumberScreen(model: FlowClaimPhoneNumberStepModel) -> some JourneyPresentation {
        HostingJourney(
            SubmitClaimStore.self,
            rootView: SubmitClaimContactScreen(model: model)
        ) { action in
            getScreen(for: action)
        }
        .resetProgressToPreviousValueOnDismiss
    }

    private static func submitClaimPhoneNumberScreenOld(
        model: FlowClaimPhoneNumberStepModel
    ) -> some JourneyPresentation {
        HostingJourney(
            SubmitClaimStore.self,
            rootView: SubmitClaimContactScreenOld(model: model)
        ) { action in
            getScreen(for: action)
        }
    }

    @JourneyBuilder
    static func submitClaimOccurrancePlusLocationScreen() -> some JourneyPresentation {
        HostingJourney(
            SubmitClaimStore.self,
            rootView: SubmitClaimOccurrencePlusLocationScreen()
        ) {
            action in
            getScreen(for: action)
        }
        .resetProgressToPreviousValueOnDismiss
    }

    static func submitClaimOccurrancePlusLocationScreenOld() -> some JourneyPresentation {
        HostingJourney(
            SubmitClaimStore.self,
            rootView: SubmitClaimOccurrencePlusLocationScreenOld()
        ) {
            action in
            getScreen(for: action)
        }
    }

    @JourneyBuilder
    static func openDatePickerScreen(type: ClaimsNavigationAction.DatePickerType) -> some JourneyPresentation {
        let screen = DatePickerScreen(type: type).hUseNewStyle
        if type.shouldShowModally {
            HostingJourney(
                SubmitClaimStore.self,
                rootView: screen,
                style: .detented(.scrollViewContentSize),
                options: [
                    .defaults
                ]
            ) {
                action in
                if case .setNewDate = action {
                    PopJourney()
                } else if case .setSingleItemPurchaseDate = action {
                    PopJourney()
                } else {
                    getScreen(for: action)
                }
            }
            .configureTitle(type.title)
            .withDismissButton
        } else {
            HostingJourney(
                SubmitClaimStore.self,
                rootView: screen
            ) {
                action in
                if case .setNewDate = action {
                    PopJourney()
                } else if case .setSingleItemPurchaseDate = action {
                    PopJourney()
                } else {
                    getScreen(for: action)
                }
            }
            .resetProgressToPreviousValueOnDismiss
            .configureTitle(type.title)
        }
    }

    static func openDatePickerScreenOld(type: ClaimsNavigationAction.DatePickerType) -> some JourneyPresentation {
        let screen = DatePickerScreen(type: type)
        if type.shouldShowModally {
            return HostingJourney(
                SubmitClaimStore.self,
                rootView: screen,
                style: .detented(.scrollViewContentSize),
                options: [
                    .defaults,
                    .largeTitleDisplayMode(.always),
                    .prefersLargeTitles(true),
                ]
            ) {
                action in
                if case .setNewDate = action {
                    PopJourney()
                } else if case .setSingleItemPurchaseDate = action {
                    PopJourney()
                } else {
                    getScreen(for: action)
                }
            }
            .configureTitle(type.title)
            .withDismissButton
        } else {
            return HostingJourney(
                SubmitClaimStore.self,
                rootView: screen
            ) {
                action in
                if case .setNewDate = action {
                    PopJourney()
                } else if case .setSingleItemPurchaseDate = action {
                    PopJourney()
                } else {
                    getScreen(for: action)
                }
            }
            .configureTitle(type.title)
        }
    }

    static func openLocationScreen(type: ClaimsNavigationAction.LocationPickerType) -> some JourneyPresentation {
        HostingJourney(
            SubmitClaimStore.self,
            rootView: CheckboxPickerScreen<ClaimFlowLocationOptionModel>(
                items: {
                    let store: SubmitClaimStore = globalPresentableStoreContainer.get()
                    return store.state.locationStep?.options
                        .compactMap({ (object: $0, displayName: $0.displayName) }) ?? []
                }(),
                preSelectedItems: { nil },
                onSelected: { selectedLocation in
                    let store: SubmitClaimStore = globalPresentableStoreContainer.get()
                    let executedAction: SubmitClaimsAction = {
                        switch type {
                        case .setLocation:
                            return .setNewLocation(location: selectedLocation.first)
                        case .submitLocation:
                            return .locationRequest(location: selectedLocation.first)
                        }
                    }()
                    store.send(executedAction)
                },
                onCancel: {
                    let store: SubmitClaimStore = globalPresentableStoreContainer.get()
                    store.send(.navigationAction(action: .dismissScreen))
                },
                singleSelect: true
            ),
            style: type == .submitLocation ? .default : .detented(.scrollViewContentSize)
        ) {
            action in
            if case .navigationAction(.dismissScreen) = action {
                PopJourney()
            } else if case .setNewLocation = action {
                PopJourney()
            } else {
                getScreen(for: action)
            }
        }
        .resetProgressToPreviousValueOnDismiss
    }

    static func openLocationScreenOld(type: ClaimsNavigationAction.LocationPickerType) -> some JourneyPresentation {
        HostingJourney(
            SubmitClaimStore.self,
            rootView: LocationPickerScreenOld(type: type),
            style: type == .submitLocation ? .default : .detented(.scrollViewContentSize)
        ) {
            action in
            if case .setNewLocation = action {
                PopJourney()
            } else {
                getScreen(for: action)
            }
        }
        .withDismissButton
    }

    static func openBrandPickerScreen() -> some JourneyPresentation {
        HostingJourney(
            SubmitClaimStore.self,
            rootView: ItemPickerScreen<ClaimFlowItemBrandOptionModel>(
                items: {
                    let store: SubmitClaimStore = globalPresentableStoreContainer.get()
                    return store.state.singleItemStep?.availableItemBrandOptions
                        .compactMap({ (object: $0, displayName: $0.displayName) }) ?? []
                }(),
                onSelected: { item in
                    let store: SubmitClaimStore = globalPresentableStoreContainer.get()
                    store.send(.setItemBrand(brand: item))
                },
                onCancel: {
                    let store: SubmitClaimStore = globalPresentableStoreContainer.get()
                    store.send(.navigationAction(action: .dismissScreen))
                }
            ),
            style: .detented(.scrollViewContentSize),
            options: [.defaults, .wantsGrabber]
        ) {
            action in
            if case let .setItemBrand(brand) = action {
                let store: SubmitClaimStore = globalPresentableStoreContainer.get()
                if store.state.singleItemStep?.shouldShowListOfModels(for: brand) ?? false {
                    openModelPickerScreen().configureTitle(L10n.claimsChooseModelTitle)
                } else {
                    PopJourney()
                }
            } else if case .navigationAction(.dismissScreen) = action {
                PopJourney()
            } else {
                getScreen(for: action)
            }
        }
        .onAction(
            SubmitClaimStore.self,
            { action, pre in
                if case .setSingleItemModel(_) = action {
                    pre.bag.dispose()
                }
            }
        )
    }

    static func openBrandPickerScreenOld() -> some JourneyPresentation {
        HostingJourney(
            SubmitClaimStore.self,
            rootView: ItemPickerScreenOld<ClaimFlowItemBrandOptionModel>(
                items: {
                    let store: SubmitClaimStore = globalPresentableStoreContainer.get()
                    return store.state.singleItemStep?.availableItemBrandOptions
                        .compactMap({ (object: $0, displayName: $0.displayName) }) ?? []
                }(),
                onSelected: { item in
                    let store: SubmitClaimStore = globalPresentableStoreContainer.get()
                    store.send(.setItemBrand(brand: item))
                }
            ),
            options: .autoPopSelfAndSuccessors
        ) {
            action in
            if case let .setItemBrand(brand) = action {
                let store: SubmitClaimStore = globalPresentableStoreContainer.get()
                if store.state.singleItemStep?.shouldShowListOfModels(for: brand) ?? false {
                    openModelPickerScreenOld()
                } else {
                    PopJourney()
                }
            } else {
                getScreen(for: action)
            }
        }
        .onAction(
            SubmitClaimStore.self,
            { action, pre in
                if case .setSingleItemModel(_) = action {
                    pre.bag.dispose()
                }
            }
        )
    }

    static func openModelPickerScreen() -> some JourneyPresentation {
        HostingJourney(
            SubmitClaimStore.self,
            rootView: CheckboxPickerScreen<ClaimFlowItemModelOptionModel>(
                items: {
                    let store: SubmitClaimStore = globalPresentableStoreContainer.get()
                    return store.state.singleItemStep?.getListOfModels()?.compactMap({ ($0, $0.displayName) }) ?? []

                }(),
                preSelectedItems: { nil },
                onSelected: { item in
                    let store: SubmitClaimStore = globalPresentableStoreContainer.get()
                    store.send(.setSingleItemModel(modelName: item.first!))
                },
                onCancel: {},
                singleSelect: true,
                showDividers: true
            ),
            style: .detented(.large, modally: false),
            options: [.defaults, .wantsGrabber]
        ) {
            action in
            ContinueJourney()
        }
        .onAction(
            SubmitClaimStore.self,
            { action, pre in
                if case .setSingleItemModel = action {
                    pre.bag.dispose()
                }
            }
        )
    }

    static func openModelPickerScreenOld() -> some JourneyPresentation {
        HostingJourney(
            SubmitClaimStore.self,
            rootView: ItemPickerScreenOld<ClaimFlowItemModelOptionModel>(
                items: {
                    let store: SubmitClaimStore = globalPresentableStoreContainer.get()
                    return store.state.singleItemStep?.getListOfModels()?.compactMap({ ($0, $0.displayName) }) ?? []

                }(),
                onSelected: { item in
                    let store: SubmitClaimStore = globalPresentableStoreContainer.get()
                    store.send(.setSingleItemModel(modelName: item))
                }
            )
        ) {
            action in
            ContinueJourney()
        }
        .onAction(
            SubmitClaimStore.self,
            { action, pre in
                if case .setSingleItemModel = action {
                    pre.bag.dispose()
                }
            }
        )
    }

    static func openDamagePickerScreen() -> some JourneyPresentation {
        HostingJourney(
            SubmitClaimStore.self,
            rootView: CheckboxPickerScreen<ClaimFlowItemProblemOptionModel>(
                items: {
                    let store: SubmitClaimStore = globalPresentableStoreContainer.get()
                    return store.state.singleItemStep?.availableItemProblems
                        .compactMap({ (object: $0, displayName: $0.displayName) }) ?? []
                }(),
                preSelectedItems: {
                    let store: SubmitClaimStore = globalPresentableStoreContainer.get()
                    var damagesArray: [ClaimFlowItemProblemOptionModel] = []
                    for selectedDamage in store.state.singleItemStep?.selectedItemProblems ?? [] {
                        damagesArray.append(
                            ClaimFlowItemProblemOptionModel(displayName: selectedDamage, itemProblemId: selectedDamage)
                        )
                    }
                    return damagesArray
                },
                onSelected: { selectedDamages in
                    let store: SubmitClaimStore = globalPresentableStoreContainer.get()
                    var damages: [String] = []

                    for damage in selectedDamages {
                        damages.append(damage.itemProblemId)
                    }
                    store.send(
                        .submitDamage(
                            damage: damages
                        )
                    )
                },
                onCancel: {
                    let store: SubmitClaimStore = globalPresentableStoreContainer.get()
                    store.send(.navigationAction(action: .dismissScreen))
                }
            ),
            style: .detented(.scrollViewContentSize)
        ) {
            action in
            if case .navigationAction(.dismissScreen) = action {
                PopJourney()
            } else if case .setSingleItemDamage(_) = action {
                PopJourney()
            } else {
                getScreen(for: action)
            }
        }
    }

    static func openDamagePickerScreenOld() -> some JourneyPresentation {
        HostingJourney(
            SubmitClaimStore.self,
            rootView: DamamagePickerScreenOld(),
            style: .default
        ) {
            action in
            if case .setSingleItemDamage(_) = action {
                PopJourney()
            } else {
                getScreen(for: action)
            }
        }
    }

    static func openAudioRecordingSceen() -> some JourneyPresentation {
        let store: SubmitClaimStore = globalPresentableStoreContainer.get()
        let url = store.state.audioRecordingStep?.getUrl()
        return HostingJourney(
            SubmitClaimStore.self,
            rootView: SubmitClaimAudioRecordingScreen(url: url)
        ) { action in
            getScreen(for: action)
        }
        .resetProgressToPreviousValueOnDismiss
    }

    static func openAudioRecordingSceenOld() -> some JourneyPresentation {
        let store: SubmitClaimStore = globalPresentableStoreContainer.get()
        let url = store.state.audioRecordingStep?.getUrl()
        return HostingJourney(
            SubmitClaimStore.self,
            rootView: SubmitClaimAudioRecordingScreenOld(url: url)
        ) { action in
            getScreen(for: action)
        }
    }

    private static func openSuccessScreen() -> some JourneyPresentation {
        HostingJourney(
            rootView: SubmitClaimSuccessScreen()
        )
        .hidesBackButton
    }

    private static func openSuccessScreenOld() -> some JourneyPresentation {
        HostingJourney(
            rootView: SubmitClaimSuccessScreenOld()
        )
        .hidesBackButton
    }

    private static func openSingleItemScreenOld() -> some JourneyPresentation {
        HostingJourney(
            SubmitClaimStore.self,
            rootView: SubmitClaimSingleItemOld()
        ) {
            action in
            if case .navigationAction(.openDatePicker) = action {
                openDatePickerScreen(type: .setDateOfPurchase)
            } else if case .navigationAction(.openBrandPicker) = action {
                openBrandPickerScreenOld()
            } else {
                getScreen(for: action)
            }
        }
    }

    @JourneyBuilder
    private static func openSingleItemScreen() -> some JourneyPresentation {
        HostingJourney(
            SubmitClaimStore.self,
            rootView: SubmitClaimSingleItem()
        ) {
            action in
            if case .navigationAction(.openDatePicker) = action {
                openDatePickerScreen(type: .setDateOfPurchase)
            } else if case .navigationAction(.openBrandPicker) = action {
                openBrandPickerScreen().configureTitle(L10n.claimsChooseModelTitle)
            } else {
                getScreen(for: action)
            }
        }
        .resetProgressToPreviousValueOnDismiss
    }

    private static func openSummaryScreen() -> some JourneyPresentation {
        HostingJourney(
            SubmitClaimStore.self,
            rootView: SubmitClaimSummaryScreen()
        ) {
            action in
            if case .navigationAction(.dismissScreen) = action {
                PopJourney()
            } else {
                getScreen(for: action)
            }
        }
        .resetProgressToPreviousValueOnDismiss
    }

    private static func openSummaryScreenOld() -> some JourneyPresentation {
        HostingJourney(
            SubmitClaimStore.self,
            rootView: SubmitClaimSummaryScreenOld()
        ) {
            action in
            getScreen(for: action)
        }
    }

    private static func openCheckoutNoRepairScreen() -> some JourneyPresentation {
        HostingJourney(
            SubmitClaimStore.self,
            rootView: SubmitClaimCheckoutNoRepairScreen()
        ) {
            action in
            if case .navigationAction(.openCheckoutTransferringScreen) = action {
                openCheckoutTransferringScreen()
            } else if case .navigationAction(.dismissScreen) = action {
                PopJourney()
            } else if case .summaryRequest = action {
                openCheckoutTransferringScreen()
            } else {
                getScreenForAction(for: action)
            }
        }
        .resetProgressToPreviousValueOnDismiss
    }

    private static func openCheckoutNoRepairScreenOld() -> some JourneyPresentation {

        HostingJourney(
            SubmitClaimStore.self,
            rootView: SubmitClaimCheckoutNoRepairScreenOld()
        ) {
            action in
            if case .navigationAction(.openCheckoutTransferringScreen) = action {
                openCheckoutTransferringScreenOld()
            } else if case .summaryRequest = action {
                openCheckoutTransferringScreenOld()
            } else {
                getScreen(for: action)
            }
        }
    }

    static func openCheckoutTransferringScreen() -> some JourneyPresentation {
        HostingJourney(
            rootView: SubmitClaimCheckoutTransferringScreen(),
            style: .modally(presentationStyle: .fullScreen, transitionStyle: .crossDissolve)
        )
    }

    static func openCheckoutTransferringScreenOld() -> some JourneyPresentation {

        HostingJourney(
            rootView: SubmitClaimCheckoutTransferringScreenOld(),
            style: .modally(presentationStyle: .fullScreen, transitionStyle: .crossDissolve)
        )
    }

    private static func openSummaryEditScreen() -> some JourneyPresentation {

        HostingJourney(
            SubmitClaimStore.self,
            rootView: SubmitClaimEditSummaryScreen()
        ) {
            action in
            getScreen(for: action)
        }
        .resetProgressToPreviousValueOnDismiss
    }

    @JourneyBuilder
    public static func showClaimEntrypointGroup(
        origin: ClaimsOrigin
    ) -> some JourneyPresentation {
        HostingJourney(
            SubmitClaimStore.self,
            rootView: SelectClaimEntrypointGroup(
                selectedEntrypoints: { entrypoints in
                    let store: SubmitClaimStore = globalPresentableStoreContainer.get()
                    store.send(.setSelectedEntrypoints(entrypoints: entrypoints))

                    if entrypoints.isEmpty {
                        store.send(
                            .startClaimRequest(
                                entrypointId: nil,
                                entrypointOptionId: nil
                            )
                        )
                    }
                }),
            style: .modally(presentationStyle: .overFullScreen)
        ) { action in
            if case let .setSelectedEntrypoints(entrypoints) = action {
                if !entrypoints.isEmpty {
                    ClaimJourneys.showClaimEntrypointType(origin: origin)
                }
            } else {
                getScreen(for: action).showsBackButton
            }
        }
        .onPresent {
            let store: SubmitClaimStore = globalPresentableStoreContainer.get()
            store.send(.fetchEntrypointGroups)
        }
        .resetProgressToPreviousValueOnDismiss
        .hidesBackButton
        .withJourneyDismissButton
        .addClaimsProgressBar
    }

    @JourneyBuilder
    public static func showClaimEntrypointType(
        origin: ClaimsOrigin
    ) -> some JourneyPresentation {
        HostingJourney(
            SubmitClaimStore.self,
            rootView:
                SelectClaimEntrypointType(selectedEntrypointOptions: { options, selectedEntrypointId in
                    let store: SubmitClaimStore = globalPresentableStoreContainer.get()
                    store.send(.setSelectedEntrypointOptions(entrypoints: options))
                    store.send(.setSelectedEntrypointId(entrypoints: selectedEntrypointId))

                    if options.isEmpty {
                        store.send(
                            .startClaimRequest(
                                entrypointId: selectedEntrypointId,
                                entrypointOptionId: nil
                            )
                        )
                    }
                })
        ) { action in
            if case let .setSelectedEntrypointOptions(options) = action {
                if !options.isEmpty {
                    ClaimJourneys.showClaimEntrypointOption(origin: origin)
                }
            } else {
                getScreen(for: action)
            }
        }
        .resetProgressToPreviousValueOnDismiss
        .showsBackButton
        .withJourneyDismissButton
    }

    @JourneyBuilder
    public static func showClaimEntrypointOption(
        origin: ClaimsOrigin
    ) -> some JourneyPresentation {
        HostingJourney(
            SubmitClaimStore.self,
            rootView:
                SelectClaimEntrypointOption(onButtonClick: { entrypointId, entrypointOptionId in
                    let store: SubmitClaimStore = globalPresentableStoreContainer.get()
                    store.send(
                        .startClaimRequest(
                            entrypointId: entrypointId,
                            entrypointOptionId: entrypointOptionId
                        )
                    )
                })
        ) { action in
            getScreen(for: action)
        }
        .resetProgressToPreviousValueOnDismiss
        .withJourneyDismissButton
    }

    @JourneyBuilder
    public static func showClaimEntrypointsOld(
        origin: ClaimsOrigin
    ) -> some JourneyPresentation {
        HostingJourney(
            SubmitClaimStore.self,
            rootView: SelectClaimEntrypointOld(entrypointGroupId: nil),
            style: .detented(.large, modally: false)
        ) { action in
            getScreen(for: action).hidesBackButton
        }
        .hidesBackButton
        .withJourneyDismissButton
    }

    private static func showClaimFailureScreen() -> some JourneyPresentation {
        HostingJourney(rootView: ClaimFailureScreen())
            .hidesBackButton
    }

    private static func showClaimFailureScreenOld() -> some JourneyPresentation {
        HostingJourney(rootView: ClaimFailureScreenOld())
            .hidesBackButton
    }

    private static func openUpdateAppTerminationScreen() -> some JourneyPresentation {
        HostingJourney(
            SubmitClaimStore.self,
            rootView: UpdateAppScreen(
                onSelected: {
                    let store: SubmitClaimStore = globalPresentableStoreContainer.get()
                    store.send(.dissmissNewClaimFlow)
                }
            )
        ) {
            action in
            getScreen(for: action)
        }
        .hidesBackButton
    }

    static func openUpdateAppTerminationScreenOld() -> some JourneyPresentation {
        HostingJourney(
            SubmitClaimStore.self,
            rootView: UpdateAppScreenOld(
                onSelected: {
                    let store: SubmitClaimStore = globalPresentableStoreContainer.get()
                    store.send(.dissmissNewClaimFlow)
                }
            )
        ) {
            action in
            getScreen(for: action)
        }
        .hidesBackButton
    }
}

extension JourneyPresentation {
    func addDismissClaimsFlow() -> some JourneyPresentation {
        self.withJourneyDismissButtonWithConfirmation(
            withTitle: L10n.General.areYouSure,
            andBody: L10n.Claims.Alert.body,
            andCancelText: L10n.General.no,
            andConfirmText: L10n.General.yes
        )
    }
}

extension JourneyPresentation {
    var resetProgressToPreviousValueOnDismiss: some JourneyPresentation {
        let store: SubmitClaimStore = globalPresentableStoreContainer.get()
        let previousProgress = store.state.previousProgress
        return self.onDismiss {
            store.send(.setProgress(progress: previousProgress))
        }
    }
}
