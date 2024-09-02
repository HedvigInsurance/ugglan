import Apollo
import Foundation
import StoreContainer
import SwiftUI
import hCore
import hCoreUI
import hGraphQL

struct ActiveSectionView<Claims: View>: View {
    @PresentableStore var store: HomeStore

    var claimsContent: Claims

    var body: some View {
        PresentableStoreLens(
            HomeStore.self,
            getter: { state in
                state.memberContractState
            }
        ) { memberStateData in
            hSection {
                hText(L10n.HomeTab.welcomeTitleWithoutName, style: .displayXSLong)
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
                claimsContent
            }
        }
    }
}
