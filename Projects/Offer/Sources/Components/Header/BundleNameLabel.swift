import Foundation
import Presentation
import SwiftUI
import hCore
import hCoreUI

struct BundleNameLabel: View {
    var body: some View {
        PresentableStoreLens(
            OfferStore.self,
            getter: { state in
                state.currentVariant?.bundle.displayName
            }
        ) { bundleName in
            if let bundleName = bundleName {
                hText(bundleName, style: .subheadline)
                    .foregroundColor(hTextColor.secondary)
                    .padding(.horizontal, 10)
                    .multilineTextAlignment(.center)
            }
        }
        .presentableStoreLensAnimation(.spring())
    }
}
