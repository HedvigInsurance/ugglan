import Foundation
import SwiftUI
import hCore
import hCoreUI
import hGraphQL

struct VariationsSection: View {
    let variations: [QuoteVariant]

    var body: some View {
        if variations.count > 1 {
            hSection(header: hText(L10n.offerBundleSelectorTitle)) {
                VStack(alignment: .leading) {
                    ForEach(variations, id: \.id) { variant in
                        VariantSelector(variant: variant)
                            .padding(.top, 15)
                    }
                }
            }.sectionContainerStyle(.transparent)
        }
    }
}

struct VariationSection: View {
    var body: some View {
        PresentableStoreLens(
            OfferStore.self,
            getter: { state in
                state.offerData?.possibleVariations ?? []
            }
        ) { possibleVariations in
            VariationsSection(variations: possibleVariations)
        }
        .presentableStoreLensAnimation(.easeInOut)
        .sectionContainerStyle(.transparent)
    }
}
