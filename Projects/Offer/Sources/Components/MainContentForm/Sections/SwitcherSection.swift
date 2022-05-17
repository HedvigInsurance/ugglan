import Flow
import Form
import Foundation
import Presentation
import SwiftUI
import UIKit
import hCore
import hCoreUI
import hGraphQL

struct SwitcherSection {}

extension SwitcherSection: View {
    var body: some View {
        VStack {
            PresentableStoreLens(
                OfferStore.self,
                getter: { $0.currentVariant?.bundle ?? nil }
            ) { quoteBundle in
                if let quoteBundle = quoteBundle, quoteBundle.switcher {
                    CurrentInsurerSection(quoteBundle: quoteBundle)
                }
            }
        }
    }
}
