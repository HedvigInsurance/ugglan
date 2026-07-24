import Environment
import SwiftUI
import hCore
import hCoreUI

struct OnboardingInviteScreen: View {
    let discountCode: String
    let monthlyDiscountPerReferral: String
    @EnvironmentObject var vm: OnboardingNavigationViewModel
    @State private var modalPresentationSourceWrapperViewModel = ModalPresentationSourceWrapperViewModel()
    @State private var namesToDisplay: [String] = []
    private var subtitle: String {
        if !monthlyDiscountPerReferral.isEmpty {
            // TODO: L10n
            return "With Hedvig Forever, you get \(monthlyDiscountPerReferral) off for every friend you invite."
        }
        return "With Hedvig Forever, you get a discount off for every friend you invite."  // TODO: L10n
    }

    var body: some View {
        hForm {
            centerContent
        }
        .hFormTitle(
            title: .init(.small, .body1, "Invite a friend", alignment: .leading),
            subTitle: .init(
                .small,
                .body1,
                subtitle,
                alignment: .leading
            )
        )
        .hFormContentPosition(.center)
        .hFormAttachToBottom {
            hSection {
                VStack(spacing: .padding8) {
                    if !discountCode.isEmpty {
                        ModalPresentationSourceWrapper(
                            content: {
                                hButton(
                                    .large,
                                    .secondary,
                                    content: .init(title: "Invite a friend")  // TODO: L10n
                                ) {
                                    shareCode(code: discountCode)
                                }
                            },
                            vm: modalPresentationSourceWrapperViewModel
                        )
                        .fixedSize(horizontal: false, vertical: true)
                    }
                    hContinueButton {
                        vm.advance(
                            after: .inviteFriend(
                                discountCode: discountCode,
                                monthlyDiscountPerReferral: monthlyDiscountPerReferral
                            )
                        )
                    }
                }
            }
            .sectionContainerStyle(.transparent)
        }
        .task {
            namesToDisplay = []
            await delay(0.5)
            for name in ["Elin", "Hampus", "Li", "Peter"] {
                withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                    namesToDisplay.append(name)
                }
                await delay(1)
            }
        }
    }

    private var centerContent: some View {
        hSection(namesToDisplay, id: \.self) { element in
            hRow {
                Circle()
                    .foregroundColor(hSignalColor.Green.element)
                    .frame(width: 14, height: 14)
                hText(element)
                Spacer()
                hText("-10kr")
            }

            .transition(.move(edge: .bottom).combined(with: .opacity))
        }
        .clipped()
        .hWithoutHorizontalPadding(.row)
        .sectionContainerStyle(.transparent)
        .hRowContentAlignment(.center)
        .background() {
            RoundedRectangle(cornerRadius: .padding24)
                .fill(hFillColor.Opaque.negative)
                .hShadow(type: .custom(opacity: 0.05, radius: 5, xOffset: 0, yOffset: 4), show: true)
                .hShadow(type: .custom(opacity: 0.1, radius: 1, xOffset: 0, yOffset: 2), show: true)
                .overlay(
                    RoundedRectangle(cornerRadius: .padding24)
                        .inset(by: 0.5)
                        .stroke(hBorderColor.secondary, lineWidth: 1)
                )
        }
        .padding(.horizontal, 72)
        .accessibilityHidden(true)
    }

    private func shareCode(code: String) {
        let url =
            "\(Environment.current.webBaseURL)/\(hCore.Localization.Locale.currentLocale.value.webPath)/forever/\(code)"
        let message = L10n.referralSmsMessage(monthlyDiscountPerReferral, url)

        let activityVC = UIActivityViewController(
            activityItems: [message as Any],
            applicationActivities: nil
        )
        modalPresentationSourceWrapperViewModel.present(activity: activityVC)
    }
}

#Preview {
    OnboardingInviteScreen(discountCode: "HEDVIG", monthlyDiscountPerReferral: "10 kr")
        .environmentObject(OnboardingNavigationViewModel())
}
