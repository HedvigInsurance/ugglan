import Apollo
import Contracts
import Flow
import Form
import Presentation
import SwiftUI
import UIKit
import hCore
import hCoreUI
import hGraphQL

struct SettingsScreen: View {
    @PresentableStore var store: UgglanStore
    @Inject var giraffe: hGiraffe
    @StateObject var vm = VCViewModel()
    let onActionExecuted: (UIViewController?) -> Void
    @StateObject private var infoModel = DismissInfoModel()

    init(
        onActionExecuted: @escaping (UIViewController?) -> Void
    ) {
        self.onActionExecuted = onActionExecuted
        store.send(.fetchMemberDetails)
    }

    var body: some View {
        hForm {
            VStack(spacing: 4) {

                hSection {
                    hFloatingField(
                        value: Localization.Locale.currentLocale.displayName,
                        placeholder: L10n.settingsLanguageTitle,
                        onTap: {
                            // todo: add action to display language picker
                        }
                    )
                }

                hSection {
                    hFloatingField(
                        value: infoModel.getNotificationStatus
                            ? L10n.profileNotificationsStatusOn : L10n.profileNotificationsStatusOff,
                        placeholder: L10n.pushNotificationsAlertTitle,
                        onTap: {}
                    )
                }

                if !infoModel.getNotificationStatus && !infoModel.hasDismissedNotificationInfo {
                    InfoCard(
                        text: L10n.profileAllowNotificationsInfoLabel,
                        type: .info,
                        buttonView: displayButtons
                    )
                    .padding(.top, 12)
                }
            }
            .padding(.top, 16)
        }
        .hFormAttachToBottom {

            PresentableStoreLens(
                UgglanStore.self,
                getter: { state in
                    state.memberDetails
                        ?? MemberDetails(id: "", firstName: "", lastName: "", phone: "", email: "")
                }
            ) { memberDetails in
                hButton.LargeButtonGhost {
                    if ApplicationState.currentState?.isOneOf([.loggedIn]) == true {
                        let hasAlreadyRequested = ApolloClient.deleteAccountStatus(for: memberDetails.id)
                        if hasAlreadyRequested {
                            store.send(.deleteAccountAlreadyRequested)
                        } else {
                            store.send(.deleteAccount(details: memberDetails))
                        }
                    }
                } content: {
                    hText(L10n.SettingsScreen.deleteAccountButton)
                        .foregroundColor(hSignalColorNew.redElement)
                }
            }
            .padding(16)
        }
    }

    var displayButtons: some View {
        HStack(spacing: 8) {
            hButton.SmallSecondaryAlt {
                infoModel.changeDismissActiveValue(true)
            } content: {
                hText(L10n.pushNotificationsAlertActionNotNow)
            }

            hButton.SmallSecondaryAlt {
                let current = UNUserNotificationCenter.current()
                current.getNotificationSettings(completionHandler: { settings in
                    DispatchQueue.main.async {
                        UIApplication.shared.appDelegate
                            .registerForPushNotifications()
                            .onValue { status in
                                onActionExecuted(vm.vc)
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                    infoModel.updateNotificationStatus
                                }
                            }
                    }
                })
            } content: {
                hText(L10n.ReferralsAllowPushNotificationSheet.Allow.button)
            }
        }
    }
}

struct SettingsScreen_Previews: PreviewProvider {
    static var previews: some View {
        SettingsScreen(onActionExecuted: { _ in })
    }
}

class DismissInfoModel: ObservableObject {
    var hasDismissedNotificationInfo = false
    var notificationsActivated = false

    func changeDismissActiveValue(_ newValue: Bool) {
        hasDismissedNotificationInfo = newValue
        self.objectWillChange.send()
    }

    var updateNotificationStatus: Void {
        let ugglanStore: UgglanStore = globalPresentableStoreContainer.get()
        let notificationStatus = ugglanStore.state.pushNotificationCurrentStatus()
        notificationsActivated = (notificationStatus == .authorized)
        self.objectWillChange.send()
    }

    var getNotificationStatus: Bool {
        let ugglanStore: UgglanStore = globalPresentableStoreContainer.get()
        let notificationStatus = ugglanStore.state.pushNotificationCurrentStatus()
        notificationsActivated = (notificationStatus == .authorized)
        return notificationsActivated
    }

}
