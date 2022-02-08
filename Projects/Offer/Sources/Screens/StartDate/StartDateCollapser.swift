//
//  StartDateCollapser.swift
//  Offer
//
//  Created by Sam Pettersson on 2022-02-08.
//  Copyright © 2022 Hedvig AB. All rights reserved.
//

import Foundation
import SwiftUI

struct StartDateCollapser<Content: View>: View {
    var expanded: Bool
    @ViewBuilder var expandedContent: () -> Content
    
    var body: some View {
        expandedContent()
            .frame(height: 300)
            .frame(maxHeight: expanded ? 300 : 0)
            .opacity(expanded ? 1 : 0)
            .clipped()
    }
}
