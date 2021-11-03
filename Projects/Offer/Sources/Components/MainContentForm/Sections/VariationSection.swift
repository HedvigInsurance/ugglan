//
//  VariationSection.swift
//  Offer
//
//  Created by Sam Pettersson on 2021-11-03.
//  Copyright © 2021 Hedvig AB. All rights reserved.
//

import Foundation
import SwiftUI
import hCoreUI
import hCore

struct VariationSection: View {
    var body: some View {
        PresentableStoreLens(
            OfferStore.self,
            getter: { state in
                state.offerData?.possibleVariations ?? []
            }
        ) { possibleVariations in
            if possibleVariations.count != 1 {
                VStack {
                    hText("Ditt försäkringspaket", style: .headline)
                    
                    ForEach(possibleVariations, id: \.id) { possibleVariation in
                        hRow {
                            hText(possibleVariation.tag ?? "")
                        }
                    }
                }
            }
        }
    }
}
