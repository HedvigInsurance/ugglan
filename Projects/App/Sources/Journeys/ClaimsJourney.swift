import Claims
import Embark
import Flow
import Foundation
import Home
import Odyssey
import OdysseyKit
import Presentation
import UIKit
import hAnalytics
import hCore
import hCoreUI
import hGraphQL

extension AppJourney {

    static func claimDetailJourney(claim: Claim) -> some JourneyPresentation {
        HostingJourney(
            UgglanStore.self,
            rootView: ClaimDetailView(claim: claim),
            options: [.embedInNavigationController]
        ) { action in
            DismissJourney()
        }
        .inlineTitle()
        .configureTitle(L10n.ClaimStatus.title)
    }

    static func claimsInfoJourney() -> some JourneyPresentation {
        Journey(ClaimsInfoPager())
            .onAction(ClaimsStore.self) { action in
                if case .submitNewClaim = action {
                    DismissJourney()
                }
            }
    }

    @JourneyBuilder
    static func startClaimsJourney(from origin: ClaimsOrigin) -> some JourneyPresentation {
        if hAnalyticsExperiment.claimsFlow {
            showCommonClaimIfNeeded(origin: origin) { newOrigin in
                honestyPledge(from: newOrigin)
                //                {
                //                    AppJourney.notificationJourney {
                //                        AppJourney.getScreenForAction(for: .openPhoneNumberScreen(phoneNumber: ""))
                ////                        ContinueJourney().onPresent {
                ////                            let store: ClaimsStore = globalPresentableStoreContainer.get()
                ////                            store.send(.startClaim(from: newOrigin.id))
                ////                        }.onAction(ClaimsStore.self) { action in
                ////                            getScreenForAction(for: action)
                ////                        }
                //                    }
            }
            .hidesBackButton
        } else if hAnalyticsExperiment.odysseyClaims {
            showCommonClaimIfNeeded(origin: origin) { newOrigin in
                odysseyClaims(from: newOrigin)
            }
        } else {
            claimsJourneyPledgeAndNotificationWrapper { redirect in
                switch redirect {
                case .chat:
                    AppJourney.claimsChat()
                        .hidesBackButton
                        .withJourneyDismissButton
                case .close:
                    DismissJourney()
                case .menu:
                    ContinueJourney()
                case .mailingList:
                    DismissJourney()
                case .offer:
                    DismissJourney()
                case .quoteCartOffer:
                    DismissJourney()
                }
            }
        }
    }

