//
//  hFormBottomAttachedBackground.swift
//  hCoreUI
//
//  Created by Sam Pettersson on 2022-02-08.
//  Copyright © 2022 Hedvig AB. All rights reserved.
//

import Foundation
import SwiftUI

public struct hFormBottomAttachedBackground<Content: View>: View {
    var content: () -> Content
    
    public init(content: @escaping () -> Content) {
        self.content = content
    }
    
    public var body: some View {
        VStack {
            hSeparatorColor.separator.frame(height: .hairlineWidth)
                .edgesIgnoringSafeArea(.horizontal)
            content().padding(16)
        }
        .background(hBackgroundColor.secondary.edgesIgnoringSafeArea([.bottom, .horizontal]))
    }
}
