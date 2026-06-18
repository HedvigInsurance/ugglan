import Foundation
import SwiftUI
import hCore
import hCoreUI

struct ImpersonationSettings: View {
    var body: some View {
        hForm {
            VStack(alignment: .leading, spacing: 0) {
                hSection(header: hText("Select locale")) {
                    ForEach(Localization.Locale.allCases, id: \.rawValue) { locale in
                        hRow {
                            hText(locale.rawValue)
                        }
                        .onTap {
                            Localization.Locale.currentLocale.send(locale)
                            ApplicationState.preserveState(.loggedIn)
                            ApplicationState.state = .loggedIn
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