    private static func honestyPledge(from origin: ClaimsOrigin) -> some JourneyPresentation {
        HostingJourney(
            ClaimsStore.self,
            rootView: LoadingViewWithContent(.startClaim(from: origin.id)) { HonestyPledge() },
            style: .detented(.scrollViewContentSize, modally: false)
        ) { action in
            getScreenForAction(for: action).hidesBackButton
        }
        .onAction(UgglanStore.self) { action, _ in
            if case .didAcceptHonestyPledge = action {
                @PresentableStore var store: ClaimsStore
                store.send(.startClaim(from: origin.id))
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
            getScreenForAction(for: action)
        }
        .onAction(ClaimsStore.self) { action, _ in
            if case let .submitClaimPhoneNumber(phoneNumberInput) = action {
                @PresentableStore var store: ClaimsStore
                store.send(
                    .claimNextPhoneNumber(phoneNumber: phoneNumberInput)
                )
            }
        }
        .setScrollEdgeNavigationBarAppearanceToStandard
    }

    @JourneyBuilder
    private static func getScreenForAction(for action: ClaimsAction) -> some JourneyPresentation {
        if case let .openPhoneNumberScreen(phoneNumber) = action {
            AppJourney.submitClaimPhoneNumberScreen(phoneNumber: phoneNumber).withJourneyDismissButton
        } else if case let .openDateOfOccurrenceScreen(maxDate) = action {
            AppJourney.submitClaimOccurranceScreen(maxDate: maxDate).withJourneyDismissButton
        } else if case let .openAudioRecordingScreen(questions) = action {
            AppJourney.openAudioRecordingSceen(questions: questions).withJourneyDismissButton
        } else if case .openSuccessScreen = action {
            AppJourney.openSuccessScreen()
        } else if case let .openSingleItemScreen(maxDate) = action {
            AppJourney.openSingleItemScreen(maxDate: maxDate)
        } else if case .openSummaryScreen = action {
            AppJourney.openSummaryScreen()
        } else if case .openDamagePickerScreen = action {
            openDamagePickerScreen()
        } else if case .openCheckoutNoRepairScreen = action {
            AppJourney.openCheckoutNoRepairScreen()
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
        .onAction(
            ClaimsStore.self,
            { action, _ in
                if case .submitOccuranceAndLocation = action {
                    @PresentableStore var store: ClaimsStore
                    store.send(
                        .claimNextDateOfOccurrenceAndLocation
                    )
                }
            }
        )
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
            rootView: BrandPickerScreen(),
            options: .autoPopSelfAndSuccessors
        ) {
            action in
            if case let .submitBrand(brand) = action {
                openModelPickerScreen()
                    .onPresent {
                        @PresentableStore var store: ClaimsStore
                        store.send(.setSingleItemBrand(brand: brand))
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
        .withDismissButton
        .setScrollEdgeNavigationBarAppearanceToStandard
    }

    static func openModelPickerScreen() -> some JourneyPresentation {

        HostingJourney(
            ClaimsStore.self,
            rootView: ModelPickerScreen()
        ) {
            action in
            ContinueJourney()
        }
        .onAction(
            ClaimsStore.self,
            { action, pre in
                if case let .submitModel(model) = action {
                    @PresentableStore var store: ClaimsStore
                    pre.bag.dispose()
                    store.send(.setSingleItemModel(modelName: model))
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

    static func openSuccessScreen() -> some JourneyPresentation {
        HostingJourney(
            ClaimsStore.self,
            rootView: SubmitClaimSuccessScreen(),
            style: .default
        ) {
            action in
            if case .dissmissNewClaimFlow = action {
                DismissJourney()
            } else if case .openFreeTextChat = action {
                AppJourney.freeTextChat()
            } else {
                getScreenForAction(for: action)
            }
        }
        .setScrollEdgeNavigationBarAppearanceToStandard
    }
    static func openSingleItemScreen(maxDate: Date) -> some JourneyPresentation {
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

    static func openSummaryScreen() -> some JourneyPresentation {
        HostingJourney(
            ClaimsStore.self,
            rootView: SubmitClaimSummaryScreen(),
            style: .default
        ) {
            action in
            if case .openSummaryEditScreen = action {
                openSummaryEditScreen()
            } else if case .claimNextSingleItemCheckout = action {
                openCheckoutNoRepairScreen()
            } else {
                getScreenForAction(for: action)
            }
        }
        .onAction(
            ClaimsStore.self,
            { action, _ in
                if case .submitSummary = action {
                    @PresentableStore var store: ClaimsStore
                    store.send(.claimNextSummary)
                }
            }
        )
        .withDismissButton
        .setScrollEdgeNavigationBarAppearanceToStandard
    }

    static func openSummaryEditScreen() -> some JourneyPresentation {

        HostingJourney(
            ClaimsStore.self,
            rootView: SubmitClaimEditSummaryScreen()
        ) {
            action in
            if case .openLocationPicker = action {
                openLocationScreen()
            } else if case .dissmissNewClaimFlow = action {
                PopJourney()
            } else {
                getScreenForAction(for: action)
            }
        }
        .setScrollEdgeNavigationBarAppearanceToStandard
    }

    static func openCheckoutNoRepairScreen() -> some JourneyPresentation {

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
        .onAction(
            ClaimsStore.self,
            { action, _ in
                if case .submitSummary = action {
                    @PresentableStore var store: ClaimsStore
                    store.send(.claimNextSingleItemCheckout)
                }
            }
        )
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
            } else if case .dissmissNewClaimFlow = action {
                PopJourney()
            } else {
                getScreenForAction(for: action)
            }
        }
    }

    static func openCheckoutTransferringDoneScreen() -> some JourneyPresentation {

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

    @JourneyBuilder
    private static func claimsJourneyPledgeAndNotificationWrapper<RedirectJourney: JourneyPresentation>(
        @JourneyBuilder redirectJourney: @escaping (_ redirect: ExternalRedirect) -> RedirectJourney
    ) -> some JourneyPresentation {
        HonestyPledge.journey(style: .detented(.scrollViewContentSize)) {
            AppJourney.notificationJourney {
                let embark = Embark(name: "claims")
                AppJourney.embark(embark, redirectJourney: redirectJourney).hidesBackButton
            }
        }
    }

    @JourneyBuilder
    private static func showCommonClaimIfNeeded(
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
            .withDismissButton
        case .commonClaims:
            redirectJourney(origin)
        }
    }

    static func odysseyClaims(from origin: ClaimsOrigin) -> some JourneyPresentation {
        return OdysseyRoot(
            name: "mainRouter",
            initialURL: "/automation-claim",
            scopeValues: origin.initialScopeValues
        ) { destinationURL in
            let store: ClaimsStore = globalPresentableStoreContainer.get()
            store.send(.odysseyRedirect(url: destinationURL))
        }
        .disposableHostingJourney
        .setStyle(.detented(.large))
        .setOptions([])
        .onAction(ClaimsStore.self) { action in
            if case let .odysseyRedirect(urlString) = action {
                switch urlString {
                case "hedvig://chat":
                    AppJourney.claimsChat()
                        .hidesBackButton
                        .withJourneyDismissButton
                case "hedvig://close":
                    DismissJourney()
                default:
                    ContinueJourney()
                        .onPresent {
                            guard let url = URL(string: urlString), url.isHTTP else {
                                return
                            }

                            if UIApplication.shared.canOpenURL(url) {
                                UIApplication.shared.open(url)
                            }
                        }
                }
            }
        }
    }

    static func commonClaimDetailJourney(claim: CommonClaim) -> some JourneyPresentation {
        Journey(
            CommonClaimDetail(claim: claim),
            style: .detented(.medium, .large),
            options: .defaults
        )
        .onAction(ClaimsStore.self) { action in
            if case .submitNewClaim = action {
                DismissJourney()
            }
        }
        .withJourneyDismissButton
    }
}

extension AppJourney {
    static func notificationJourney<Next: JourneyPresentation>(
        @JourneyBuilder _ next: @escaping () -> Next
    ) -> some JourneyPresentation {
        Journey(NotificationLoader(), style: .detented(.large, modally: false)) { authorization in
            switch authorization {
            case .notDetermined:
                Journey(
                    ClaimsAskForPushnotifications(),
                    style: .detented(.large, modally: false)
                ) { _ in
                    next()
                }
            default:
                next()
            }
        }
    }
}

extension AppJourney {
    static func embark<RedirectJourney: JourneyPresentation>(
        _ embark: Embark,
        style: PresentationStyle = .default,
        @JourneyBuilder redirectJourney: @escaping (_ redirect: ExternalRedirect) -> RedirectJourney
    ) -> some JourneyPresentation {
        Journey(embark, style: style) { redirect in
            redirectJourney(redirect)
        }
    }
}
extension JourneyPresentation {
    func sendActionOnDismiss<S: Store>(_ storeType: S.Type, _ action: S.Action) -> Self {
        return self.onDismiss {
            let store: S = self.presentable.get()

            store.send(action)
        }
    }
}
