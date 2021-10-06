//
//  CrossSellHighlights.swift
//  CrossSellHighlights
//
//  Created by Sam Pettersson on 2021-10-06.
//  Copyright © 2021 Hedvig AB. All rights reserved.
//

import Foundation
import SwiftUI
import hCoreUI
import hCore
import hGraphQL

struct CrossSellHightlights: View {
    let info: CrossSellInfo
    
    var body: some View {
        hSection(header: hText("Highlights")) {
            ForEach(info.highlights, id: \.title) { highlight in
                HStack {
                    hText(highlight.title)
                }
            }
        }.sectionContainerStyle(.transparent)
    }
}
