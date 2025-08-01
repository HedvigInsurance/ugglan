import Foundation
import Market
import PresentableStore
import SwiftUI
import hCore
import hCoreUI

struct ImpersonationSettings: View {
    @PresentableStore var marketStore: MarketStore

    var body: some View {
        hForm {
            VStack(alignment: .leading, spacing: 0) {
                hSection(header: hText("Select locale")) {
                    ForEach(Localization.Locale.allCases, id: \.rawValue) { locale in
                        hRow {
                            hText(locale.rawValue)
                        }
                        .onTap {
                            Task {
                                Localization.Locale.currentLocale.send(locale)
                                await marketStore.sendAsync(.selectLanguage(language: locale.rawValue))
                                ApplicationState.preserveState(.loggedIn)
                                ApplicationState.state = .loggedIn
                            }
                        }
                    }
                }
            }
            VStack {
                hText(
                    "BEWARE: if you select a locale that doesn't match the market of the user weird things will happen."
                )
                .fixedSize(horizontal: false, vertical: true)
                .environment(\.defaultHTextStyle, .label)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .foregroundColor(hTextColor.Opaque.secondary)
            .padding(.horizontal, 15)
            .padding(.top, .padding10)
        }
    }
}

#Preview {
    ImpersonationSettings()
}
