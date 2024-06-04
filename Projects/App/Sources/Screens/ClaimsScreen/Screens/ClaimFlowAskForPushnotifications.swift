import Claims
import Presentation
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
        } else {
            mainContent
        }
    }

    var mainContent: some View {
        hSection {
            VStack(spacing: 24) {
                Spacer()
                hCoreUIAssets.infoIconFilled.view
                    .resizable()
                    .frame(width: 24, height: 24)
                    .foregroundColor(hSignalColor.blueElement)
                VStack(spacing: 0) {
                    hText(L10n.activateNotificationsTitle)
                    hText(text)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 32)
                        .foregroundColor(hTextColor.secondary)
                }
                hButton.MediumButton(type: .primary) {
                    let current = UNUserNotificationCenter.current()
                    current.getNotificationSettings(completionHandler: { settings in
                        DispatchQueue.main.async {
                            UIApplication.shared.appDelegate
                                .registerForPushNotifications {
                                    onActionExecuted()
                                }
                        }
                    })
                } content: {
                    hText(L10n.claimsActivateNotificationsCta, style: .body)
                }
                .fixedSize()

                Spacer()
                hButton.LargeButton(type: .ghost) {
                    onActionExecuted()
                    let store: ProfileStore = globalPresentableStoreContainer.get()
                    store.send(.setPushNotificationStatus(status: nil))
                } content: {
                    hText(L10n.claimsActivateNotificationsDismiss, style: .footnote)
                        .foregroundColor(hTextColor.primary)
                }
                .padding(.bottom, 16)
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
