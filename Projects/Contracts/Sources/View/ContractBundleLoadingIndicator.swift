import Foundation
import SwiftUI
import hCore
import hCoreUI

struct ContractBundleLoadingIndicator: View {
    var body: some View {
        PresentableStoreLens(
            ContractStore.self,
            getter: { state in
                !state.contracts.isEmpty || !state.contractBundles.isEmpty
            }
        ) { hasLoadedContracts in
            if !hasLoadedContracts {
                ActivityIndicator(style: .large).padding(.top, 15)
            }
        }
        .sectionContainerStyle(.transparent)
    }
}
