import Foundation
import Presentation
import hCore

public class ClaimJourneys {
    @JourneyBuilder
    public static func getScreenForAction(for action: ClaimsAction) -> some JourneyPresentation {
        GroupJourney {
            if case let .openPhoneNumberScreen(phoneNumber) = action {
                submitClaimPhoneNumberScreen(phoneNumber: phoneNumber)  //.withJourneyDismissButton
            } else if case let .openDateOfOccurrenceScreen(maxDate) = action {
                submitClaimOccurranceScreen(maxDate: maxDate).withJourneyDismissButton
            } else if case let .openAudioRecordingScreen(questions) = action {
                openAudioRecordingSceen(questions: questions).withJourneyDismissButton
            } else if case .openSuccessScreen = action {
                openSuccessScreen().hidesBackButton
            } else if case let .openSingleItemScreen(maxDate) = action {
                openSingleItemScreen(maxDate: maxDate)
            } else if case .openSummaryScreen = action {
                openSummaryScreen()
            } else if case .openDamagePickerScreen = action {
                openDamagePickerScreen()
            } else if case .openCheckoutNoRepairScreen = action {
                openCheckoutNoRepairScreen()
            } else if case .openFailureSceen = action {
                showClaimFailureScreen()
            } else if case .openSummaryEditScreen = action {
                openSummaryEditScreen()
            } else if case .claimNextSingleItemCheckout = action {
                openCheckoutNoRepairScreen()
            } else if case .openLocationPicker = action {
                openLocationScreen()
            }
        }
    }

    private static func submitClaimPhoneNumberScreen(
        phoneNumber: String
    ) -> some JourneyPresentation {
        HostingJourney(
            ClaimsStore.self,
            rootView: SubmitClaimContactScreen(phoneNumber: phoneNumber),
            style: .detented(.large, modally: false)
        ) { action in
            if case .dissmissNewClaimFlow = action {
                PopJourney()
            } else {
                getScreenForAction(for: action)
            }
        }
    }

