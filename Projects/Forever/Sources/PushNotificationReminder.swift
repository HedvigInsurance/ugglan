import Flow
import Foundation
import Presentation
import SwiftUI
import UIKit
import hCore
import hCoreUI

struct PushNotificationReminderView: View {
    @PresentableStore var store: ForeverStore

    public var body: some View {
        hForm {
            hSection {
                VStack(spacing: 16) {
                    Image(uiImage: Asset.pushNotificationReminderIllustration.image)
                    L10n.ReferralsAllowPushNotificationSheet.headline.hText(.title1)
                    L10n.ReferralsAllowPushNotificationSheet.body.hText().foregroundColor(hLabelColor.secondary)
                        .multilineTextAlignment(.center)
                }
            }
            .sectionContainerStyle(.transparent).padding(.top, 16)
        }
        .hFormAttachToBottom {
            hButton.LargeButtonFilled {
                let center = UNUserNotificationCenter.current()
                center.requestAuthorization(options: [.alert, .sound, .badge]) {
                    _,
                    _ in
                    DispatchQueue.main.async {
                        UIApplication.shared.registerForRemoteNotifications()
                    }
                    store.send(.dismissPushNotificationSheet)
                }
            } content: {
                L10n.ReferralsAllowPushNotificationSheet.Allow.button.hText()
            }
            .padding()
        }
        .navigationBarItems(
            trailing: Button(action: {
                store.send(.dismissPushNotificationSheet)
            }) {
                L10n.NavBar.skip.hText().foregroundColor(Color(.brand(.destructive)))
            }
        )
    }
}
