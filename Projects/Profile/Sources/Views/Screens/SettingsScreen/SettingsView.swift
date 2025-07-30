import Apollo
import Contracts
import PresentableStore
import SwiftUI
import hCore
import hCoreUI

struct SettingsView: View {
    @PresentableStore var store: ProfileStore
    @StateObject var memberSubscriptionPreferenceVm = MemberSubscriptionPreferenceViewModel()
    @EnvironmentObject var profileNavigationVm: ProfileNavigationViewModel

    init() {
        store.send(.fetchMemberDetails)
    }

    var body: some View {
        hForm {
            hSection {
                VStack(spacing: .padding4) {
                    hFloatingField(
                        value: Localization.Locale.currentLocale.value.displayName,
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
                                    DispatchQueue.main.async { Dependencies.urlOpener.open(settingsUrl) }
                                } else {
                                    NotificationCenter.default.post(name: .registerForPushNotifications, object: nil)

                                }
                            }
                        )
                    }
                    MemberSubscriptionPreferenceView(vm: memberSubscriptionPreferenceVm)
                        .environmentObject(profileNavigationVm)
                }
                .accessibilityAddTraits(.isButton)
                NotificationsCardView()
                    .padding(.vertical, .padding16)

            }
            .padding(.top, .padding8)
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
                            hasTravelCertificate: false,
                            isContactInfoUpdateNeeded: false
                        )
                }
            ) { memberDetails in
                hSection {
                    hButton(
                        .large,
                        .ghost,
                        content: .init(
                            title: L10n.SettingsScreen.deleteAccountButton
                        ),
                        {
                            if ApplicationState.currentState?.isOneOf([.loggedIn]) == true {
                                let hasAlreadyRequested = ApolloClient.deleteAccountStatus(for: memberDetails.id)
                                if hasAlreadyRequested {
                                    profileNavigationVm.isDeleteAccountAlreadyRequestedPresented = true
                                } else {
                                    profileNavigationVm.isDeleteAccountPresented = memberDetails
                                }
                            }
                        }
                    )
                    .hUseButtonTextColor(.red)
                }
                .sectionContainerStyle(.transparent)
            }
        }
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
