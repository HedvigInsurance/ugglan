import SwiftUI
import hCore
import hCoreUI

struct ClaimChatAIDisclaimerView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 13) {
            hText(L10n.claimChatAiInfo, style: .label)
                .foregroundColor(hTextColor.Translucent.secondary)
                .padding(.horizontal, .padding16)
            hRowDivider()
                .dividerInsets(.all, 0)
                .ignoresSafeArea()
        }
        .padding(.top, 11)
        .background(Self.backgroundColor)
        .id(ClaimChatConstants.aiDisclaimerViewId)
        .transition(.opacity.combined(with: .move(edge: .top)))
    }

    private static var backgroundColor: some hColor {
        hColorScheme(
            light: hColorBase(Color(hexString: "FAFAFA").opacity(0.6)),
            dark: hFillColor.Opaque.black
        )
    }
}

#Preview {
    VStack(spacing: 0) {
        ClaimChatAIDisclaimerView()
        Spacer()
    }
}
