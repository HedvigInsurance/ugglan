import Claims
import Presentation
import Profile
import SwiftUI
import hAnalytics
import hCore
import hCoreUI

struct AskForPushnotifications: View {
    let onActionExecuted: () -> Void
    let text: String
    let pushNotificationStatus: UNAuthorizationStatus
    init(
        text: String,
        onActionExecuted: @escaping () -> Void
    ) {
        let store: ProfileStore = globalPresentableStoreContainer.get()
        self.pushNotificationStatus = store.state.pushNotificationCurrentStatus()
        self.text = text
        self.onActionExecuted = onActionExecuted
    }

    var body: some View {
        hForm {
            VStack {
                Spacer(minLength: 24)
                Image(hCoreUIAssets.activatePushNotificationsIllustration.name).resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(height: 200)
                Spacer(minLength: 24)
                hText(L10n.claimsActivateNotificationsHeadline, style: .title2).foregroundColor(.primary)
                Spacer(minLength: 24)
                hText(L10n.claimsActivateNotificationsBody, style: .body).foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            .padding([.leading, .trailing], 16)

        }
        .hFormAttachToBottom {
            VStack(spacing: 12) {
                hButton.LargeButtonPrimary {
                    let current = UNUserNotificationCenter.current()
                    current.getNotificationSettings(completionHandler: { settings in
                        DispatchQueue.main.async {
                            UIApplication.shared.appDelegate
                                .registerForPushNotifications()
                                .onValue { status in
                                    onActionExecuted()
                                }
                        }
                    })
                } content: {
                    hText(L10n.claimsActivateNotificationsCta, style: .body)
                        .foregroundColor(hLabelColor.primary.inverted)
                }
                .frame(maxWidth: .infinity, alignment: .bottom)

                hButton.SmallButtonText {
                    onActionExecuted()
                    let store: ProfileStore = globalPresentableStoreContainer.get()
                    store.send(.setPushNotificationStatus(status: nil))
                } content: {
                    hText(L10n.claimsActivateNotificationsDismiss, style: .footnote)
                        .foregroundColor(hLabelColor.primary)
                }
            }
            .padding([.leading, .trailing], 16)
        }
    }
}

extension AskForPushnotifications {
    static func journey(for origin: ClaimsOrigin) -> some JourneyPresentation {
        HostingJourney(
            SubmitClaimStore.self,
            rootView: AskForPushnotifications(
                text: L10n.claimsActivateNotificationsBody,
                onActionExecuted: {
                    if #available(iOS 15.0, *) {
                        let vc = UIApplication.shared.getTopViewController()
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                            vc?.sheetPresentationController?.presentedViewController.view.alpha = 0
                            vc?.sheetPresentationController?.detents = [.medium()]
                        }
                    }
                    let store: SubmitClaimStore = globalPresentableStoreContainer.get()
                    store.send(.navigationAction(action: .dismissPreSubmitScreensAndStartClaim(origin: origin)))
                }
            ),
            style: .detented(.large, modally: false, bgColor: nil)
        ) { action in
            if case let .navigationAction(navigationAction) = action {
                if case .dismissPreSubmitScreensAndStartClaim = navigationAction {
                    ClaimJourneys.showClaimEntrypointGroup(origin: origin)
                        .onAction(SubmitClaimStore.self) { action in
                            if case .dissmissNewClaimFlow = action {
                                DismissJourney()
                            }
                        }
                } else if case .openTriagingGroupScreen = navigationAction {
                    ClaimJourneys.showClaimEntrypointGroup(origin: origin)
                }
            } else {
                ClaimJourneys.getScreenForAction(for: action, withHidesBack: true)
            }
        }
        .hidesBackButton
    }
}
