import Claims
import Embark
import Flow
import Foundation
import Home
import Presentation
import UIKit
import hCore
import hCoreUI
import hGraphQL

extension AppJourney {
    static var claimJourney: some JourneyPresentation {
        AppJourney.claimsJourneyPledgeAndNotificationWrapper { redirect in
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
            case .dataCollection:
                ContinueJourney()
            }
        }
    }

    private static func claimsJourneyPledgeAndNotificationWrapper<RedirectJourney: JourneyPresentation>(
        @JourneyBuilder redirectJourney: @escaping (_ redirect: ExternalRedirect) -> RedirectJourney
    ) -> some JourneyPresentation {
        HonestyPledge.journey {
            AppJourney.notificationJourney {
                let embark = Embark(name: "claims")

                AppJourney.embark(embark, redirectJourney: redirectJourney).hidesBackButton
            }
            .withJourneyDismissButton
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
