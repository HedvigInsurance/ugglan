import SwiftUI
import hCore
import hCoreUI

/// Shown while the session is swapped for another one: switching to a power of attorney, or back from one to the
/// member's own account.
struct SwitchingAccountScreen: View {
    let switchingTo: Destination

    enum Destination {
        case powerOfAttorney
        case ownAccount

        var message: String {
            switch self {
            // TODO: Localize via Lokalise
            case .powerOfAttorney: "Switching"
            // TODO: Localize via Lokalise
            case .ownAccount: "Switching"
            }
        }
    }

    var body: some View {
        ZStack {
            // Same video as the logged out screen
            LoginVideoView()
                .ignoresSafeArea()
                .accessibilityHidden(true)
            hSection {
                VStack(spacing: .padding24) {
                    Spacer()
                    hCoreUIAssets.bigPillowBlack.view
                        .resizable()
                        .frame(width: 128, height: 128)
                        .accessibilityHidden(true)
                    hText(switchingTo.message)
                        .foregroundColor(hTextColor.Opaque.primary)
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: .infinity)
                    Spacer()
                }
                .environment(\.colorScheme, .light)
            }
            .sectionContainerStyle(.transparent)
        }
        .onAppear {
            // Replaces the whole root in place behind an opacity transition, so the outgoing content is still in the
            // accessibility tree here. Passing the message makes VoiceOver read it instead of whatever it focuses first.
            UIAccessibility.post(notification: .screenChanged, argument: switchingTo.message)
        }
        .trackViewName(name: .init(describing: SwitchingAccountScreen.self))
    }
}

#Preview {
    SwitchingAccountScreen(switchingTo: .powerOfAttorney)
}
