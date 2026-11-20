import SwiftUI
import hCore
import hCoreUI

struct GreetingView: View {
    @Environment(\.actingPowerOfAttorney) private var actingPowerOfAttorney
    let firstName: String?

    var body: some View {
        VStack(spacing: .padding16) {
            greeting
            if actingPowerOfAttorney != nil {
                SwitchBackToOwnAccountButton()
            }
        }
        .padding(.horizontal, .padding16)
        .padding(.vertical, 140)
    }

    private var greeting: some View {
        VStack(spacing: 0) {
            if let actingPowerOfAttorney {
                hText(L10n.homeGreetingTitle(actingPowerOfAttorney.firstName), style: .heading2)
                    .foregroundColor(hTextColor.Opaque.primary)
                hText(powerOfAttorneySubtitle(for: actingPowerOfAttorney), style: .heading2)
                    .foregroundColor(hTextColor.Translucent.secondary)
            } else if let firstName, !firstName.isEmpty {
                hText(L10n.homeGreetingTitle(firstName), style: .heading2)
                    .foregroundColor(hTextColor.Opaque.primary)
                hText(L10n.homeGreetingSubtitle, style: .heading2)
                    .foregroundColor(hTextColor.Translucent.secondary)
            } else {
                hText(L10n.HomeTab.welcomeTitleWithoutName, style: .heading2)
                    .foregroundColor(hTextColor.Opaque.primary)
            }
        }
        .multilineTextAlignment(.center)
        .fixedSize(horizontal: false, vertical: true)
        .frame(maxWidth: .infinity)
        .accessibilityElement(children: .combine)
        .accessibilityAddTraits(.isHeader)
    }

    // TODO: Localize via Lokalise
    private func powerOfAttorneySubtitle(for powerOfAttorney: ActingPowerOfAttorney) -> String {
        if let firstName {
            return "You're acting on behalf of \(firstName)"
        }
        return ""
    }
}

/// Lets a member who switched to a power of attorney from their own session return to it. A View of its own so its
/// closures only capture this view (see `LogoutButton`).
private struct SwitchBackToOwnAccountButton: View {
    @Environment(\.switchBackToOwnAccount) private var switchBackToOwnAccount
    @State private var showAlert = false

    var body: some View {
        if let switchBackToOwnAccount {
            // TODO: Localize via Lokalise
            hButton(.medium, .secondary, content: .init(title: "Switch back to my account")) {
                showAlert = true
            }
            .fixedSize(horizontal: false, vertical: true)
            // TODO: Localize via Lokalise
            .alert("Switch back to your account?", isPresented: $showAlert) {
                Button(L10n.generalCancelButton, role: .cancel) {}
                // TODO: Localize via Lokalise
                Button("Switch back") {
                    switchBackToOwnAccount()
                }
            } message: {
                // TODO: Localize via Lokalise
                Text("You will stop acting with the power of attorney.")
            }
        }
    }
}

#Preview {
    GreetingView(firstName: "Hedvig")
}
