import Kingfisher
import Presentation
import SwiftUI
import hCore
import hCoreUI

public struct FirstVetView: View {
    @PresentableStore var store: HomeStore
    private let partners: [FirstVetPartner]

    public init(
        partners: [FirstVetPartner]
    ) {
        self.partners = partners
    }

    public var body: some View {
        hForm {
            VStack(spacing: 8) {
                ForEach(partners, id: \.id) { partner in
                    hSection {
                        hRow {
                            VStack(alignment: .leading, spacing: 16) {
                                HStack(spacing: 8) {
                                    Image(uiImage: hCoreUIAssets.firstVetQuickNav.image)
                                    hText(partner.title ?? "")
                                    Spacer()
                                }
                                hText(partner.description ?? "")
                                    .foregroundColor(hTextColor.secondary)
                                    .fixedSize(horizontal: false, vertical: true)
                                hButton.MediumButton(type: .secondaryAlt) {
                                    if let url = URL(
                                        string: partner.url
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

//extension FirstVetView {
//    public static func journey(partners: [FirstVetPartner]) -> some JourneyPresentation {
//        HostingJourney(
//            HomeStore.self,
//            rootView: FirstVetView(partners: partners),
//            style: .detented(.large, modally: true),
//            options: [.largeNavigationBar, .blurredBackground]
//        ) { action in
//            if case .dismissOtherServices = action {
//                DismissJourney()
//            }
//        }
//    }
//}

#Preview{
    FirstVetView(partners: [])
}
