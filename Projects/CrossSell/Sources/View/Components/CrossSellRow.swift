import SwiftUI
import hCore
import hCoreUI

public struct CrossSellRow<Pillow: View>: View {
    private let title: String
    private let subtitle: String
    private let buttonTitle: String
    private let variant: hButtonConfigurationType
    private let isLoading: Bool
    private let accessibilityAction: String?
    private let pillow: Pillow
    private let action: () -> Void

    @State private var tapAnimationTrigger = false

    public init(
        title: String,
        subtitle: String,
        buttonTitle: String,
        variant: hButtonConfigurationType,
        isLoading: Bool = false,
        accessibilityAction: String? = nil,
        @ViewBuilder pillow: () -> Pillow,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.subtitle = subtitle
        self.buttonTitle = buttonTitle
        self.variant = variant
        self.isLoading = isLoading
        self.accessibilityAction = accessibilityAction
        self.pillow = pillow()
        self.action = action
    }

    public var body: some View {
        HStack(spacing: .padding16) {
            pillow
                .frame(width: 48, height: 48)
                .accessibilityHidden(true)

            HStack(spacing: 0) {
                VStack(alignment: .leading, spacing: 0) {
                    hText(title, style: .body1).foregroundColor(hTextColor.Translucent.primary)
                    MarqueeText(
                        text: subtitle,
                        leftFade: 2,
                        rightFade: 2,
                        pauseDuration: 2
                    )
                    .foregroundColor(hTextColor.Opaque.secondary)
                }
                Spacer()

                hButton(.small, variant, content: .init(title: buttonTitle)) { performAction() }
                    .disabled(isLoading)
                    .hButtonIsLoading(isLoading)
                    .animation(.default, value: isLoading)
            }
        }
        .padding(.vertical, .padding8)
        .accessibilityElement(children: .combine)
        .accessibilityHint(L10n.voiceoverPressTo + " " + (accessibilityAction ?? buttonTitle))
        .onTapGesture { performAction() }
        .accessibilityAddTraits(.isButton)
        .accessibilityAction(.default) { performAction() }
    }

    private func performAction() {
        guard !isLoading else { return }
        tapAnimationTrigger.toggle()
        action()
        ImpactGenerator.soft()
    }
}
