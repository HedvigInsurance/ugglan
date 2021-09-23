//
//  ContractBundleLoadingIndicator.swift
//  ContractBundleLoadingIndicator
//
//  Created by Sam Pettersson on 2021-09-23.
//  Copyright © 2021 Hedvig AB. All rights reserved.
//

import Foundation
import SwiftUI
import hCore
import hCoreUI

struct ContractBundleLoadingIndicator: View {
    var body: some View {
        PresentableStoreLens(
            ContractStore.self,
            getter: { state in
                state.hasLoadedContractBundlesOnce
            }
        ) { hasLoadedContractBundlesOnce in
            if !hasLoadedContractBundlesOnce {
                ActivityIndicator(isAnimating: true).padding(.top, 15)
            }
        }
        .sectionContainerStyle(.transparent)
    }
}
