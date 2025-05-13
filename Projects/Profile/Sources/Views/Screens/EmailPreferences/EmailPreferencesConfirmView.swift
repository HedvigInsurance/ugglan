import PresentableStore
import SwiftUI
import hCore
import hCoreUI

struct EmailPreferencesConfirmView: View {
    @ObservedObject var vm: MemberSubscriptionPreferenceViewModel
    @EnvironmentObject var profileNavigationVm: ProfileNavigationViewModel

    @PresentableStore var store: ProfileStore
    var body: some View {
        GenericErrorView(
            title: vm.isUnsubscribed ? L10n.SettingsScreen.subscribeTitle : L10n.General.areYouSure,
            description: vm.isUnsubscribed
                ? L10n.SettingsScreen.subscribeDescription : L10n.SettingsScreen.unsubscribeDescription,
            formPosition: .compact,
            attachContentToBottom: true
        )
        .hStateViewButtonConfig(
            .init(
                actionButtonAttachedToBottom:
                    .init(
                        buttonTitle: vm.isUnsubscribed
                            ? L10n.SettingsScreen.subscribeButton : L10n.SettingsScreen.confirmUnsubscribe,
                        buttonAction: {
                            Task {
                                await vm.toggleSubscription()
                                profileNavigationVm.isConfirmEmailPreferencesPresented = false
                            }
                        }
                    ),
                dismissButton: .init(
                    buttonAction: {
                        profileNavigationVm.isConfirmEmailPreferencesPresented = false
                    }
                )
            )
        )
        .hButtonIsLoading(vm.isLoading)
    }
}

#Preview {
    EmailPreferencesConfirmView(vm: .init())
}
