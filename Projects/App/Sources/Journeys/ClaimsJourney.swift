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
        //        hAnalyticsEvent.claimFlowType(
        //            claimType: hAnalyticsExperiment.odysseyClaims ? .automation : .manual
        //        )
        //        .send()
        //

        HostingJourney(
            UgglanStore.self,
            rootView: HonestyPledge(),
            style: .modal
        ) {
            action in
            if case .didAcceptHonestyPledge = action {
                submitClaimContractScreen(from: origin)
            }
        }
        .withDismissButton
        .setScrollEdgeNavigationBarAppearanceToStandard

        //        return AppJourney.claimsJourneyPledgeAndNotificationWrapper(from: origin) { redirect in // här
        //            switch redirect {
        //            case .chat:
        //                AppJourney.claimsChat()
        //                    .hidesBackButton
        //                    .withJourneyDismissButton
        //            case .close:
        //                DismissJourney()
        //            case .menu:
        //                ContinueJourney()
        //            case .mailingList:
        //                DismissJourney()
        //            case .offer:
        //                DismissJourney()
        //            case .quoteCartOffer:
        //                DismissJourney()
        //            }
        //        }
    }

    static func submitClaimContractScreen(from origin: ClaimsOrigin) -> some JourneyPresentation {

        HostingJourney(
            ClaimsStore.self,
            rootView: SubmitClaimContactScreen(),
            style: .modal
        ) {
            action in
            if case .submitClaimOccuranceScreen = action {
                submitClaimOccurranceScreen(from: origin)
            }
        }
        .withDismissButton
        .setScrollEdgeNavigationBarAppearanceToStandard
    }

    static func submitClaimOccurranceScreen(from origin: ClaimsOrigin) -> some JourneyPresentation {

        HostingJourney(
            ClaimsStore.self,
            rootView: SubmitClaimOccurrenceScreen(origin: origin),
            style: .modal
        ) {

            action in
            if case .openDatePicker = action {
                openDatePickerScreen()
            } else if case .openLocation = action {
                openLocationScreen()
            } else if case .submitClaimAudioRecordingOrInfo = action {

                switch origin {
                case .generic:
                    openAudioRecordingSceen()
                case .commonClaims:
                    opernObjectInformation()
                case .commonClaims(id: "6"):  //doesn't work
                    opernObjectInformation()
                }
            }
        }
        .withDismissButton
        .setScrollEdgeNavigationBarAppearanceToStandard
    }

    static func openDatePickerScreen() -> some JourneyPresentation {

        HostingJourney(
            ClaimsStore.self,
            rootView: DatePickerScreen(),
            style: .modal
        ) {
            action in
            if case .dissmissNewClaimFlow = action {
                PopJourney()
            }
        }
        .withDismissButton
        .setScrollEdgeNavigationBarAppearanceToStandard
    }

    static func openLocationScreen() -> some JourneyPresentation {

        HostingJourney(
            ClaimsStore.self,
            rootView: LocationPickerScreen(),
            style: .modal
        ) {
            action in
            if case .dismissLocation = action {
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
                DismissJourney()  //change
            }
        }
        .setScrollEdgeNavigationBarAppearanceToStandard
    }

    static func opernObjectInformation() -> some JourneyPresentation {

        HostingJourney(
            ClaimsStore.self,
            rootView: SubmitClaimObjectInformation(),
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
