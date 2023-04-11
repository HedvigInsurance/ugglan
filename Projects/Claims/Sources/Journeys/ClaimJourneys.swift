import Foundation
import Presentation
import hCore
import hCoreUI

public class ClaimJourneys {

    @JourneyBuilder
    public static func getScreenForAction(
        for action: ClaimsAction,
        withHidesBack: Bool = false
    ) -> some JourneyPresentation {
        if withHidesBack {
            getScreen(for: action).hidesBackButton
        } else {
            getScreen(for: action).showsBackButton
        }
    }

    @JourneyBuilder
    private static func getScreen(for action: ClaimsAction) -> some JourneyPresentation {
        GroupJourney {
            if case let .navigationAction(navigationAction) = action {
                if case let .openPhoneNumberScreen(model) = navigationAction {
                    submitClaimPhoneNumberScreen(model: model).addDismissWithConfirmation()
                } else if case .openDateOfOccurrencePlusLocationScreen = navigationAction {
                    submitClaimOccurrancePlusLocationScreen().addDismissWithConfirmation()
                } else if case .openAudioRecordingScreen = navigationAction {
                    openAudioRecordingSceen().addDismissWithConfirmation()
                } else if case .openSuccessScreen = navigationAction {
                    openSuccessScreen().addDismissWithConfirmation()
                } else if case .openSingleItemScreen = navigationAction {
                    openSingleItemScreen().addDismissWithConfirmation()
                } else if case .openSummaryScreen = navigationAction {
                    openSummaryScreen().addDismissWithConfirmation()
                } else if case .openDamagePickerScreen = navigationAction {
                    openDamagePickerScreen().addDismissWithConfirmation()
                } else if case .openCheckoutNoRepairScreen = navigationAction {
                    openCheckoutNoRepairScreen().addDismissWithConfirmation()
                } else if case .openFailureSceen = navigationAction {
                    showClaimFailureScreen().addDismissWithConfirmation()
                } else if case .openSummaryEditScreen = navigationAction {
                    openSummaryEditScreen().addDismissWithConfirmation()
                } else if case let .openLocationPicker(type) = navigationAction {
                    openLocationScreen(type: type).addDismissWithConfirmation()
                } else if case .openUpdateAppScreen = navigationAction {
                    openUpdateAppTerminationScreen().addDismissWithConfirmation()
                } else if case let .openDatePicker(type) = navigationAction {
                    openDatePickerScreen(type: type)
                }
            }
        }
    }

    private static func submitClaimPhoneNumberScreen(model: FlowClaimPhoneNumberStepModel) -> some JourneyPresentation {
        HostingJourney(
            ClaimsStore.self,
            rootView: SubmitClaimContactScreen(model: model),
            style: .detented(.large, modally: false)
        ) { action in
            getScreenForAction(for: action)
        }
    }

    static func submitClaimOccurrancePlusLocationScreen() -> some JourneyPresentation {
        HostingJourney(
            ClaimsStore.self,
            rootView: SubmitClaimOccurrencePlusLocationScreen(),
            style: .detented(.large, modally: false)
        ) {
            action in
            if case let .navigationAction(.openDatePicker(pickerType)) = action {
                openDatePickerScreen(type: pickerType)
            } else if case let .navigationAction(.openLocationPicker(type)) = action {
                openLocationScreen(type: type)
            } else {
                getScreenForAction(for: action)
            }
        }
    }

