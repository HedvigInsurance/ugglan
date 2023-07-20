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

    init() {
        store.send(.fetchMemberDetails)
    }

    var body: some View {
        hForm {
            hSection {
                hFloatingField(
                    value: Localization.Locale.currentLocale.displayName,
                    placeholder: L10n.settingsLanguageTitle,
                    onTap: {
                        // todo: add action to display language picker
                    }
                )
            }
            .padding(.top, 16)

            PresentableStoreLens(
                UgglanStore.self,
                getter: { state in
                    state
                }
            ) { _ in
                hSection {
                    hFloatingField(
                        value: store.state.pushNotificationCurrentStatus() == .authorized
                            ? L10n.profileNotificationsStatusOn : L10n.profileNotificationsStatusOff,
                        placeholder: L10n.pushNotificationsAlertTitle,
                        onTap: {
                            // todo: add action to allow notifications
                        }
                    )
                }
                NotificationsCardView()
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
}

struct SettingsScreen_Previews: PreviewProvider {
    static var previews: some View {
        SettingsScreen()
    }
}
