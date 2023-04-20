import Apollo
import Foundation
import SwiftUI
import hAnalytics
import hCore
import hCoreUI
import hGraphQL

struct FutureSectionView: View {
    var memberName: String

    var body: some View {
        PresentableStoreLens(
            HomeStore.self,
            getter: { state in
                state.futureStatus
            }
        ) { futureStatus in
            hSection {
                VStack(alignment: .leading, spacing: 16) {
                    switch futureStatus {
                    case .activeInFuture(let inceptionDate):
                        L10n.HomeTab
                            .activeInFutureWelcomeTitle(
                                memberName,
                                inceptionDate
                            )
                            .hText(.prominentTitle)
                        L10n.HomeTab.activeInFutureBody
                            .hText(.body)
                            .foregroundColor(hLabelColor.secondary)
                    case .pendingSwitchable:
                        L10n.HomeTab.pendingSwitchableWelcomeTitle(memberName)
                            .hText(.prominentTitle)
                        L10n.HomeTab.pendingSwitchableBody
                            .hText(.body)
                            .foregroundColor(hLabelColor.secondary)
                    case .pendingNonswitchable:
                        L10n.HomeTab.pendingNonswitchableWelcomeTitle(memberName)
                            .hText(.prominentTitle)
                        L10n.HomeTab.pendingNonswitchableBody
                            .hText(.body)
                            .foregroundColor(hLabelColor.secondary)
                    case .none:
                        EmptyView()
                    }
                }
            }
            .sectionContainerStyle(.transparent)
        }
    }
}
