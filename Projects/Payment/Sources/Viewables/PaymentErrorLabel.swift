import SwiftUI
import hCore
import hCoreUI

struct PaymentErrorLabel: View {
    let message: String

    var body: some View {
        HStack {
            Image(uiImage: hCoreUIAssets.warningTriangleFilled.image)
                .foregroundColor(hSignalColor.Red.element)
                .accessibilityHidden(true)
            hText(message, style: .label)
                .foregroundColor(hSignalColor.Red.text)
        }
        .padding(.bottom, .padding8)
        .accessibilityElement(children: .combine)
    }
}
