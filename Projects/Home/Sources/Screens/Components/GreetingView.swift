import SwiftUI
import hCore
import hCoreUI

struct GreetingView: View {
    let firstName: String?

    var body: some View {
        greeting
            .padding(.horizontal, .padding16)
            .padding(.vertical, 140)
    }

    private var greeting: some View {
        VStack(spacing: 0) {
            if let firstName, !firstName.isEmpty {
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
}

#Preview {
    GreetingView(firstName: "Hedvig")
}
