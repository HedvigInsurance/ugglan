import Presentation
import SwiftUI
import hCore
import hCoreUI

struct EmailPreferencesConfirmView: View {
    @ObservedObject var vm: MemberSubscriptionPreferenceViewModel
    @EnvironmentObject var profileNavigationVm: ProfileNavigationViewModel

    @PresentableStore var store: ProfileStore
    var body: some View {
        GenericErrorView(
            title: L10n.General.areYouSure,
            description: vm.isUnsubscribed
                ? L10n.SettingsScreen.subscribeDescription : L10n.SettingsScreen.unsubscribeDescription,
            icon: .triangle,
            buttons: .init(
                actionButtonAttachedToBottom:
                    .init(
                        buttonTitle: vm.isUnsubscribed ? L10n.General.yes : L10n.SettingsScreen.confirmUnsubscribe,
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
        .hUseNewDesign
    }
}

#Preview{
    EmailPreferencesConfirmView(vm: .init())
}