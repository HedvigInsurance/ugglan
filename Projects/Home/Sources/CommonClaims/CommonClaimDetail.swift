import Kingfisher
import Presentation
import SwiftUI
import hCore
import hCoreUI

public struct QuickActionDetailScreen: View {
    @PresentableStore var store: HomeStore
    private let quickAction: QuickAction

    public init(
        quickAction: QuickAction
    ) {
        self.quickAction = quickAction
    }

    public var body: some View {
        hForm {
            let bulletPoints = quickAction.layout?.titleAndBulletPoint?.bulletPoints
            VStack(spacing: 8) {
                ForEach(bulletPoints ?? [], id: \.hashValue) { bulletPoint in
                    hSection {
                        hRow {
                            VStack(alignment: .leading, spacing: 16) {
                                HStack(spacing: 8) {
                                    if quickAction.isFirstVet {
                                        Image(uiImage: hCoreUIAssets.firstVetQuickNav.image)
                                    }
                                    hText(bulletPoint.title)
                                    Spacer()
                                }
                                hText(bulletPoint.description)
                                    .foregroundColor(hTextColor.secondary)
                                    .fixedSize(horizontal: false, vertical: true)
                                if quickAction.isFirstVet {
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

extension QuickActionDetailScreen {
    public static func journey(quickAction: QuickAction) -> some JourneyPresentation {
        HostingJourney(
            HomeStore.self,
            rootView: QuickActionDetailScreen(quickAction: quickAction),
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
    QuickActionDetailScreen(
        quickAction: QuickAction(
            id: "",
            displayTitle: "",
            layout: QuickAction.Layout.init(
                titleAndBulletPoint:
                    .init(
                        color: "",
                        bulletPoints: [
                            .init(
                                title: "title",
                                description: "description"
                                    //                                icon: nil
                            ),
                            .init(
                                title: "title",
                                description: "description"
                                    //                                icon: nil
                            ),
                        ]
                    ),
                emergency: nil
            )
        )
    )
}
