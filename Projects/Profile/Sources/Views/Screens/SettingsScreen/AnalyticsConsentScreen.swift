import SwiftUI
import hCore
import hCoreUI

public struct AnalyticsConsentScreen: View {
    @AppStorage(AnalyticsConsent.hasConsentedKey) private var consentGiven: Bool?
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var buttonEnabled = true
    private let showsGraphic: Bool
    private let onConsentSelected: @MainActor (_ given: Bool) async -> Void
    private let privacyPolicyUrl = URL(string: "https://www.hedvig.com/se/personuppgifter")!

    public init(
        showsGraphic: Bool = false,
        onConsentSelected: @escaping @MainActor (_ given: Bool) async -> Void
    ) {
        self.showsGraphic = showsGraphic
        self.onConsentSelected = onConsentSelected
    }

    public var body: some View {
        hForm {
            if showsGraphic {
                hSection {
                    VStack(spacing: .padding16) {
                        graphic
                    }
                }
                .sectionContainerStyle(.transparent)
            }
        }
        .hFormContentPosition(.center)
        .hFormTitle(
            title: .init(.small, .body1, "Help us make the app better", alignment: .leading),
            subTitle: .init(
                .small,
                .body1,
                """
                We use technical tools to see how you use the app, so we can make it better.

                Product analytics is completely optional and can be turned off any time in settings. This data is never used for marketing.
                """,
                alignment: .leading
            )
        )
        .hFormAttachToBottom {
            hSection {
                VStack(spacing: .padding16) {
                    privacyPolicyLink
                    VStack(spacing: .padding8) {
                        hButton(.large, .secondary, content: .init(title: "Allow")) {
                            select(given: true)
                        }
                        hButton(.large, .secondary, content: .init(title: "Deny")) {
                            select(given: false)
                        }
                    }
                    .disabled(!buttonEnabled)
                }
            }
            .sectionContainerStyle(.transparent)
        }
    }

    private func select(given: Bool) {
        if given {
            AnalyticsConsent.give()
            UIAccessibility.post(notification: .announcement, argument: "Analytics allowed")  // TODO: L10n
        } else {
            AnalyticsConsent.revoke()
        }
        buttonEnabled = false
        Task {
            await onConsentSelected(given)
            buttonEnabled = true
        }
    }

    private var graphic: some View {
        ZStack(alignment: .topTrailing) {
            RoundedRectangle(cornerRadius: .padding24)
                .fill(hFillColor.Opaque.negative)
                .frame(width: 80, height: 80)
                .overlay {
                    hCoreUIAssets.eq.view
                        .resizable()
                        .frame(width: 52, height: 52)
                }
                .hShadow(type: .custom(opacity: 0.05, radius: 5, xOffset: 0, yOffset: 4), show: true)
                .hShadow(type: .custom(opacity: 0.1, radius: 1, xOffset: 0, yOffset: 2), show: true)
                .overlay(
                    RoundedRectangle(cornerRadius: .padding24)
                        .inset(by: 0.5)
                        .stroke(hBorderColor.secondary, lineWidth: 1)
                )

            Group {
                Image(uiImage: consentGiven == true ? hCoreUIAssets.checkmark.image : hCoreUIAssets.close.image)
                    .resizable()
                    .frame(width: 24, height: 24)
                    .foregroundColor(hTextColor.Opaque.negative)
                    .padding(.padding4)
                    .background {
                        if consentGiven == true {
                            Circle().fill(hSignalColor.Green.element)
                        } else {
                            Circle().fill(hSignalColor.Red.element)
                        }
                    }
                    .opacity(consentGiven != nil ? 1 : 0)
            }
            .scaleEffect(consentGiven != nil ? 1 : 0, anchor: .center)
            .animation(reduceMotion ? .none : .bouncy, value: consentGiven)
            .offset(x: 8, y: -8)
        }
        .accessibilityHidden(true)
    }

    private var privacyPolicyLink: some View {
        HStack(spacing: .padding4) {
            hText(L10n.legalPrivacyPolicy, style: .body1)
                .underline()
            hCoreUIAssets.arrowNorthEast.view
                .resizable()
                .frame(width: 18, height: 18)
                .accessibilityHidden(true)
        }
        .foregroundColor(hTextColor.Opaque.primary)
        .frame(minHeight: 44)
        .contentShape(Rectangle())
        .onTapGesture {
            UIApplication.shared.open(privacyPolicyUrl)
        }
        .accessibilityElement(children: .combine)
        .accessibilityAddTraits(.isButton)
        .accessibilityHint(L10n.onboardingOpensInBrowserHint)
    }
}

#Preview {
    AnalyticsConsentScreen { _ in }
}
