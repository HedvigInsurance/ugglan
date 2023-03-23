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

    static func claimJourney(from origin: ClaimsOrigin) -> some JourneyPresentation {

        hAnalyticsEvent.claimFlowType(
            claimType: hAnalyticsExperiment.odysseyClaims ? .automation : .manual
        )
        .send()

        return AppJourney.claimsJourneyPledgeAndNotificationWrapper(from: origin) { redirect in
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

    static func startSubmitClaimsFlow(from origin: ClaimsOrigin) -> some JourneyPresentation {
        HostingJourney(ClaimsStore.self, rootView: HonestyPledge(), style: .detented(.scrollViewContentSize)) {
            action in
            getScreenForAction(for: action)
        }
        .onAction(UgglanStore.self) { action, _ in
            if case .didAcceptHonestyPledge = action {
                @PresentableStore var store: ClaimsStore
                store.send(.startClaim(from: origin))
            }
        }
    }

    static func submitClaimPhoneNumberScreen(
        contextInput: String,
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
                    .claimNextPhoneNumber(phoneNumber: phoneNumberInput, context: contextInput)
                )
            }
        }
        .setScrollEdgeNavigationBarAppearanceToStandard
    }

    @JourneyBuilder
    private static func getScreenForAction(for action: ClaimsAction) -> some JourneyPresentation {
        if case let .openPhoneNumberScreen(contextInput, phoneNumber) = action {
            AppJourney.submitClaimPhoneNumberScreen(contextInput: contextInput, phoneNumber: phoneNumber)
                .withJourneyDismissButton
        } else if case let .openDateOfOccurrenceScreen(contextInput) = action {
            AppJourney.submitClaimOccurranceScreen(context: contextInput).withJourneyDismissButton
        } else if case let .openAudioRecordingScreen(contextInput) = action {
            AppJourney.openAudioRecordingSceen(context: contextInput).withJourneyDismissButton
        } else if case .openSuccessScreen = action {
            AppJourney.openSuccessScreen()
        } else if case let .openSingleItemScreen(contextInput) = action {
            AppJourney.openSingleItemScreen(context: contextInput)
        } else if case let .openSummaryScreen(contextInput) = action {
            AppJourney.openSummaryScreen(context: contextInput)
        } else if case .openBrandPicker = action {
            AppJourney.openBrandPickerScreen()
        } else if case .openDamagePickerScreen = action {
            openDamagePickerScreen()
        } else if case let .openSummaryEditScreen(context) = action {
            AppJourney.openSummaryEditScreen(context: context)
        } else if case let .openCheckoutNoRepairScreen(contextInput) = action {
            AppJourney.openCheckoutNoRepairScreen(context: contextInput)
        }
    }

    static func submitClaimOccurranceScreen(context: String) -> some JourneyPresentation {
        HostingJourney(
            ClaimsStore.self,
            rootView: SubmitClaimOccurrenceScreen(),
            style: .detented(.large, modally: false)
        ) {
            action in
            if case .openDatePicker = action {
                openDatePickerScreen(context: context)
            } else if case .openLocationPicker = action {
                openLocationScreen(context: context)
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
                        .claimNextDateOfOccurrenceAndLocation(context: context)
                    )
                }
            }
        )
        .setScrollEdgeNavigationBarAppearanceToStandard
    }

    static func openDatePickerScreen(context: String) -> some JourneyPresentation {

        HostingJourney(
            ClaimsStore.self,
            rootView: DatePickerScreen(),
            style: .default
        ) {
            action in
            if case let .submitClaimDateOfOccurrence(dateOfOccurrence) = action {

                PopJourney()
                    .onPresent {
                        @PresentableStore var store: ClaimsStore

                        store.send(
                            .claimNextDateOfOccurrence(
                                dateOfOccurrence: dateOfOccurrence,
                                context: context
                            )
                        )
                    }
            }
        }
        .setScrollEdgeNavigationBarAppearanceToStandard
    }

    static func openDatePickerScreenForPurchasPrice(context: String) -> some JourneyPresentation {

        HostingJourney(
            ClaimsStore.self,
            rootView: DatePickerScreen(),
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

    static func openLocationScreen(context: String) -> some JourneyPresentation {

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
                        store.send(.claimNextLocation(displayName: displayName, displayValue: value, context: context))
                    }
            }
        }
        .setScrollEdgeNavigationBarAppearanceToStandard
    }

    static func openBrandPickerScreen() -> some JourneyPresentation {

        HostingJourney(
            ClaimsStore.self,
            rootView: BrandPickerScreen()
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
        .withDismissButton
        .setScrollEdgeNavigationBarAppearanceToStandard
    }

    static func openModelPickerScreen() -> some JourneyPresentation {

        HostingJourney(
            ClaimsStore.self,
            rootView: ModelPickerScreen()
        ) {
            action in
            if case .setSingleItemModel(_) = action {
                DismissJourney()
            }
        }
        .onAction(
            ClaimsStore.self,
            { action, pre in
                if case let .submitModel(model) = action {
                    @PresentableStore var store: ClaimsStore
                    store.send(.setSingleItemModel(modelName: model))
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
            if case let .setSingleItemDamage(_) = action {
                PopJourney()
            } else {
                getScreenForAction(for: action)
            }
        }
        .setScrollEdgeNavigationBarAppearanceToStandard
    }

    static func openAudioRecordingSceen(context: String) -> some JourneyPresentation {
        HostingJourney(ClaimsStore.self, rootView: SubmitClaimAudioRecordingScreen()) { action in
            getScreenForAction(for: action)
        }
        .onAction(
            ClaimsStore.self,
            { action, _ in
                if case let .submitAudioRecording(audioURL) = action {
                    @PresentableStore var store: ClaimsStore
                    store.send(.claimNextAudioRecording(audioURL: audioURL, context: context))
                }
            }
        )
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

    static func openSingleItemScreen(context: String) -> some JourneyPresentation {
        HostingJourney(
            ClaimsStore.self,
            rootView: SubmitClaimSingleItem(),
            style: .default
        ) {
            action in
            if case .openDatePicker = action {
                openDatePickerScreenForPurchasPrice(context: context)
            } else {
                getScreenForAction(for: action)
            }
        }
        .onAction(
            ClaimsStore.self,
            { action, _ in
                if case let .submitSingleItem(purchasePrice) = action {
                    @PresentableStore var store: ClaimsStore
                    store.send(.claimNextSingleItem(context: context, purchasePrice: purchasePrice))
                }
            }
        )
        .setScrollEdgeNavigationBarAppearanceToStandard
    }

    static func openSummaryScreen(context: String) -> some JourneyPresentation {

        HostingJourney(
            ClaimsStore.self,
            rootView: SubmitClaimSummaryScreen(),
            style: .default
        ) {
            action in
            if case .openSummaryEditScreen = action {
                openSummaryEditScreen(context: context)
            } else if case .claimNextSingleItemCheckout(context) = action {
                openCheckoutNoRepairScreen(context: context)
            } else {
                getScreenForAction(for: action)
                //=======
                //                PopJourney()
                //                    .onPresent {
                //                        @PresentableStore var store: ClaimsStore
                //                        store.send(.claimNextSummary(context: context)) //maybe need to send in something else?
                //                    }
                //>>>>>>> Stashed changes
            }
        }
        .onAction(
            ClaimsStore.self,
            { action, _ in
                if case .submitSummary = action {
                    @PresentableStore var store: ClaimsStore
                    store.send(.claimNextSummary(context: context))
                }
            }
        )
        .withDismissButton
        .setScrollEdgeNavigationBarAppearanceToStandard
    }

    static func openSummaryEditScreen(context: String) -> some JourneyPresentation {

        HostingJourney(
            ClaimsStore.self,
            rootView: SubmitClaimEditSummaryScreen()
        ) {
            action in
            if case .openLocationPicker = action {
                openLocationScreen(context: context)
            } else {
                getScreenForAction(for: action)
            }
        }
        .setScrollEdgeNavigationBarAppearanceToStandard
    }

    static func openCheckoutNoRepairScreen(context: String) -> some JourneyPresentation {

        HostingJourney(
            ClaimsStore.self,
            rootView: SubmitClaimCheckoutNoRepairScreen(),
            style: .default
        ) {
            action in
            if case .openCheckoutTransferringScreen = action {
                openCheckoutTransferringScreen()
            } else if case .submitSingleItemCheckout = action {

                PopJourney()
                    .onPresent {
                        @PresentableStore var store: ClaimsStore
                        store.send(.claimNextSingleItemCheckout(context: context))
                    }
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
        from origin: ClaimsOrigin,
        @JourneyBuilder redirectJourney: @escaping (_ redirect: ExternalRedirect) -> RedirectJourney
    ) -> some JourneyPresentation {
        if hAnalyticsExperiment.odysseyClaims {
            odysseyClaims(from: origin).withJourneyDismissButton
        } else {
            HonestyPledge.journey {
                AppJourney.notificationJourney {
                    let embark = Embark(name: "claims")
                    AppJourney.embark(embark, redirectJourney: redirectJourney).hidesBackButton
                }
                .withJourneyDismissButton
            }
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
