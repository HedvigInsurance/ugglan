import Flow
import Form
import Foundation
import Presentation
import SwiftUI
import UIKit
import hCore
import hCoreUI

struct DetailsSection {}

extension DetailsSection: View {
    var body: some View {
        PresentableStoreLens(
            OfferStore.self,
            getter: { state in
                state.currentVariant?.bundle.quotes ?? []
            }
        ) { quotes in
            ForEach(quotes, id: \.id) { quote in
                quote.detailsTable.view
            }
        }
    }
}
