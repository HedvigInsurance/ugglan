import Presentation
import SwiftUI
import hCore
import hCoreUI

public struct ClaimFlowAskForPushnotifications: View {
    let onActionExecuted: () -> Void

    init(
        onActionExecuted: @escaping () -> Void
    ) {
        self.onActionExecuted = onActionExecuted
    }

    public var body: some View {
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
        .hFormAttachToBottom {
            VStack {
                hButton.LargeButtonFilled {
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
                } content: {
                    hText(L10n.claimsActivateNotificationsDismiss, style: .footnote)
                        .foregroundColor(hLabelColor.primary)
                }
            }
            .padding([.leading, .trailing], 16)
        }
    }
}
