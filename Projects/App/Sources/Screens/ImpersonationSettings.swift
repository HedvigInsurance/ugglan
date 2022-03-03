import Foundation
import Presentation
import SwiftUI
import hCore
import hCoreUI

struct ImpersonationSettings: View {
    @PresentableStore var store: UgglanStore

    var body: some View {
        hForm {
            hSection(header: hText("Select locale")) {
                ForEach(Localization.Locale.allCases, id: \.rawValue) { locale in
                    hRow {
                        hText(locale.rawValue)
                    }
                    .onTap {
                        Localization.Locale.currentLocale = locale
                        ApplicationState.preserveState(.loggedIn)
                        UIApplication.shared.appDelegate.logout()
                    }
                }
            }
            .withFooter {
                hText(
                    "BEWARE: if you select a locale that doesn't match the market of the user weird things will happen."
                )
            }
        }
    }
}
