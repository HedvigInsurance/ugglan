import Apollo
import Foundation
import SwiftUI
import hAnalytics
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
                state.memberStateData
            }
        ) { memberStateData in
            hSection {
                hText(L10n.HomeTab.welcomeTitleWithoutName, style: .title1)
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
                claimsContent
            }
            .slideUpFadeAppearAnimation()
            .sectionContainerStyle(.transparent)
        }
    }
}
