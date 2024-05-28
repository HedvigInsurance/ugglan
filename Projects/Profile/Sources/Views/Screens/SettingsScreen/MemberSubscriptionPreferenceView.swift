import Presentation
import SwiftUI
import hCore
import hCoreUI

struct MemberSubscriptionPreferenceView: View {
    @ObservedObject var vm: MemberSubscriptionPreferenceViewModel
    var body: some View {
        hFloatingField(
            value: vm.isUnsubscribed ? L10n.General.unsubscribed : L10n.General.subscribed,
            placeholder: L10n.SettingsScreen.emailPreferences,
            onTap: {
                vm.onEmailPreferencesButtonTap()
            }
        )
        .disabled(vm.isLoading)
        .task {
            vm.setMemberId()
        }
    }
}

class MemberSubscriptionPreferenceViewModel: ObservableObject {
    @Published var memberId: String = ""
    @Published var isLoading = false
    @Published var isUnsubscribed = false
    private static let userDefaultsKey = "unsubscribedMembers"
    @Published var unsubscribedMembers = UserDefaults.standard.array(forKey: userDefaultsKey) as? [String]
    @Inject var profileService: ProfileService

    init() {}

    func setMemberId() {
        let store: ProfileStore = globalPresentableStoreContainer.get()
        memberId = store.state.memberDetails?.id ?? ""
        updateUnsubscibed()

    }

    func onEmailPreferencesButtonTap() {
        let store: ProfileStore = globalPresentableStoreContainer.get()
        store.send(.showConfirmEmailPreferences)
    }

    func updateUnsubscibed() {
        isUnsubscribed = unsubscribedMembers?.first(where: { $0 == memberId }) != nil
    }

    @MainActor
    func toogleSubscription() async {
        withAnimation {
            isLoading = true
        }

        let store: ProfileStore = globalPresentableStoreContainer.get()
        let memberId = store.state.memberDetails?.id ?? ""
        do {
            try await profileService.updateSubscriptionPreference(to: isUnsubscribed)
            let toast = Toast(
                symbol: .icon(
                    hCoreUIAssets
                        .circularCheckmark
                        .image
                ),
                body: (isUnsubscribed)
                    ? L10n.SettingsScreen.subscribedMessage : L10n.SettingsScreen.unsubscribedMessage
            )
            Toasts.shared.displayToast(toast: toast)
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

        } catch let ex {
            let ss = ""
        }

        withAnimation {
            isLoading = false
        }

    }
}

private struct UnsubscribedMembers {

}
