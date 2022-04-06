import Foundation
import SwiftUI
import hCore
import hCoreUI
import hGraphQL

struct CrossSellingCardLabel: View {
    @PresentableStore var store: ContractStore
    let crossSell: hGraphQL.CrossSell
    var didTapButton: () -> Void

    var body: some View {
        VStack(alignment: .leading) {
            VStack(alignment: .leading, spacing: 4) {
                hText(crossSell.title, style: .headline)
                hText(crossSell.description, style: .footnote)
            }
            .foregroundColor(hLabelColor.primary)
            .colorScheme(.dark)
            Spacer()
            hButton.SmallButtonFilled {
                didTapButton()
            } content: {
                hText(crossSell.buttonText)
                    .frame(maxWidth: .infinity)
            }
            .hButtonFilledStyle(.overImage)
        }
        .padding(16)
        .frame(
            maxWidth: .infinity,
            minHeight: 200,
            alignment: .bottom
        )
    }
}
