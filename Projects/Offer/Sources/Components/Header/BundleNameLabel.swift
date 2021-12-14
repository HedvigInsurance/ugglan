//
//  BundleNameLabel.swift
//  Offer
//
//  Created by Sam Pettersson on 2021-12-14.
//  Copyright © 2021 Hedvig AB. All rights reserved.
//

import Foundation
import Presentation
import hCore
import hCoreUI
import SwiftUI

struct BundleNameLabel: View {
    var body: some View {
        PresentableStoreLens(
            OfferStore.self,
            getter: { state in
                state.currentVariant?.bundle.displayName
            }
        ) { bundleName in
            if let bundleName = bundleName {
                hText(bundleName, style: .subheadline).foregroundColor(hLabelColor.secondary)
            }
        }.presentableStoreLensAnimation(.spring())
    }
}
