import AppStateContainer
import SwiftUI
import hCore
import hCoreUI

struct NotificationsCardView: View {
    @AppObservedObject var store: ProfileStore
    var body: some View {
        if store.shouldShowNotificationCard {
            InfoCard(text: L10n.profileAllowNotificationsInfoLabel, type: .info)
                .buttons([
                    .init(
                        buttonTitle: L10n.pushNotificationsAlertActionNotNow,
                        buttonAction: {
                            store.setPushNotificationsTo(date: Date())
                        }
                    ),
                    .init(
                        buttonTitle: L10n.ReferralsAllowPushNotificationSheet.Allow.button,
                        buttonAction: {
                            NotificationCenter.default.post(name: .registerForPushNotifications, object: nil)
                        }
                    ),
                ])
        }
    }
}

#Preview {
    NotificationsCardView()
}
