import Claims
import Contacts
import Flow
import Foundation
import Home
import Presentation
import UIKit
import hCore
import hCoreUI
import hGraphQL

extension AppJourney {

    static func claimDetailJourney(claim: ClaimModel) -> some JourneyPresentation {
        HostingJourney(
            ClaimsStore.self,
            rootView: ClaimDetailView(claim: claim)
        ) { action in
            if case .closeClaimStatus = action {
                PopJourney()
            } else if case let .navigation(navAction) = action {
                if case let .openFilesFor(claim, files) = navAction {
                    openFilesFor(claim: claim, files: files)
                }
            }
        }
        .configureTitle(L10n.claimsYourClaim)
        .hidesBottomBarWhenPushed
    }

    private static func openFilesFor(claim: ClaimModel, files: [File]) -> some JourneyPresentation {
        HostingJourney(
            ClaimsStore.self,
            rootView: ClaimFilesView(endPoint: claim.targetFileUploadUri, files: files),
            style: .modally(presentationStyle: .overFullScreen),
            options: .largeNavigationBar
        ) { action in
            if case let .navigation(navAction) = action {
                if case .dismissAddFiles = navAction {
                    PopJourney()
                }
            }
        }
        .onDismiss {
            let store: ClaimsStore = globalPresentableStoreContainer.get()
            store.send(.refreshFiles)
        }
        .withDismissButton
        .configureTitle(L10n.ClaimStatusDetail.addedFiles)

    }

    @JourneyBuilder
    static func startClaimsJourney(from origin: ClaimsOrigin) -> some JourneyPresentation {
        honestyPledge(from: origin)
    }

    private static func honestyPledge(from origin: ClaimsOrigin) -> some JourneyPresentation {
        HostingJourney(
            SubmitClaimStore.self,
            rootView: HonestyPledge.journey(from: origin),
            style: .detented(.scrollViewContentSize, bgColor: nil),
            options: [.defaults, .blurredBackground]
        ) { action in
            if case let .navigationAction(navigationAction) = action {
                if case .dismissPreSubmitScreensAndStartClaim = navigationAction {
                    ClaimJourneys.showClaimEntrypointGroup(origin: origin)
                        .onAction(SubmitClaimStore.self) { action in
                            if case .dissmissNewClaimFlow = action {
                                DismissJourney()
                            }
                        }
                } else if case .openNotificationsPermissionScreen = navigationAction {
                    AskForPushnotifications.journey(for: origin)
                } else if case .openTriagingGroupScreen = navigationAction {
                    ClaimJourneys.showClaimEntrypointGroup(origin: origin)
                }
            } else if case .dissmissNewClaimFlow = action {
                DismissJourney()
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

extension JourneyPresentation {
    func sendActionOnDismiss<S: Store>(_ storeType: S.Type, _ action: S.Action) -> Self {
        return self.onDismiss {
            let store: S = self.presentable.get()

            store.send(action)
        }
    }
}
