import Claims
import Presentation
import SwiftUI
import hAnalytics
import hCore
import hCoreUI

struct AskForPushnotifications: View {
    let onActionExecuted: (UIViewController?) -> Void
    @State var viewController: UIViewController?
    let text: String
    let pushNotificationStatus: UNAuthorizationStatus
    init(
        text: String,
        onActionExecuted: @escaping (UIViewController?) -> Void
    ) {
        let store: UgglanStore = globalPresentableStoreContainer.get()
        self.pushNotificationStatus = store.state.pushNotificationCurrentStatus()
        self.text = text
        self.onActionExecuted = onActionExecuted
    }

    var body: some View {
        hForm {
            VStack {
                Spacer(minLength: 24)
                Image(Asset.activatePushNotificationsIllustration.name).resizable().aspectRatio(contentMode: .fit)
                    .frame(height: 200)
                Spacer(minLength: 24)
                hText(L10n.claimsActivateNotificationsHeadline, style: .title2).foregroundColor(.primary)
                Spacer(minLength: 24)
                hText(L10n.claimsActivateNotificationsBody, style: .body).foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            .padding([.leading, .trailing], 16)

        }
        .hUseBlur
        .hFormAttachToBottom {
            VStack(spacing: 12) {
                hButton.LargeButtonFilled {
                    let current = UNUserNotificationCenter.current()
                    current.getNotificationSettings(completionHandler: { settings in
                        DispatchQueue.main.async {
                            UIApplication.shared.appDelegate
                                .registerForPushNotifications()
                                .onValue { status in
                                    onActionExecuted(viewController)
                                }
                        }
                    })
                } content: {
                    hText(L10n.claimsActivateNotificationsCta, style: .body)
                        .foregroundColor(hLabelColor.primary.inverted)
                }
                .frame(maxWidth: .infinity, alignment: .bottom)

                hButton.SmallButtonText {
                    onActionExecuted(viewController)
                    let store: UgglanStore = globalPresentableStoreContainer.get()
                    store.send(.setPushNotificationStatus(status: nil))
                } content: {
                    hText(L10n.claimsActivateNotificationsDismiss, style: .footnote)
                        .foregroundColor(hLabelColor.primary)
                }
            }
            .padding([.leading, .trailing], 16)
        }
        .introspectViewController { viewController in
            self.viewController = viewController
        }
    }
}

extension AskForPushnotifications {
    static func journey(for origin: ClaimsOrigin) -> some JourneyPresentation {
        HostingJourney(
            SubmitClaimStore.self,
            rootView: AskForPushnotifications(
                text: L10n.claimsActivateNotificationsBody,
                onActionExecuted: { vc in
                    if hAnalyticsExperiment.claimsTriaging {
                        let store: SubmitClaimStore = globalPresentableStoreContainer.get()
                        store.send(.navigationAction(action: .dismissPreSubmitScreensAndStartClaim(origin: origin)))
                        if #available(iOS 15.0, *) {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                                vc?.sheetPresentationController?.presentedViewController.view.alpha = 0
                                vc?.sheetPresentationController?.detents = [.medium()]
                            }
                        }
                    } else {
                        let store: SubmitClaimStore = globalPresentableStoreContainer.get()
                        if hAnalyticsExperiment.claimsTriaging {
                            store.send(.navigationAction(action: .openNewTriagingScreen))
                        } else {
                            store.send(.navigationAction(action: .openEntrypointScreen))
                        }
                    }
                }
            ),
            style: .detented(.large, modally: false, bgColor: nil)
        ) { action in
            if case let .navigationAction(navigationAction) = action {
                if case .dismissPreSubmitScreensAndStartClaim = navigationAction {
                    if hAnalyticsExperiment.claimsTriaging {
                        ClaimJourneys.showClaimEntrypointGroup(origin: origin)
                            .onAction(SubmitClaimStore.self) { action in
                                if case .dissmissNewClaimFlow = action {
                                    DismissJourney()
                                }
                            }
                    } else {
                        ClaimJourneys.showClaimEntrypointsOld(origin: origin)
                            .onAction(SubmitClaimStore.self) { action in
                                if case .dissmissNewClaimFlow = action {
                                    DismissJourney()
                                }
                            }
                    }
                } else if case .openNewTriagingScreen = navigationAction {
                    ClaimJourneys.showClaimEntrypointGroup(origin: origin)
                } else if case .openEntrypointScreen = navigationAction {
                    ClaimJourneys.showClaimEntrypointsOld(origin: origin)
                }
            } else {
                ClaimJourneys.getScreenForAction(for: action, withHidesBack: true)
            }
        }
        .hidesBackButton
    }
}
