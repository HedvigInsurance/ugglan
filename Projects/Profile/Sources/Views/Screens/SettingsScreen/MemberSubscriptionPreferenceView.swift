import PresentableStore
import SwiftUI
import hCore
import hCoreUI

struct MemberSubscriptionPreferenceView: View {
    @ObservedObject var vm: MemberSubscriptionPreferenceViewModel
    @EnvironmentObject var profileNavigationVm: ProfileNavigationViewModel

    @InjectObservableObject var featureFlags: FeatureFlags
    @ViewBuilder
    var body: some View {
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
                        .environmentObject(profileNavigationVm)
                        .embededInNavigation(tracking: ProfileDetentType.emailPreferences)
                }
            )
        }
    }
}

@MainActor
class MemberSubscriptionPreferenceViewModel: ObservableObject {
    @Published var memberId: String = ""
    @Published var isLoading = false
    @Published var isUnsubscribed = false
    static let userDefaultsKey = "unsubscribedMembers"
    @Published var unsubscribedMembers = UserDefaults.standard.array(forKey: userDefaultsKey) as? [String]
    var profileService = ProfileService()
    var profileNavigationViewModel: ProfileNavigationViewModel?
    init() {}

    func setMemberId() {
        let store: ProfileStore = globalPresentableStoreContainer.get()
        memberId = store.state.memberDetails?.id ?? ""
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

        let store: ProfileStore = globalPresentableStoreContainer.get()
        let memberId = store.state.memberDetails?.id ?? ""
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

private struct UnsubscribedMembers {}
