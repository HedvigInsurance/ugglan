import Presentation
import SwiftUI
import hCore
import hCoreUI

struct NotificationsCardView: View {
    @PresentableStore var ugglanStore: UgglanStore
    var body: some View {
        PresentableStoreLens(
            UgglanStore.self,
            getter: { state in
                state
            }
        ) { state in
            if state.shouldShowNotificationCard {
                InfoCard(text: L10n.profileAllowNotificationsInfoLabel, type: .info)
                    .buttons([
                        .init(
                            buttonTitle: L10n.pushNotificationsAlertActionNotNow,
                            buttonAction: {
                                ugglanStore.send(.setPushNotificationsTo(date: Date()))
                            }
                        ),
                        .init(
                            buttonTitle: L10n.ReferralsAllowPushNotificationSheet.Allow.button,
                            buttonAction: {

                                _ = UIApplication.shared.appDelegate
                                    .registerForPushNotifications()
                            }
                        ),
                    ])
            }
        }
        .presentableStoreLensAnimation(.default)

    }
}

struct NotificationsCardView_Previews: PreviewProvider {
    static var previews: some View {
        NotificationsCardView()
    }
}
