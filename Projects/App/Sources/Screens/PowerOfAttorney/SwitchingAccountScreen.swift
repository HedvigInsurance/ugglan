import SwiftUI
import hCore
import hCoreUI

/// Shown while the member goes back from a power of attorney session to their own.
struct SwitchingAccountScreen: View {
    // TODO: Localize via Lokalise
    private let message = "Switching back to your account"

    var body: some View {
        ZStack {
            // Same video as the logged out screen
            LoginVideoView()
                .ignoresSafeArea()
                .accessibilityHidden(true)
            hSection {
                VStack {
                    Spacer()
                    hText(message)
                        .foregroundColor(hTextColor.Opaque.primary)
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: .infinity)
                }
                .environment(\.colorScheme, .light)
            }
            .sectionContainerStyle(.transparent)
        }
        .onAppear {
            // Replaces the whole root in place behind an opacity transition, so the outgoing content is still in the
            // accessibility tree here. Passing the message makes VoiceOver read it instead of whatever it focuses first.
            UIAccessibility.post(notification: .screenChanged, argument: message)
        }
        .trackViewName(name: .init(describing: SwitchingAccountScreen.self))
    }
}

#Preview {
    SwitchingAccountScreen()
}
