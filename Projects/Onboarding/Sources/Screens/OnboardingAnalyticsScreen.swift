import SwiftUI
import hCore
import hCoreUI

struct OnboardingAnalyticsScreen: View {
    @EnvironmentObject var vm: OnboardingNavigationViewModel

    private let privacyPolicyUrl = URL(string: "https://www.hedvig.com/se/personuppgifter")!

    var body: some View {
        hForm {
            hSection {
                VStack(spacing: .padding16) {
                    graphic
                }
            }
            .sectionContainerStyle(.transparent)
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
                        hButton(.large, .secondary, content: .init(title: "Allow")) {  // TODO: L10n
                            AnalyticsConsent.give()
                            let eventTrackingClient: EventTrackingClient = Dependencies.shared.resolve()
                            eventTrackingClient.setCollectionEnabled(true)
                            vm.advance(after: .analyticsConsent)
                        }
                        hButton(.large, .secondary, content: .init(title: "Deny")) {  // TODO: L10n
                            let eventTrackingClient: EventTrackingClient = Dependencies.shared.resolve()
                            eventTrackingClient.setCollectionEnabled(false)
                            vm.advance(after: .analyticsConsent)
                        }
                    }
                }
            }
            .sectionContainerStyle(.transparent)
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
            hCoreUIAssets.checkmarkFilledSmall.view
                .resizable()
                .frame(width: 40, height: 40)
                .foregroundColor(hSignalColor.Green.element)
                .offset(x: 12, y: -12)
        }
        .accessibilityHidden(true)
    }

    private var privacyPolicyLink: some View {
        HStack(spacing: .padding4) {
            hText("Privacy policy", style: .body1)  // TODO: L10n
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
        .accessibilityHint("Opens in your browser")  // TODO: L10n
    }
}

#Preview {
    OnboardingAnalyticsScreen()
        .environmentObject(OnboardingNavigationViewModel())
}
