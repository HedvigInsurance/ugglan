import SwiftUI
import hCore
import hCoreUI

struct GreetingView: View {
    let firstName: String?

    var body: some View {
        VStack(spacing: 0) {
            if let firstName, !firstName.isEmpty {
                // TODO: localise
                hText("Hi \(firstName)", style: .heading2)
                    .foregroundColor(hTextColor.Opaque.primary)
                hText("How can we help?", style: .heading2)
                    .foregroundColor(hTextColor.Translucent.secondary)
            } else {
                hText(L10n.HomeTab.welcomeTitleWithoutName, style: .heading2)
                    .foregroundColor(hTextColor.Opaque.primary)
            }
        }
        .multilineTextAlignment(.center)
        .fixedSize(horizontal: false, vertical: true)
        .frame(maxWidth: .infinity)
        .padding(.horizontal, .padding16)
        .padding(.vertical, 140)
    }
}

#Preview {
    GreetingView(firstName: "Hedvig")
}
