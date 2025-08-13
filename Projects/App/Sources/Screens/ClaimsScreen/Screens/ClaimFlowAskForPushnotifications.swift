import Claims
import PresentableStore
import Profile
import SwiftUI
import hCore
import hCoreUI

struct AskForPushNotifications: View {
    let onActionExecuted: () -> Void
    let text: String
    let wrapWithForm: Bool
    let height: CGFloat

    init(
        text: String,
        onActionExecuted: @escaping () -> Void,
        wrapWithForm: Bool = false,
        height: CGFloat? = nil
    ) {
        self.text = text
        self.onActionExecuted = onActionExecuted
        self.wrapWithForm = wrapWithForm
        self.height = height ?? 0
    }

    var body: some View {
        if wrapWithForm {
            hForm {
                mainContent
                    .frame(minHeight: height)
            }
            .hFormContentPosition(.compact)
        } else {
            mainContent
        }
    }

    var mainContent: some View {
        hSection {
            VStack(spacing: .padding16) {
                if !wrapWithForm {
                    Spacer()
                }
                hCoreUIAssets.infoFilled.view
                    .resizable()
                    .frame(width: 24, height: 24)
                    .foregroundColor(hSignalColor.Blue.element)
                    .accessibilityHidden(true)
                textContent
                buttonsView
            }
        }
        .sectionContainerStyle(.transparent)
        .background(
            BackgroundView().ignoresSafeArea()
        )
    }

    private var textContent: some View {
        VStack(spacing: 0) {
            hText(L10n.activateNotificationsTitle)
                .accessibilityAddTraits(.isHeader)
            hText(text)
                .multilineTextAlignment(.center)
                .padding(.horizontal, .padding32)
                .foregroundColor(hTextColor.Opaque.secondary)
        }
    }

    @ViewBuilder
    var buttonsView: some View {
        if wrapWithForm {
            VStack(spacing: .padding4) {
                activateNotificationsButton
                if !wrapWithForm {
                    Spacer()
                }
                closeButton
            }
        } else {
            activateNotificationsButton
            if !wrapWithForm {
                Spacer()
            }
            closeButton
        }
    }

    var activateNotificationsButton: some View {
        hButton(
            .medium,
            .primary,
            content: .init(title: L10n.claimsActivateNotificationsCta),
            {
                Task {
                    await UIApplication.shared.appDelegate.registerForPushNotifications()
                    onActionExecuted()
                }
            }
        )
    }

    var closeButton: some View {
        hButton(
            .large,
            .ghost,
            content: .init(title: L10n.claimsActivateNotificationsDismiss),
            {
                onActionExecuted()
                let store: ProfileStore = globalPresentableStoreContainer.get()
                store.send(.setPushNotificationStatus(status: nil))
            }
        )
    }
}

struct AskForPushnotifications_Previews: PreviewProvider {
    static var previews: some View {
        AskForPushNotifications(text: "TEXT") {}
    }
}
