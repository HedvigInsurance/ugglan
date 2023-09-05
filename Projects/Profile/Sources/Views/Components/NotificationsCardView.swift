import Presentation
import SwiftUI
import hCore
import hCoreUI

struct NotificationsCardView: View {
    @PresentableStore var store: ProfileStore
    var body: some View {
        PresentableStoreLens(
            ProfileStore.self,
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
                                /* TODO: SEND TO UGGLAN */
//                                shouldShowNotificationCard.send(.setPushNotificationsTo(date: Date()))
                            }
                        ),
                        .init(
                            buttonTitle: L10n.ReferralsAllowPushNotificationSheet.Allow.button,
                            buttonAction: {

//                                _ = UIApplication.shared.appDelegate
//                                    .registerForPushNotifications()
                                /* todo: change */
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
