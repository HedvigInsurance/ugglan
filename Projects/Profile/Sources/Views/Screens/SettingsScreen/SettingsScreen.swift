import Apollo
import Contracts
import SwiftUI
import hCore
import hCoreUI
import hGraphQL

struct SettingsScreen: View {
    @PresentableStore var store: ProfileStore
    @EnvironmentObject var profileNavigationVm: ProfileNavigationViewModel

    init() {
        store.send(.fetchMemberDetails)
    }

    var body: some View {
        hForm {
            hSection {
                VStack(spacing: 4) {
                    hFloatingField(
                        value: Localization.Locale.currentLocale.displayName,
                        placeholder: L10n.settingsLanguageTitle,
                        onTap: {
                            profileNavigationVm.isLanguagePickerPresented = true
                        }
                    )
                    PresentableStoreLens(
                        ProfileStore.self,
                        getter: { state in
                            state
                        }
                    ) { _ in
                        hFloatingField(
                            value: store.state.pushNotificationCurrentStatus() == .authorized
                                ? L10n.profileNotificationsStatusOn : L10n.profileNotificationsStatusOff,
                            placeholder: L10n.pushNotificationsAlertTitle,
                            onTap: {
                                if store.state.pushNotificationCurrentStatus() == .authorized {
                                    guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else {
                                        return
                                    }
                                    DispatchQueue.main.async { UIApplication.shared.open(settingsUrl) }
                                } else {
                                    store.send(.registerForPushNotifications)
                                }
                            }
                        )
                    }
                }
                NotificationsCardView()
                    .padding(.vertical, 16)

            }
            .padding(.top, 8)
        }
        .sectionContainerStyle(.transparent)
        .hFormAttachToBottom {
            PresentableStoreLens(
                ProfileStore.self,
                getter: { state in
                    state.memberDetails
                        ?? MemberDetails(
                            id: "",
                            firstName: "",
                            lastName: "",
                            phone: "",
                            email: "",
                            hasTravelCertificate: false
                        )
                }
            ) { memberDetails in
                hButton.LargeButton(type: .ghost) {
                    if ApplicationState.currentState?.isOneOf([.loggedIn]) == true {
                        let hasAlreadyRequested = ApolloClient.deleteAccountStatus(for: memberDetails.id)
                        if hasAlreadyRequested {
                            profileNavigationVm.isDeleteAccountAlreadyRequestedPresented = true
                        } else {
                            profileNavigationVm.isDeleteAccountPresented = memberDetails
                        }
                    }
                } content: {
                    hText(L10n.SettingsScreen.deleteAccountButton)
                        .foregroundColor(hSignalColor.redElement)
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
