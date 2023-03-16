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

        HostingJourney(
            UgglanStore.self,
            rootView: HonestyPledge(),
            style: .modal
        ) {

            action in
            if case .didAcceptHonestyPledge = action {
                PopJourney()  //?
                    .onPresent {
                        @PresentableStore var store: ClaimsStore
                        store.send(.startClaim(from: origin))
                    }
            }
        }
        .withDismissButton
        .setScrollEdgeNavigationBarAppearanceToStandard
    }

    static func submitClaimPhoneNumberScreen(
        from origin: ClaimsOrigin,
        contextInput: String
    ) -> some JourneyPresentation {  //delete origin?

        HostingJourney(
            ClaimsStore.self,
            rootView: SubmitClaimContactScreen(),
            style: .modal
        ) {
            action in
            if case let .submitClaimPhoneNumber(phoneNumberInput) = action {
                PopJourney()  //?
                    .onPresent {
                        @PresentableStore var store: ClaimsStore
                        store.send(
                            .claimNextPhoneNumber(from: origin, phoneNumber: phoneNumberInput, context: contextInput)
                        )  //add context
                    }
            }
        }
        .withDismissButton
        .setScrollEdgeNavigationBarAppearanceToStandard
    }

    static func submitClaimOccurranceScreen(
        from origin: ClaimsOrigin,
        dateOfOccurrence: Date?,
        contextInput: String
    ) -> some JourneyPresentation {

        HostingJourney(
            ClaimsStore.self,
            rootView: SubmitClaimOccurrenceScreen(),
            style: .modal
        ) {

            action in
            if case .openDatePicker = action {
                openDatePickerScreen(from: origin, context: contextInput)
            } else if case .openLocationPicker = action {
                openLocationScreen(from: origin, context: contextInput)
            }  //else if case let .submitClaimDateOfOccurrence(dateOfOccurrence, context) = action {

            //   PopJourney() //?
            //                .onPresent {
            //                    @PresentableStore var store: ClaimsStore
            //                    store.send(.claimNextDateOfOccurrence(dateOfOccurrence: dateOfOccurrence, context: contextInput)) //add context
            //                }

            //                switch origin {
            //                    /* TODO: ADD SELECTION BETWEEN BROKEN COMPUTER AND PHONE */
            //                case .generic:
            //                    openAudioRecordingSceen()
            //                case .commonClaims:
            //                    openObjectInformation()
            //                }
            //            }
        }
        .withDismissButton
        .setScrollEdgeNavigationBarAppearanceToStandard
    }

    static func openDatePickerScreen(from origin: ClaimsOrigin, context: String) -> some JourneyPresentation {  //claims origin?

        HostingJourney(
            ClaimsStore.self,
            rootView: DatePickerScreen(),
            style: .modal
        ) {
            action in
            if case let .submitClaimDateOfOccurrence(dateOfOccurrence) = action {

                PopJourney()  //?
                    .onPresent {
                        @PresentableStore var store: ClaimsStore

                        store.send(
                            .claimNextDateOfOccurrence(
                                from: origin,
                                dateOfOccurrence: dateOfOccurrence,
                                context: context
                            )
                        )  //add context
                        //                    submitClaimOccurranceScreen(from: origin, contextInput: context, dateOfOccurrence: dateOfOccurrence)

                    }
            }
        }
        .withDismissButton
        .setScrollEdgeNavigationBarAppearanceToStandard
    }

    static func openLocationScreen(from origin: ClaimsOrigin, context: String) -> some JourneyPresentation {  //claims origin?

        HostingJourney(
            ClaimsStore.self,
            rootView: LocationPickerScreen(),
            style: .modal
        ) {
            action in
            if case let .submitClaimLocation(location) = action {  //change

                PopJourney()  //?
                    .onPresent {
                        @PresentableStore var store: ClaimsStore
                        store.send(.claimNextLocation(location: location, context: context))  //add context
                        //                    store.send(.claimNextLocation(location: "", context: "")) //add context //change
                    }
                //                PopJourney()
            }
        }
        .setScrollEdgeNavigationBarAppearanceToStandard
    }

    static func openModelPickerScreen() -> some JourneyPresentation {

        HostingJourney(
            ClaimsStore.self,
            rootView: ModelPickerScreen(),
            style: .modal
        ) {
            action in
            if case .dissmissNewClaimFlow = action {
                PopJourney()
            }
        }
        .setScrollEdgeNavigationBarAppearanceToStandard
    }

    static func openDamagePickerScreen() -> some JourneyPresentation {

        HostingJourney(
            ClaimsStore.self,
            rootView: DamamagePickerScreen(),
            style: .modal
        ) {
            action in
            if case .dissmissNewClaimFlow = action {
                PopJourney()
            }
        }
        .setScrollEdgeNavigationBarAppearanceToStandard
    }

    static func openAudioRecordingSceen() -> some JourneyPresentation {

        HostingJourney(
            ClaimsStore.self,
            rootView: SubmitClaimAudioRecordingScreen(),
            style: .modal
        ) {
            action in
            if case .openSuccessScreen = action {
                openSuccessSceen()
            }
        }
        .setScrollEdgeNavigationBarAppearanceToStandard
    }

    static func openSuccessSceen() -> some JourneyPresentation {

        HostingJourney(
            ClaimsStore.self,
            rootView: SubmitClaimSuccessScreen(),
            style: .modal
        ) {
            action in
            if case .dissmissNewClaimFlow = action {
                DismissJourney()
            } else if case .openFreeTextChat = action {
                DismissJourney()
            }
        }
        .setScrollEdgeNavigationBarAppearanceToStandard
    }

    static func openObjectInformation() -> some JourneyPresentation {

        HostingJourney(
            ClaimsStore.self,
            rootView: SubmitClaimObjectInformation(),
            style: .modal
        ) {
            action in
            if case .openSummaryScreen = action {
                openSummaryScreen()
            } else if case .openDatePicker = action {
                //                openDatePickerScreen(from: ClaimsOrigin)
                openLocationScreen()
            } else if case .openLocationPicker = action {
                openLocationScreen()
            } else if case .openDamagePickerScreen = action {
                openDamagePickerScreen()
            } else if case .openModelPicker = action {
                openModelPickerScreen()
            }
        }
        .setScrollEdgeNavigationBarAppearanceToStandard
    }

    static func openSummaryScreen() -> some JourneyPresentation {

        HostingJourney(
            ClaimsStore.self,
            rootView: SubmitClaimSummaryScreen(),
            style: .modal
        ) {
            action in
            if case .openSummaryEditScreen = action {
                openSummaryEditScreen()
            } else if case .openCheckoutNoRepairScreen = action {
                openCheckoutNoRepairScreen()
            }
        }
        .withDismissButton
        .setScrollEdgeNavigationBarAppearanceToStandard
    }

    static func openSummaryEditScreen() -> some JourneyPresentation {

        HostingJourney(
            ClaimsStore.self,
            rootView: SubmitClaimEditSummaryScreen(),
            style: .modal
        ) {
            action in
            if case .openLocationPicker = action {
                openLocationScreen()
            } else if case .openDatePicker = action {
                //                openDatePickerScreen(from: <#ClaimsOrigin#>)
                openLocationScreen()
            } else if case .openDamagePickerScreen = action {
                openDamagePickerScreen()
            } else if case .openModelPicker = action {
                openModelPickerScreen()
            } else if case .dissmissNewClaimFlow = action {
                PopJourney()
            }
        }
        .setScrollEdgeNavigationBarAppearanceToStandard
    }

    static func openCheckoutNoRepairScreen() -> some JourneyPresentation {

        HostingJourney(
            ClaimsStore.self,
            rootView: SubmitClaimCheckoutNoRepairScreen(),
            style: .modal
        ) {
            action in
            if case .openCheckoutTransferringScreen = action {
                openCheckoutTransferringScreen()
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
