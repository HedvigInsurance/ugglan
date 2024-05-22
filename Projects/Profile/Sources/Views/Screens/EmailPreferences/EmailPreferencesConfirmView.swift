import Presentation
import SwiftUI
import hCore
import hCoreUI

struct EmailPreferencesConfirmView: View {
    @ObservedObject var vm: MemberSubscriptionPreferenceViewModel
    @PresentableStore var store: ProfileStore
    var body: some View {
        GenericErrorView(
            title: L10n.General.areYouSure,
            description: L10n.SettingsScreen.unsubscribeDescription,
            icon: .triangle,
            buttons: .init(
                actionButtonAttachedToBottom:
                    .init(
                        buttonTitle: L10n.SettingsScreen.confirmUnsubscribe,
                        buttonAction: {
                            Task {
                                await vm.toogleSubscription()
                                store.send(.dismissConfirmEmailPreferences)
                            }
                        }
                    ),
                dismissButton: .init(
                    buttonTitle: L10n.generalCloseButton,
                    buttonAction: {
                        store.send(.dismissConfirmEmailPreferences)
                    }
                )
            )
        )
        .hWithLargeIcon
        .hExtraTopPadding
        .hDisableScroll
        .hButtonIsLoading(vm.isLoading)
    }
}

#Preview{
    EmailPreferencesConfirmView(vm: .init())
}

extension EmailPreferencesConfirmView {
    public static var journey: some JourneyPresentation {
        let store: ProfileStore = globalPresentableStoreContainer.get()
        return HostingJourney(
            ProfileStore.self,
            rootView: EmailPreferencesConfirmView(vm: store.memberSubscriptionPreferenceViewModel),
            style: .detented(.scrollViewContentSize)
        ) { action in
            if case .dismissConfirmEmailPreferences = action {
                PopJourney()
            }
        }
        .configureTitle(L10n.SettingsScreen.emailPreferences)
    }
}
