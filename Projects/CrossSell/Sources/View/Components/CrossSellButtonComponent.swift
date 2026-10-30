import SwiftUI
import hCore
import hCoreUI

struct CrossSellButtonComponent: View {
    let crossSell: RecommendedCrossSell
    @State private var isLoading = false
    @Environment(\.dismiss) var dismiss
    var body: some View {
        hSection {
            VStack(spacing: .padding16) {
                hButton(
                    .large,
                    .primary,
                    content: .init(title: buttonTitle),
                    openRecommendation
                )
                .disabled(isLoading)
                .hButtonIsLoading(isLoading)
                .animation(.default, value: isLoading)
                .accessibilityHint(L10n.crossSellButton)
                if let buttonDescription {
                    hText(buttonDescription, style: .finePrint)
                        .foregroundColor(hTextColor.Translucent.secondary)
                }
            }
        }
        .sectionContainerStyle(.transparent)
    }

    private var buttonTitle: String {
        switch crossSell {
        case let .insurance(insurance): return insurance.buttonText ?? L10n.crossSellButton
        case let .addon(addon): return addon.buttonText
        }
    }

    private var buttonDescription: String? {
        switch crossSell {
        case let .insurance(insurance): return insurance.buttonDescription
        case .addon: return nil
        }
    }

    private func openRecommendation() {
        switch crossSell {
        case let .insurance(insurance):
            isLoading = true
            Task {
                let didOpen = await insurance.openStore()
                isLoading = false
                if didOpen {
                    dismiss()
                }
            }
        case let .addon(addon):
            if let url = URL(string: addon.deepLink) {
                NotificationCenter.default.post(name: .openDeepLink, object: url)
            }
            dismiss()
        }
    }
}

#Preview {
    CrossSellButtonComponent(
        crossSell: .insurance(
            .init(
                id: "id1",
                source: .home,
                title: "title",
                description: "description",
                buttonTitle: "Save 15%",
                webActionURL: "",
                imageUrl: nil,
                buttonDescription: "button"
            )
        )
    )
}
