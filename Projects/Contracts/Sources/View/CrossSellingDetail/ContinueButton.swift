//
//  ContinueButton.swift
//  ContinueButton
//
//  Created by Sam Pettersson on 2021-10-07.
//  Copyright © 2021 Hedvig AB. All rights reserved.
//

import Foundation
import SwiftUI
import hCoreUI
import hCore
import hGraphQL

struct ContinueButton: View {
    @PresentableStore var store: ContractStore
    var crossSell: CrossSell
    
    var body: some View {
        VStack {
            hGrayscaleColor.one.frame(height: .hairlineWidth)
            hButton.LargeButtonFilled {
                if let embarkStoryName = crossSell.embarkStoryName {
                    store.send(.openCrossSellingEmbark(name: embarkStoryName))
                }
            } content: {
                hText("Calculate your price")
            }
            .padding(16)
        }
        .background(hBackgroundColor.secondary.edgesIgnoringSafeArea(.bottom))
    }
}