    static func openDatePickerScreen(type: ClaimsNavigationAction.DatePickerType) -> some JourneyPresentation {
        return HostingJourney(
            ClaimsStore.self,
            rootView: DatePickerScreen(type: type),
            style: .default
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
    }

    static func openLocationScreen(type: ClaimsNavigationAction.LocationPickerType) -> some JourneyPresentation {

        HostingJourney(
            ClaimsStore.self,
            rootView: LocationPickerScreen(type: type),
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
            ClaimsStore.self,
            rootView: ItemPickerScreen<ClaimFlowItemBrandOptionModel>(
                items: {
                    let store: ClaimsStore = globalPresentableStoreContainer.get()
                    return store.state.singleItemStep?.availableItemBrandOptions
                        .compactMap({ (object: $0, displayName: $0.displayName) }) ?? []
                }(),
                onSelected: { item in
                    let store: ClaimsStore = globalPresentableStoreContainer.get()
                    store.send(.setItemBrand(brand: item))
                }
            ),
            options: .autoPopSelfAndSuccessors
        ) {
            action in
            if case let .setItemBrand(brand) = action {
                let store: ClaimsStore = globalPresentableStoreContainer.get()
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
            ClaimsStore.self,
            { action, pre in
                if case .setSingleItemModel(_) = action {
                    pre.bag.dispose()
                }
            }
        )
    }

    static func openModelPickerScreen() -> some JourneyPresentation {

        HostingJourney(
            ClaimsStore.self,
            rootView: ItemPickerScreen<ClaimFlowItemModelOptionModel>(
                items: {
                    let store: ClaimsStore = globalPresentableStoreContainer.get()
                    return store.state.singleItemStep?.getListOfModels()?.compactMap({ ($0, $0.displayName) }) ?? []

                }(),
                onSelected: { item in
                    let store: ClaimsStore = globalPresentableStoreContainer.get()
                    store.send(.setSingleItemModel(modelName: item))
                }
            )
        ) {
            action in
            ContinueJourney()
        }
        .onAction(
            ClaimsStore.self,
            { action, pre in
                if case .setSingleItemModel = action {
                    pre.bag.dispose()
                }
            }
        )
    }

    static func openDamagePickerScreen() -> some JourneyPresentation {

        HostingJourney(
            ClaimsStore.self,
            rootView: DamamagePickerScreen(),
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
        let store: ClaimsStore = globalPresentableStoreContainer.get()
        let url = store.state.audioRecordingStep!.url
        return HostingJourney(
            ClaimsStore.self,
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
    private static func openSingleItemScreen() -> some JourneyPresentation {
        HostingJourney(
            ClaimsStore.self,
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
            ClaimsStore.self,
            rootView: SubmitClaimSummaryScreen(),
            style: .detented(.large, modally: false)
        ) {
            action in
            getScreenForAction(for: action)
        }
    }

    private static func openCheckoutNoRepairScreen() -> some JourneyPresentation {

        HostingJourney(
            ClaimsStore.self,
            rootView: SubmitClaimCheckoutNoRepairScreen(),
            style: .detented(.large, modally: false)
        ) {
            action in
            if case .navigationAction(.openCheckoutTransferringScreen) = action {
                openCheckoutTransferringScreen()
            } else if case .claimNextSummary = action {
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
            ClaimsStore.self,
            rootView: SubmitClaimEditSummaryScreen()
        ) {
            action in
            getScreenForAction(for: action)
        }
    }

    @JourneyBuilder
    public static func showCommonClaimIfNeeded(
        origin: ClaimsOrigin,
        @JourneyBuilder redirectJourney: @escaping (_ newOrigin: ClaimsOrigin) -> some JourneyPresentation
    ) -> some JourneyPresentation {
        switch origin {
        case .generic:
            HostingJourney(
                ClaimsStore.self,
                rootView: SelectCommonClaim(),
                style: .detented(.large),
                options: [
                    .defaults, .prefersLargeTitles(false), .largeTitleDisplayMode(.always),
                ]
            ) { action in
                if case let .commonClaimOriginSelected(origin) = action {
                    GroupJourney { context in
                        switch origin {
                        case .generic:
                            ContinueJourney()
                        case let .commonClaims(id):
                            redirectJourney(ClaimsOrigin.commonClaims(id: id))
                        }
                    }
                }
            }
            .onPresent({
                let store: ClaimsStore = globalPresentableStoreContainer.get()
                store.send(.fetchCommonClaimsForSelection)
            })
        case .commonClaims:
            redirectJourney(origin)
        }
    }

    private static func showClaimFailureScreen() -> some JourneyPresentation {
        HostingJourney(rootView: ClaimFailureScreen())
            .hidesBackButton
    }

    static func openUpdateAppTerminationScreen() -> some JourneyPresentation {
        HostingJourney(
            ClaimsStore.self,
            rootView: UpdateAppScreen(
                onSelected: {
                    let store: ClaimsStore = globalPresentableStoreContainer.get()
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
    func addDismissWithConfirmation() -> some JourneyPresentation {
        self.withJourneyDismissButtonWithConfirmation(
            withTitle: L10n.General.areYouSure,
            andBody: L10n.Claims.Alert.body,
            andCancelText: L10n.General.no,
            andConfirmText: L10n.General.yes
        )
    }
}
