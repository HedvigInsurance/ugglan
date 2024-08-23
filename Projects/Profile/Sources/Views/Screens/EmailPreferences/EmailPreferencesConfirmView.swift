import StoreContainer
import SwiftUI
import hCore
import hCoreUI

struct EmailPreferencesConfirmView: View {
    @ObservedObject var vm: MemberSubscriptionPreferenceViewModel
    @EnvironmentObject var profileNavigationVm: ProfileNavigationViewModel

    @hPresentableStore var store: ProfileStore
    var body: some View {
        GenericErrorView(
            title: vm.isUnsubscribed ? L10n.SettingsScreen.subscribeTitle : L10n.General.areYouSure,
            description: vm.isUnsubscribed
                ? L10n.SettingsScreen.subscribeDescription : L10n.SettingsScreen.unsubscribeDescription,
            buttons: .init(
                actionButtonAttachedToBottom:
                    .init(
                        buttonTitle: vm.isUnsubscribed
                            ? L10n.SettingsScreen.subscribeButton : L10n.SettingsScreen.confirmUnsubscribe,
                        buttonAction: {
                            Task {
                                await vm.toogleSubscription()
                                profileNavigationVm.isConfirmEmailPreferencesPresented = false
                            }
                        }
                    ),
                dismissButton: .init(
                    buttonTitle: L10n.generalCloseButton,
                    buttonAction: {
                        profileNavigationVm.isConfirmEmailPreferencesPresented = false
                    }
                )
            ),
            attachContentToTheBottom: true
        )
        .hExtraTopPadding
        .hDisableScroll
        .hButtonIsLoading(vm.isLoading)
    }
}

#Preview{
    EmailPreferencesConfirmView(vm: .init())
}