    static func submitClaimOccurranceScreen(maxDate: Date) -> some JourneyPresentation {
        HostingJourney(
            ClaimsStore.self,
            rootView: SubmitClaimOccurrenceScreen(),
            style: .detented(.large, modally: false)
        ) {
            action in
            if case .openDatePicker = action {
                openDatePickerScreen(maxDate: maxDate)
            } else if case .openLocationPicker = action {
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
            rootView: DatePickerScreen(title: L10n.Claims.Incident.Screen.Date.Of.incident, maxDate: maxDate),
            style: .default
        ) {
            action in
            if case let .submitClaimDateOfOccurrence(dateOfOccurrence) = action {

                PopJourney()
                    .onPresent {
                        @PresentableStore var store: ClaimsStore
                        store.send(
                            .claimNextDateOfOccurrence(dateOfOccurrence: dateOfOccurrence)
                        )
                    }
            }
        }
        .onAction(
            ClaimsStore.self,
            { action, pre in
                if case .dissmissNewClaimFlow = action {
                    pre.bag.dispose()
                }
            }
        )
        .setScrollEdgeNavigationBarAppearanceToStandard
    }

    static func openDatePickerScreenForPurchasePrice(maxDate: Date) -> some JourneyPresentation {
        HostingJourney(
            ClaimsStore.self,
            rootView: DatePickerScreen(title: L10n.Claims.Item.Screen.Date.Of.Purchase.button, maxDate: maxDate),
            style: .default
        ) {
            action in
            if case let .submitClaimDateOfOccurrence(purchaseDate) = action {
                PopJourney()
                    .onPresent {
                        @PresentableStore var store: ClaimsStore
                        store.send(
                            .setSingleItemPurchaseDate(purchaseDate: purchaseDate)
                        )
                    }
            }
        }
        .onAction(
            ClaimsStore.self,
            { action, pre in
                if case .dissmissNewClaimFlow = action {
                    pre.bag.dispose()
                }
            }
        )
        .setScrollEdgeNavigationBarAppearanceToStandard
    }

    static func openLocationScreen() -> some JourneyPresentation {

        HostingJourney(
            ClaimsStore.self,
            rootView: LocationPickerScreen(),
            style: .default
        ) {
            action in
            if case let .submitClaimLocation(displayName, value) = action {
                PopJourney()
                    .onPresent {
                        @PresentableStore var store: ClaimsStore
                        store.send(.claimNextLocation(displayName: displayName, displayValue: value))
                    }
            }
        }
        .setScrollEdgeNavigationBarAppearanceToStandard
    }

    static func openBrandPickerScreen() -> some JourneyPresentation {
        HostingJourney(
            ClaimsStore.self,
            rootView: ItemPickerScreen<Brand>(
                items: {
                    let store: ClaimsStore = globalPresentableStoreContainer.get()
                    return store.state.newClaim.getBrands().map({ ($0, $0.displayName) })
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
                if store.state.newClaim.shouldShowListOfModels(for: brand) {
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
        .withDismissButton
        .setScrollEdgeNavigationBarAppearanceToStandard
    }

    static func openModelPickerScreen() -> some JourneyPresentation {

        HostingJourney(
            ClaimsStore.self,
            rootView: ItemPickerScreen<Model>(
                items: {
                    let store: ClaimsStore = globalPresentableStoreContainer.get()

                    return store.state.newClaim.getModels().map({ ($0, $0.displayName) })

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
                if case let .setSingleItemModel(_) = action {
                    pre.bag.dispose()
                } else if case .dissmissNewClaimFlow = action {
                    pre.bag.dispose()
                }
            }
        )
        .withDismissButton
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

    static func openAudioRecordingSceen(questions: [String]) -> some JourneyPresentation {
        HostingJourney(ClaimsStore.self, rootView: SubmitClaimAudioRecordingScreen(questions: questions)) { action in
            getScreenForAction(for: action)
        }
        .setScrollEdgeNavigationBarAppearanceToStandard
    }

    private static func openSuccessScreen() -> some JourneyPresentation {
        HostingJourney(
            ClaimsStore.self,
            rootView: SubmitClaimSuccessScreen(),
            style: .default
        ) {
            action in
            if case .dissmissNewClaimFlow = action {
                DismissJourney()
            } else {
                getScreenForAction(for: action)
            }
        }
        .setScrollEdgeNavigationBarAppearanceToStandard
    }
    private static func openSingleItemScreen(maxDate: Date) -> some JourneyPresentation {
        HostingJourney(
            ClaimsStore.self,
            rootView: SubmitClaimSingleItem(),
            style: .default
        ) {
            action in
            if case .openDatePicker = action {
                openDatePickerScreenForPurchasePrice(maxDate: maxDate)
            } else if case .openBrandPicker = action {
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
        .setScrollEdgeNavigationBarAppearanceToStandard
    }

    private static func openSummaryScreen() -> some JourneyPresentation {
        HostingJourney(
            ClaimsStore.self,
            rootView: SubmitClaimSummaryScreen(),
            style: .default
        ) {
            action in
            if case .dissmissNewClaimFlow = action {
                PopJourney()
            } else {
                getScreenForAction(for: action)
            }
        }
        .withDismissButton
        .setScrollEdgeNavigationBarAppearanceToStandard
    }

    private static func openCheckoutNoRepairScreen() -> some JourneyPresentation {

        HostingJourney(
            ClaimsStore.self,
            rootView: SubmitClaimCheckoutNoRepairScreen(),
            style: .default
        ) {
            action in
            if case .openCheckoutTransferringScreen = action {
                openCheckoutTransferringScreen()
            } else if case .claimNextSummary = action {
                openCheckoutTransferringScreen()
            } else {
                getScreenForAction(for: action)
            }
        }
        .withDismissButton
        .setScrollEdgeNavigationBarAppearanceToStandard
    }

    static func openCheckoutTransferringScreen() -> some JourneyPresentation {

        HostingJourney(
            ClaimsStore.self,
            rootView: SubmitClaimCheckoutTransferringScreen(),
            style: .modally(presentationStyle: .fullScreen)
        ) {
            action in
            if case .openCheckoutTransferringDoneScreen = action {
                openCheckoutTransferringDoneScreen()
            } else {
                getScreenForAction(for: action)
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
        .setScrollEdgeNavigationBarAppearanceToStandard
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
                    .allowSwipeDismissAlways,
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
            .withDismissButton
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

}
