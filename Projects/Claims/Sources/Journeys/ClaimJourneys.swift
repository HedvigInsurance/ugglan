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
                    openAudioRecordingSceen().addDismissClaimsFlow().configureTitle(L10n.embarkSubmitClaim)
                } else if case .openSuccessScreen = navigationAction {
                    openSuccessScreen().addDismissClaimsFlow().configureTitle(L10n.embarkSubmitClaim)
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
                    showClaimFailureScreen().addDismissClaimsFlow()
                } else if case .openSummaryEditScreen = navigationAction {
                    openSummaryEditScreen().addDismissClaimsFlow().configureTitle(L10n.Claims.Edit.Screen.title)
                } else if case let .openLocationPicker(type) = navigationAction {
                    openLocationScreen(type: type).configureTitle(L10n.Claims.Incident.Screen.location)
                } else if case .openUpdateAppScreen = navigationAction {
                    openUpdateAppTerminationScreen().addDismissClaimsFlow()
                } else if case let .openDatePicker(type) = navigationAction {
                    openDatePickerScreen(type: type)
                }
            } else {
                if case let .openPhoneNumberScreen(model) = navigationAction {
                    submitClaimPhoneNumberScreenOld(model: model).addDismissClaimsFlow()
                } else if case .openDateOfOccurrencePlusLocationScreen = navigationAction {
                    submitClaimOccurrancePlusLocationScreenOld().addDismissClaimsFlow()
                } else if case .openAudioRecordingScreen = navigationAction {
                    openAudioRecordingSceen().addDismissClaimsFlow().configureTitle(L10n.embarkSubmitClaim)
                } else if case .openSuccessScreen = navigationAction {
                    openSuccessScreen().addDismissClaimsFlow().configureTitle(L10n.embarkSubmitClaim)
                } else if case .openSingleItemScreen = navigationAction {
                    openSingleItemScreenOld().addDismissClaimsFlow()
                } else if case .openSummaryScreen = navigationAction {
                    openSummaryScreen().addDismissClaimsFlow().configureTitle(L10n.Claims.Summary.Screen.title)
                } else if case .openDamagePickerScreen = navigationAction {
                    openDamagePickerScreenOld().addDismissClaimsFlow()
                } else if case .openCheckoutNoRepairScreen = navigationAction {
                    openCheckoutNoRepairScreen().addDismissClaimsFlow()
                        .configureTitle(L10n.Claims.Payout.Summary.title)
                } else if case .openFailureSceen = navigationAction {
                    showClaimFailureScreen().addDismissClaimsFlow()
                } else if case .openSummaryEditScreen = navigationAction {
                    openSummaryEditScreen().addDismissClaimsFlow().configureTitle(L10n.Claims.Edit.Screen.title)
                } else if case let .openLocationPicker(type) = navigationAction {
                    openLocationScreenOld(type: type).addDismissClaimsFlow()
                } else if case .openUpdateAppScreen = navigationAction {
                    openUpdateAppTerminationScreen().addDismissClaimsFlow()
                } else if case let .openDatePicker(type) = navigationAction {
                    openDatePickerScreen(type: type)
                }
            }
        }
    }

    private static func submitClaimPhoneNumberScreen(model: FlowClaimPhoneNumberStepModel) -> some JourneyPresentation {
        HostingJourney(
            SubmitClaimStore.self,
            rootView: SubmitClaimContactScreen(model: model),
            style: .detented(.large, modally: false)
        ) { action in
            getScreenForAction(for: action)
        }
    }

    private static func submitClaimPhoneNumberScreenOld(
        model: FlowClaimPhoneNumberStepModel
    ) -> some JourneyPresentation {
        HostingJourney(
            SubmitClaimStore.self,
            rootView: SubmitClaimContactScreenOld(model: model),
            style: .detented(.large, modally: false)
        ) { action in
            getScreenForAction(for: action)
        }
    }

    static func submitClaimOccurrancePlusLocationScreen() -> some JourneyPresentation {
        HostingJourney(
            SubmitClaimStore.self,
            rootView: SubmitClaimOccurrencePlusLocationScreen(),
            style: .detented(.large, modally: false)
        ) {
            action in
            getScreenForAction(for: action)
        }
    }

    static func submitClaimOccurrancePlusLocationScreenOld() -> some JourneyPresentation {
        HostingJourney(
            SubmitClaimStore.self,
            rootView: SubmitClaimOccurrencePlusLocationScreenOld(),
            style: .detented(.large, modally: false)
        ) {
            action in
            getScreenForAction(for: action)
        }
    }

    static func openDatePickerScreen(type: ClaimsNavigationAction.DatePickerType) -> some JourneyPresentation {
        let screen = DatePickerScreen(type: type)

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
            }
        }
        .configureTitle(screen.title)
        .withDismissButton
    }

    static func openLocationScreen(type: ClaimsNavigationAction.LocationPickerType) -> some JourneyPresentation {
        HostingJourney(
            SubmitClaimStore.self,
            rootView: LocationPickerScreen(type: type),
            style: .detented(.scrollViewContentSize)
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
    }

    static func openLocationScreenOld(type: ClaimsNavigationAction.LocationPickerType) -> some JourneyPresentation {
        HostingJourney(
            SubmitClaimStore.self,
            rootView: LocationPickerScreenOld(type: type),
            style: .default
        ) {
            action in
            if case .setNewLocation = action {
                PopJourney()
            } else {
                getScreen(for: action)
            }
        }
    }

    static func openBrandPickerScreen() -> some JourneyPresentation {
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
                    openModelPickerScreen()
                } else {
                    PopJourney()
                }
            } else {
                getScreenForAction(for: action)
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
            rootView: DamamagePickerScreen(),
            style: .detented(.scrollViewContentSize)
        ) {
            action in
            if case .navigationAction(.dismissScreen) = action {
                PopJourney()
            } else if case .setSingleItemDamage(_) = action {
                PopJourney()
            } else {
                getScreenForAction(for: action)
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
                getScreenForAction(for: action)
            }
        }
    }

    static func openAudioRecordingSceen() -> some JourneyPresentation {
        let store: SubmitClaimStore = globalPresentableStoreContainer.get()
        let url = store.state.audioRecordingStep?.getUrl()
        return HostingJourney(
            SubmitClaimStore.self,
            rootView: SubmitClaimAudioRecordingScreen(url: url),
            style: .detented(.large, modally: false)
        ) { action in
            getScreenForAction(for: action)
        }
    }

    private static func openSuccessScreen() -> some JourneyPresentation {
        HostingJourney(
            rootView: SubmitClaimSuccessScreen(),
            style: .detented(.large, modally: false)
        )
        .hidesBackButton
    }
    private static func openSingleItemScreenOld() -> some JourneyPresentation {
        HostingJourney(
            SubmitClaimStore.self,
            rootView: SubmitClaimSingleItemOld(),
            style: .detented(.large, modally: false)
        ) {
            action in
            if case .navigationAction(.openDatePicker) = action {
                openDatePickerScreen(type: .setDateOfPurchase)
            } else if case .navigationAction(.openBrandPicker) = action {
                openBrandPickerScreen()
            } else {
                getScreenForAction(for: action)
            }
        }
    }

    private static func openSingleItemScreen() -> some JourneyPresentation {
        HostingJourney(
            SubmitClaimStore.self,
            rootView: SubmitClaimSingleItem(),
            style: .detented(.large, modally: false)
        ) {
            action in
            if case .navigationAction(.openDatePicker) = action {
                openDatePickerScreen(type: .setDateOfPurchase)
            } else if case .navigationAction(.openBrandPicker) = action {
                openBrandPickerScreen()
            } else {
                getScreenForAction(for: action)
            }
        }
    }

    private static func openSummaryScreen() -> some JourneyPresentation {
        HostingJourney(
            SubmitClaimStore.self,
            rootView: SubmitClaimSummaryScreen(),
            style: .detented(.large, modally: false)
        ) {
            action in
            getScreenForAction(for: action)
        }
    }

    private static func openCheckoutNoRepairScreen() -> some JourneyPresentation {

        HostingJourney(
            SubmitClaimStore.self,
            rootView: SubmitClaimCheckoutNoRepairScreen(),
            style: .detented(.large, modally: false)
        ) {
            action in
            if case .navigationAction(.openCheckoutTransferringScreen) = action {
                openCheckoutTransferringScreen()
            } else if case .summaryRequest = action {
                openCheckoutTransferringScreen()
            } else {
                getScreenForAction(for: action)
            }
        }
    }

    static func openCheckoutTransferringScreen() -> some JourneyPresentation {

        HostingJourney(
            rootView: SubmitClaimCheckoutTransferringScreen(),
            style: .modally(presentationStyle: .fullScreen, transitionStyle: .crossDissolve)
        )
    }

    private static func openSummaryEditScreen() -> some JourneyPresentation {

        HostingJourney(
            SubmitClaimStore.self,
            rootView: SubmitClaimEditSummaryScreen()
        ) {
            action in
            getScreenForAction(for: action)
        }
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
            style: .detented(.large, modally: false)
        ) { action in
            if case let .setSelectedEntrypoints(entrypoints) = action {
                if !entrypoints.isEmpty {
                    ClaimJourneys.showClaimEntrypointType(origin: origin)
                }
            } else {
                getScreen(for: action)
            }
        }
        .hidesBackButton
        .withJourneyDismissButton
    }

    @JourneyBuilder
    public static func showClaimEntrypointType(
        origin: ClaimsOrigin
    ) -> some JourneyPresentation {
        HostingJourney(
            SubmitClaimStore.self,
            rootView: SelectClaimEntrypointType(selectedEntrypointOptions: { options, selectedEntrypointId in
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
        .showsBackButton
        .withJourneyDismissButton
    }

    @JourneyBuilder
    public static func showClaimEntrypointOption(
        origin: ClaimsOrigin
    ) -> some JourneyPresentation {
        HostingJourney(
            SubmitClaimStore.self,
            rootView: SelectClaimEntrypointOption(onButtonClick: { entrypointId, entrypointOptionId in
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

    static func openUpdateAppTerminationScreen() -> some JourneyPresentation {
        HostingJourney(
            SubmitClaimStore.self,
            rootView: UpdateAppScreen(
                onSelected: {
                    let store: SubmitClaimStore = globalPresentableStoreContainer.get()
                    store.send(.dissmissNewClaimFlow)
                }
            ),
            style: .detented(.large, modally: true)
        ) {
            action in
            getScreenForAction(for: action)
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
