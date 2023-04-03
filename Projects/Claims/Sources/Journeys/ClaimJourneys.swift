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
    static func getScreen(for action: ClaimsAction) -> some JourneyPresentation {
        GroupJourney {
            if case let .navigationAction(navigationAction) = action {
                if case let .openPhoneNumberScreen(model) = navigationAction {
                    submitClaimPhoneNumberScreen(model: model).addDismissWithConfirmation()
                } else if case .openDateOfOccurrenceScreen = navigationAction {
                    submitClaimOccurranceScreen().addDismissWithConfirmation()
                } else if case .openAudioRecordingScreen = navigationAction {
                    openAudioRecordingSceen().addDismissWithConfirmation()
                } else if case .openSuccessScreen = navigationAction {
                    openSuccessScreen().addDismissWithConfirmation()
                } else if case let .openSingleItemScreen(maxDate) = navigationAction {
                    openSingleItemScreen(maxDate: maxDate).addDismissWithConfirmation()
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
                } else if case .openLocationPicker = navigationAction {
                    openLocationScreen().addDismissWithConfirmation()
                } else if case .openUpdateAppScreen = navigationAction {
                    openUpdateAppTerminationScreen().addDismissWithConfirmation()
                } else if case .openCheckoutTransferringDoneScreen = navigationAction {
                    openCheckoutTransferringDoneScreen()
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
            if case .dissmissNewClaimFlow = action {
                PopJourney()
            } else {
                getScreenForAction(for: action)
            }
        }
    }

    static func submitClaimOccurranceScreen() -> some JourneyPresentation {
        HostingJourney(
            ClaimsStore.self,
            rootView: SubmitClaimOccurrenceScreen(),
            style: .detented(.large, modally: false)
        ) {
            action in
            if case .navigationAction(.openDatePicker) = action {
                let store: ClaimsStore = globalPresentableStoreContainer.get()
                let maxDate = store.state.dateOfOccurenceStep?.getMaxDate() ?? Date()
                openDatePickerScreen(maxDate: maxDate)
            } else if case .navigationAction(.openLocationPicker) = action {
                openLocationScreen()
            } else {
                getScreenForAction(for: action)
            }
        }
        .setScrollEdgeNavigationBarAppearanceToStandard
    }

    static func openDatePickerScreen(maxDate: Date) -> some JourneyPresentation {
        HostingJourney(
            ClaimsStore.self,
            rootView: DatePickerScreen(title: L10n.Claims.Incident.Screen.Date.Of.incident, maxDate: maxDate) { date in
                let store: ClaimsStore = globalPresentableStoreContainer.get()
                store.send(.setNewDate(dateOfOccurrence: date.localDateString))
            },
            style: .default
        ) {
            action in
            if case .setNewDate = action {
                PopJourney()
            } else if case .dissmissNewClaimFlow = action {
                PopJourney()
            }
        }
        .setScrollEdgeNavigationBarAppearanceToStandard
    }

    static func openDatePickerScreenForPurchasePrice(maxDate: Date) -> some JourneyPresentation {
        HostingJourney(
            ClaimsStore.self,
            rootView: DatePickerScreen(title: L10n.Claims.Item.Screen.Date.Of.Purchase.button, maxDate: maxDate) {
                date in
                let store: ClaimsStore = globalPresentableStoreContainer.get()
                store.send(.setSingleItemPurchaseDate(purchaseDate: date))
            },
            style: .default
        ) {
            action in
            if case .dissmissNewClaimFlow = action {
                PopJourney()
            } else if case .setSingleItemPurchaseDate = action {
                PopJourney()
            }
        }
        .setScrollEdgeNavigationBarAppearanceToStandard
    }

    static func openLocationScreen() -> some JourneyPresentation {

        HostingJourney(
            ClaimsStore.self,
            rootView: LocationPickerScreen(),
            style: .default
        ) {
            action in
            if case .setNewLocation = action {
                PopJourney()
            }
        }
        .setScrollEdgeNavigationBarAppearanceToStandard
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
                } else if case .dissmissNewClaimFlow = action {
                    pre.bag.dispose()
                }
            }
        )
        .setScrollEdgeNavigationBarAppearanceToStandard
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
                } else if case .dissmissNewClaimFlow = action {
                    pre.bag.dispose()
                }
            }
        )
        .setScrollEdgeNavigationBarAppearanceToStandard
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
        .setScrollEdgeNavigationBarAppearanceToStandard
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
            ClaimsStore.self,
            rootView: SubmitClaimSuccessScreen(),
            style: .detented(.large, modally: false)
        ) {
            action in
            if case .dissmissNewClaimFlow = action {
                DismissJourney()
            } else {
                getScreenForAction(for: action)
            }
        }
        .hidesBackButton
        .setScrollEdgeNavigationBarAppearanceToStandard
    }
    private static func openSingleItemScreen(maxDate: Date) -> some JourneyPresentation {
        HostingJourney(
            ClaimsStore.self,
            rootView: SubmitClaimSingleItem(),
            style: .detented(.large, modally: false)
        ) {
            action in
            if case .navigationAction(.openDatePicker) = action {
                openDatePickerScreenForPurchasePrice(maxDate: maxDate)
            } else if case .navigationAction(.openBrandPicker) = action {
                openBrandPickerScreen()
            } else {
                getScreenForAction(for: action)
            }
        }
        .onAction(
            ClaimsStore.self,
            { action, _ in
                if case let .submitSingleItem(purchasePrice) = action {
                    @PresentableStore var store: ClaimsStore
                    store.send(.claimNextSingleItem(purchasePrice: purchasePrice))
                }
            }
        )
    }

    private static func openSummaryScreen() -> some JourneyPresentation {
        HostingJourney(
            ClaimsStore.self,
            rootView: SubmitClaimSummaryScreen(),
            style: .detented(.large, modally: false)
        ) {
            action in
            if case .dissmissNewClaimFlow = action {
                PopJourney()
            } else {
                getScreenForAction(for: action)
            }
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
            ClaimsStore.self,
            rootView: SubmitClaimCheckoutTransferringScreen(),
            style: .modally(presentationStyle: .fullScreen)
        ) {
            action in
            getScreenForAction(for: action)
        }
        .onPresent {
            Task {
                await delay(4)
                let store: ClaimsStore = globalPresentableStoreContainer.get()
                store.send(.claimNextSingleItemCheckout)
            }
        }
    }

    private static func openCheckoutTransferringDoneScreen() -> some JourneyPresentation {

        HostingJourney(
            ClaimsStore.self,
            rootView: SubmitClaimCheckoutTransferringDoneScreen(),
            style: .modally(presentationStyle: .fullScreen)
        ) {
            action in
            if case .dissmissNewClaimFlow = action {
                DismissJourney()
            } else {
                getScreenForAction(for: action)
            }
        }
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
        HostingJourney(
            ClaimsStore.self,
            rootView: ClaimFailureScreen()
        ) { action in
            if case .dissmissNewClaimFlow = action {
                DismissJourney()
            }
        }
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
