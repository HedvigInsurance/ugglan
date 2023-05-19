import Claims
import Contacts
import Embark
import Flow
import Foundation
import Home
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
            if hAnalyticsExperiment.claimsTriaging {
                ClaimJourneys.showClaimEntrypointGroups(origin: origin) { newOrigin in
                    ClaimJourneys.showClaimEntrypointsNew(origin: newOrigin) { newOrigin in
                        honestyPledge(from: newOrigin)
                    }
                }
            } else {
                ClaimJourneys.showClaimEntrypointsOld(origin: origin) { newOrigin in
                    honestyPledge(from: newOrigin)
                }
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
            SubmitClaimStore.self,
            rootView: LoadingViewWithContent(.startClaim) {
                HonestyPledge {
                    let ugglanStore: UgglanStore = globalPresentableStoreContainer.get()
                    if ugglanStore.state.pushNotificationCurrentStatus() != .authorized {
                        let store: SubmitClaimStore = globalPresentableStoreContainer.get()
                        store.send(.navigationAction(action: .openNotificationsPermissionScreen))
                    } else {
                        let store: SubmitClaimStore = globalPresentableStoreContainer.get()
                        store.send(.startClaimRequest(with: origin.id))
                    }
                }
            },
            style: .detented(
                .scrollViewContentSize,
                modally: false
            )
        ) { action in
            if case let .navigationAction(navigationAction) = action {
                if case .openNotificationsPermissionScreen = navigationAction {
                    HostingJourney(
                        SubmitClaimStore.self,
                        rootView: LoadingViewWithContent(.startClaim) {
                            AskForPushnotifications(
                                text: L10n.claimsActivateNotificationsBody,
                                onActionExecuted: {
                                    let store: SubmitClaimStore = globalPresentableStoreContainer.get()
                                    store.send(.startClaimRequest(with: origin.id))
                                }
                            )
                        },
                        style: .detented(.large, modally: false)
                    ) { action in
                        ClaimJourneys.getScreenForAction(for: action, withHidesBack: true)
                    }
                    .hidesBackButton
                } else {
                    ClaimJourneys.getScreenForAction(for: action, withHidesBack: true)
                }
            } else {
                ClaimJourneys.getScreenForAction(for: action, withHidesBack: true)
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
