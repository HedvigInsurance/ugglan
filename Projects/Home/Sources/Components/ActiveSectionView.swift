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
    let memberId: String

    var body: some View {
        PresentableStoreLens(
            HomeStore.self,
            getter: { state in
                state.memberStateData
            }
        ) { memberStateData in
            hSection {
                if let name = memberStateData.name {
                    hText(L10n.HomeTab.welcomeTitle(name), style: .title1)
                        .multilineTextAlignment(.center)
                        .fixedSize(horizontal: false, vertical: true)
                }

                let members = ApolloClient.retreiveMembersWithDeleteRequests()
                if members.contains(memberId) {
                    InfoCard(
                        text: L10n.hometabAccountDeletionNotification,
                        type: .attention
                    )
                }
                claimsContent
            }
            .slideUpFadeAppearAnimation()
            .sectionContainerStyle(.transparent)
        }
    }
}
