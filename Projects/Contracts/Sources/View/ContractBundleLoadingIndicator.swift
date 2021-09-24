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
