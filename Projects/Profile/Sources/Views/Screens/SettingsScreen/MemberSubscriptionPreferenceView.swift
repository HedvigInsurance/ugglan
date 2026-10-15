import AppStateContainer
import SwiftUI
import hCore
import hCoreUI

struct MemberSubscriptionPreferenceView: View {
    let vm: MemberSubscriptionPreferenceViewModel
    @Environment(ProfileNavigationViewModel.self) var profileNavigationVm

    @InjectObservableObject var featureFlags: FeatureFlags
    @ViewBuilder
    var body: some View {
        @Bindable var profileNavigationVm = profileNavigationVm
        if featureFlags.emailPreferencesEnabled {
            hFloatingField(
                value: vm.isUnsubscribed ? L10n.General.unsubscribed : L10n.General.subscribed,
                placeholder: L10n.SettingsScreen.emailPreferences,
                onTap: {
                    vm.onEmailPreferencesButtonTap()
                }
            )
            .disabled(vm.isLoading)
            .task { [weak vm] in
                vm?.setMemberId()
                vm?.profileNavigationViewModel = profileNavigationVm
            }
            .detent(
                presented: $profileNavigationVm.isConfirmEmailPreferencesPresented,

                content: {
                    EmailPreferencesConfirmView(vm: vm)
                        .environment(profileNavigationVm)
                        .embededInNavigation(tracking: ProfileDetentType.emailPreferences)
                }
            )
        }
    }
}

@MainActor
@Observable
class MemberSubscriptionPreferenceViewModel {
    var memberId: String = ""
    var isLoading = false
    var isUnsubscribed = false
    static let userDefaultsKey = "unsubscribedMembers"
    var unsubscribedMembers = UserDefaults.standard.array(forKey: userDefaultsKey) as? [String]
    @ObservationIgnored var profileService = ProfileService()
    @ObservationIgnored var profileNavigationViewModel: ProfileNavigationViewModel?
    let store: ProfileStore = globalAppStateContainer.get()
    init() {}

    func setMemberId() {
        memberId = store.memberDetails?.id ?? ""
        updateUnsubscibed()
    }

    func onEmailPreferencesButtonTap() {
        profileNavigationViewModel?.isConfirmEmailPreferencesPresented = true
    }

    func updateUnsubscibed() {
        isUnsubscribed = unsubscribedMembers?.first(where: { $0 == memberId }) != nil
    }

    @MainActor
    func toggleSubscription() async {
        withAnimation {
            isLoading = true
        }

        let store: ProfileStore = globalAppStateContainer.get()
        let memberId = store.memberDetails?.id ?? ""
        do {
            try await profileService.updateSubscriptionPreference(to: isUnsubscribed)
            let toast = ToastBar(
                type: .campaign,
                icon: hCoreUIAssets.checkmarkOutlined.view,
                text: isUnsubscribed ? L10n.SettingsScreen.subscribedMessage : L10n.SettingsScreen.unsubscribedMessage
            )
            Toasts.shared.displayToastBar(toast: toast)

            withAnimation {
                if let unsubscribedMembers = unsubscribedMembers {
                    if let index = unsubscribedMembers.firstIndex(of: memberId) {
                        var unsubscribedMembers = self.unsubscribedMembers
                        unsubscribedMembers?.remove(at: index)
                        UserDefaults.standard.set(
                            unsubscribedMembers,
                            forKey: MemberSubscriptionPreferenceViewModel.userDefaultsKey
                        )
                        self.unsubscribedMembers = unsubscribedMembers
                        updateUnsubscibed()
                    } else {
                        var unsubscribedMembers = self.unsubscribedMembers
                        unsubscribedMembers?.append(memberId)
                        UserDefaults.standard.set(
                            unsubscribedMembers,
                            forKey: MemberSubscriptionPreferenceViewModel.userDefaultsKey
                        )
                        self.unsubscribedMembers = unsubscribedMembers
                        updateUnsubscibed()
                    }
                } else {
                    let unsubscribedMembers = [memberId]
                    UserDefaults.standard.set(
                        unsubscribedMembers,
                        forKey: MemberSubscriptionPreferenceViewModel.userDefaultsKey
                    )
                    self.unsubscribedMembers = unsubscribedMembers
                    updateUnsubscibed()
                }
            }
        } catch _ {
            // TODO: Add error handling
        }

        withAnimation {
            isLoading = false
        }
    }
}
