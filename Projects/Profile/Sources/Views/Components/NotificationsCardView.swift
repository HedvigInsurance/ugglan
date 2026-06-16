import AppStateContainer
import SwiftUI
import hCore
import hCoreUI

struct NotificationsCardView: View {
    var body: some View {
        InfoCard(text: L10n.profileAllowNotificationsInfoLabel, type: .info)
            .buttons([
                .init(
                    buttonTitle: L10n.pushNotificationsAlertActionNotNow,
                    buttonAction: {
                        let store: ProfileStore = globalAppStateContainer.get()
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

#Preview {
    NotificationsCardView()
}
