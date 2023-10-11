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
                ActivityIndicator(
                    style: .large,
                    color: hTextColor.primary
                )
                .padding(.top, 15)
            }
        }
        .sectionContainerStyle(.transparent)
    }
}
