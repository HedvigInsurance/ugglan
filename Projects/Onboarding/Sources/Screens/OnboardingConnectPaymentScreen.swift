import Payment
import SwiftUI
import hCore
import hCoreUI

struct OnboardingConnectPaymentScreen: View {
    @EnvironmentObject var vm: OnboardingNavigationViewModel
    @State private var bankSide: CGFloat = 0

    private var isPaymentConnected: Bool {
        vm.steps.contains { step in
            if case let .connectPayment(isConnected) = step { return isConnected }
            return false
        }
    }

    var body: some View {
        hForm {
            graphic
        }
        .hFormTitle(
            title: .init(.small, .body1, "Connect payment", alignment: .leading),
            subTitle: .init(
                .small,
                .body1,
                "Add a payment method to activate your insurance",
                alignment: .leading
            )
        )
        .hFormContentPosition(.center)
        .hFormAttachToBottom {
            hSection {
                VStack(spacing: .padding8) {
                    hText("Adding a payment method is required to keep your insurance active", style: .finePrint)
                        .foregroundColor(hTextColor.Translucent.secondary)
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: .infinity)
                    if isPaymentConnected {
                        hContinueButton { [weak vm] in
                            vm?.advance(after: .connectPayment(isConnected: true))
                        }
                    } else {
                        hButton(.large, .primary, content: .init(title: "Connect payment")) { [weak vm] in
                            vm?.connectPaymentVm
                                .set(onSuccess: { [weak vm] in
                                    vm?.markPaymentConnected()
                                })
                        }
                    }
                }
            }
            .sectionContainerStyle(.transparent)
        }
        .task {
            await vm.fetchPaymentStatus()
        }
    }
    private var graphic: some View {
        HStack(spacing: .padding16) {
            hText("Bank")
                .padding(.padding24)
                .hShadow(type: .custom(opacity: 0.05, radius: 5, xOffset: 0, yOffset: 4), show: true)
                .hShadow(type: .custom(opacity: 0.1, radius: 1, xOffset: 0, yOffset: 2), show: true)
                .background(
                    GeometryReader { proxy in
                        let side = max(proxy.size.width, proxy.size.height)
                        RoundedRectangle(cornerRadius: .padding24)
                            .inset(by: 0.5)
                            .stroke(hBorderColor.secondary, lineWidth: 1)
                            .frame(width: side, height: side)
                            .position(x: proxy.size.width / 2, y: proxy.size.height / 2)
                            .preference(key: SquareSideKey.self, value: side)
                    }
                )
            Group {
                if isPaymentConnected {
                    DotsActivityIndicator(.standard, animated: false)
                        .transition(.opacity.animation(.bouncy))
                } else {
                    DotsActivityIndicator(.standard)
                        .transition(.opacity.animation(.bouncy))
                }
            }
            .useDarkColor

            hCoreUIAssets.bigPillowBlack.view
                .resizable()
                .frame(width: bankSide, height: bankSide)
                .overlay(alignment: .topTrailing) {
                    hCoreUIAssets.checkmarkFilled.view
                        .resizable()
                        .frame(width: bankSide / 2.5, height: bankSide / 2.5)
                        .foregroundColor(hSignalColor.Green.element)

                        .background {
                            Circle()
                                .fill(hSurfaceColor.Opaque.primary)
                                .frame(width: bankSide / 4, height: bankSide / 4)
                        }
                        .scaleEffect(isPaymentConnected ? 1 : 0, anchor: .center)
                        .animation(.bouncy, value: isPaymentConnected)
                        .offset(x: bankSide / 12, y: -bankSide / 12)
                }
        }
        .onPreferenceChange(SquareSideKey.self) { bankSide = $0 }
        .accessibilityHidden(true)
    }
}

private struct SquareSideKey: PreferenceKey {
    static var defaultValue: CGFloat { 0 }
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = max(value, nextValue())
    }
}

#Preview {
    let model = OnboardingNavigationViewModel()
    model.steps = [.connectPayment(isConnected: false)]
    return OnboardingConnectPaymentScreen()
        .environmentObject(model)
        .task {
            await delay(1)
            model.markPaymentConnected()
        }
}
