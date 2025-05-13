import Claims
import PresentableStore
import Profile
import SwiftUI
import hCore
import hCoreUI

struct AskForPushNotifications: View {
    let onActionExecuted: () -> Void
    let text: String
    let pushNotificationStatus: UNAuthorizationStatus
    let wrapWithForm: Bool

    init(
        text: String,
        onActionExecuted: @escaping () -> Void,
        wrapWithForm: Bool = false
    ) {
        let store: ProfileStore = globalPresentableStoreContainer.get()
        self.pushNotificationStatus = store.state.pushNotificationCurrentStatus()
        self.text = text
        self.onActionExecuted = onActionExecuted
        self.wrapWithForm = wrapWithForm
    }

    var body: some View {
        if wrapWithForm {
            hForm {
                mainContent
            }
            .hFormContentPosition(.compact)
        } else {
            mainContent
        }
    }

    var mainContent: some View {
        hSection {
            VStack(spacing: .padding24) {
                if !wrapWithForm {
                    Spacer()
                }
                hCoreUIAssets.infoFilled.view
                    .resizable()
                    .frame(width: 24, height: 24)
                    .foregroundColor(hSignalColor.Blue.element)
                    .accessibilityHidden(true)
                VStack(spacing: 0) {
                    hText(L10n.activateNotificationsTitle)
                    hText(text)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, .padding32)
                        .foregroundColor(hTextColor.Opaque.secondary)
                }
                .accessibilityElement(children: .combine)
                hButton(
                    .medium,
                    .primary,
                    content: .init(title: L10n.claimsActivateNotificationsCta),
                    {
                        Task {
                            await UIApplication.shared.appDelegate.registerForPushNotifications()
                            onActionExecuted()
                        }
                    }
                )
                if !wrapWithForm {
                    Spacer()
                }
                hButton(
                    .large,
                    .ghost,
                    content: .init(title: L10n.claimsActivateNotificationsDismiss),
                    {
                        onActionExecuted()
                        let store: ProfileStore = globalPresentableStoreContainer.get()
                        store.send(.setPushNotificationStatus(status: nil))
                    }
                )
                .padding(.bottom, .padding16)
            }
        }
        .sectionContainerStyle(.transparent)
        .background(
            BackgroundView().ignoresSafeArea()
        )
    }
}

struct AskForPushnotifications_Previews: PreviewProvider {
    static var previews: some View {
        AskForPushNotifications(text: "TEXT") {

        }
    }
}
