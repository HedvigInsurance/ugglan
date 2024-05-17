import Presentation
import SwiftUI
import hCore
import hCoreUI

struct MemberSubscriptionPreferenceView: View {
    @StateObject private var vm = MemberSubscriptionPreferenceViewModel()
    var body: some View {
        hFloatingField(
            value: vm.unsubscribedMembers?.first(where: { $0 == vm.memberId }) == nil ? "Subscribed" : "Unsubscribed",
            placeholder: "Recieve offers over email",
            onTap: {
                Task {
                    await vm.toogleSubscription()
                }
            }
        )
        .disabled(vm.isLoading)
    }
}

private class MemberSubscriptionPreferenceViewModel: ObservableObject {
    let memberId: String
    @Published var isLoading = false
    private static let userDefaultsKey = "unsubscribedMembers"
    @Published var unsubscribedMembers = UserDefaults.standard.array(forKey: userDefaultsKey) as? [String]
    @Inject var profileService: ProfileService
    init() {
        let store: ProfileStore = globalPresentableStoreContainer.get()
        memberId = store.state.memberDetails?.id ?? ""
    }

    @MainActor
    func toogleSubscription() async {
        withAnimation {
            isLoading = true
        }
        let isUnsubscribed: Bool? = unsubscribedMembers?.contains(memberId)
        do {
            try await profileService.updateSubscriptionPreference(to: isUnsubscribed ?? false)
            let toast = Toast(
                symbol: .icon(
                    hCoreUIAssets
                        .circularCheckmark
                        .image
                ),
                body: (isUnsubscribed ?? false)
                    ? "Subscribed to recieve offers over email" : "Unsubscribed from recieve offers over email"
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
                    } else {
                        var unsubscribedMembers = self.unsubscribedMembers
                        unsubscribedMembers?.append(memberId)
                        UserDefaults.standard.set(
                            unsubscribedMembers,
                            forKey: MemberSubscriptionPreferenceViewModel.userDefaultsKey
                        )
                        self.unsubscribedMembers = unsubscribedMembers
                    }
                } else {
                    let unsubscribedMembers = [memberId]
                    UserDefaults.standard.set(
                        unsubscribedMembers,
                        forKey: MemberSubscriptionPreferenceViewModel.userDefaultsKey
                    )
                    self.unsubscribedMembers = unsubscribedMembers
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
