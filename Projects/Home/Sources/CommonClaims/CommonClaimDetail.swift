import Kingfisher
import Presentation
import SwiftUI
import hCore
import hCoreUI

public struct CommonClaimDetail: View {
    @PresentableStore var store: HomeStore
    let claim: CommonClaim

    public init(
        claim: CommonClaim
    ) {
        self.claim = claim
    }

    public var body: some View {
        hForm {
            let bulletPoints = claim.layout.titleAndBulletPoint?.bulletPoints
            VStack(spacing: 8) {
                ForEach(bulletPoints ?? [], id: \.hashValue) { bulletPoint in
                    hSection {
                        hRow {
                            VStack(alignment: .leading, spacing: 16) {
                                HStack(spacing: 8) {
                                    if claim.id == "30" || claim.id == "31" || claim.id == "32" {
                                        Image(uiImage: hCoreUIAssets.firstVetQuickNav.image)
                                    }
                                    hText(bulletPoint.title)
                                    Spacer()
                                }
                                hText(bulletPoint.description)
                                    .foregroundColor(hTextColor.secondary)
                                    .fixedSize(horizontal: false, vertical: true)
                                if claim.id == "30" || claim.id == "31" || claim.id == "32" {
                                    hButton.MediumButton(type: .secondaryAlt) {
                                        if let url = URL(
                                            string: "https://app.adjust.com/11u5tuxu"
                                        ) {
                                            UIApplication.shared.open(url)
                                        }
                                    } content: {
                                        hText(L10n.commonClaimButton)
                                    }
                                }
                            }
                        }
                    }
                }
                .hWithoutDivider
            }
        }
        .hFormAttachToBottom {
            hButton.LargeButton(type: .ghost) {
                store.send(.dismissOtherServices)
            } content: {
                hText(L10n.generalCloseButton)
            }
        }
    }
}

extension CommonClaimDetail {
    public static func journey(claim: CommonClaim) -> some JourneyPresentation {
        HostingJourney(
            HomeStore.self,
            rootView: CommonClaimDetail(claim: claim),
            style: .detented(.large, modally: true),
            options: [.largeNavigationBar, .blurredBackground]
        ) { action in
            if case .dismissOtherServices = action {
                DismissJourney()
            }
        }
    }
}

#Preview{
    CommonClaimDetail(
        claim: CommonClaim(
            id: "",
            icon: nil,
            imageName: "",
            displayTitle: "",
            layout: CommonClaim.Layout.init(
                titleAndBulletPoint:
                    .init(
                        color: "",
                        bulletPoints: [
                            .init(
                                title: "title",
                                description: "description",
                                icon: nil
                            ),
                            .init(
                                title: "title",
                                description: "description",
                                icon: nil
                            ),
                        ]
                    ),
                emergency: nil
            )
        )
    )
}
