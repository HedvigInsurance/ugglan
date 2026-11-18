import SwiftUI
import hCore
import hCoreUI

struct GreetingView: View {
    @Environment(\.homeActingPowerOfAttorney) private var actingPowerOfAttorney
    let firstName: String?

    var body: some View {
        greeting
            .padding(.horizontal, .padding16)
            .padding(.vertical, 140)
    }

    private var greeting: some View {
        VStack(spacing: 0) {
            if let actingPowerOfAttorney {
                hText(L10n.homeGreetingTitle(actingPowerOfAttorney.name), style: .heading2)
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
    private func powerOfAttorneySubtitle(for powerOfAttorney: HomeActingPowerOfAttorney) -> String {
        let level = powerOfAttorney.hasFullAccess ? "full" : "partial"
        guard let firstName, !firstName.isEmpty else {
            return "You are acting with \(level) power of attorney"
        }
        return "You are acting with \(level) power of attorney for \(firstName)"
    }
}

/// The person using the app with a power of attorney, greeted on home instead of the member.
public struct HomeActingPowerOfAttorney: Equatable, Sendable {
    public let name: String
    public let hasFullAccess: Bool

    public init(name: String, hasFullAccess: Bool) {
        self.name = name
        self.hasFullAccess = hasFullAccess
    }
}

extension EnvironmentValues {
    @Entry public var homeActingPowerOfAttorney: HomeActingPowerOfAttorney? = nil
}

#Preview {
    GreetingView(firstName: "Hedvig")
}
