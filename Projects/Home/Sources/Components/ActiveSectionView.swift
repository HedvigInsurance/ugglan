import Apollo
import Foundation
import SwiftUI
import hAnalytics
import hCore
import hCoreUI
import hGraphQL

struct ActiveSectionView<Content: View, Claims: View, CommonClaims: View>: View {
    @PresentableStore var store: HomeStore

    var claimsContent: Claims
    var commonClaims: CommonClaims
    var statusCard: Content

    var body: some View {
        PresentableStoreLens(
            HomeStore.self,
            getter: { state in
                state.memberStateData
            }
        ) { memberStateData in
            hSection {
                if let name = memberStateData.name {
                    hText(L10n.HomeTab.welcomeTitle(name), style: .prominentTitle)
                        .multilineTextAlignment(.center)
                        .fixedSize(horizontal: false, vertical: true)
                }
                claimsContent.addStatusCard {
                    statusCard
                }
            }
            .slideUpFadeAppearAnimation()
            .sectionContainerStyle(.transparent)

            if hAnalyticsExperiment.homeCommonClaim {
                commonClaims.slideUpFadeAppearAnimation(delay: 0.4)
            }
            if hAnalyticsExperiment.movingFlow {
                hSection {
                    hRow {
                        Image(uiImage: hCoreUIAssets.apartment.image)
                        L10n.HomeTab.editingSectionChangeAddressLabel.hText()
                    }
                    .withCustomAccessory {
                        Spacer()
                        Image(uiImage: hCoreUIAssets.chevronRight.image)
                    }
                    .onTap {
                        store.send(.openMovingFlow)
                    }
                }
                .withHeader {
                    hText(
                        L10n.HomeTab.editingSectionTitle,
                        style: .title2
                    )
                }
                .slideUpFadeAppearAnimation(delay: 0.6)
            }
        }
    }
}
