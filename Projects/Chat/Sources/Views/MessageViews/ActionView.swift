import SwiftUI
import hCoreUI

struct ActionView: View {
    let action: ActionMessage

    var body: some View {
        VStack(spacing: .padding16) {
            if let text = action.text {
                hText(text, style: .body1)
                    .foregroundColor(hTextColor.Opaque.primary)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            hButton(
                .medium,
                .secondary,
                content: .init(title: action.buttonTitle),
                {
                    NotificationCenter.default.post(name: .openDeepLink, object: action.url)
                }
            )
            .hButtonTakeFullWidth(true)
        }
    }
}

#Preview {
    if let url = URL(string: "https://hedvig.com") {
        ActionView(action: .init(url: url, text: "text", buttonTitle: "button"))
            .padding(.horizontal, .padding16)
            .padding(.vertical, .padding12)
            .background(hSurfaceColor.Opaque.primary)
            .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}
