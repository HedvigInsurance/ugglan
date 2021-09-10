//
//  CrossSellingNewDot.swift
//  CrossSellingNewDot
//
//  Created by Sam Pettersson on 2021-09-09.
//  Copyright © 2021 Hedvig AB. All rights reserved.
//

import Foundation
import hCore
import hCoreUI
import SwiftUI

struct CrossSellingUnseenCircle: View {
    var body: some View {
        PresentableStoreLens(
            ContractStore.self,
            getter: {
                $0.hasUnseenCrossSell
            },
            setter: { value in
                .hasSeenCrossSells(value: value)
            }
        ) { hasUnseenCrossSell, setHasUnseenCrossSell in
            if hasUnseenCrossSell {
                Circle().fill(hTintColor.red).frame(width: 8, height: 8).onDisappear {
                    setHasUnseenCrossSell(false)
                }.transition(.scale)
            }
        }
        
    }
}
