import Kingfisher
import PresentableStore
import SwiftUI
import hCore
import hCoreUI

public struct FirstVetView: View {
    @PresentableStore var store: HomeStore
    @EnvironmentObject var router: Router
    private let partners: [FirstVetPartner]
    @State private var orientation = UIDevice.current.orientation

    public init(
        partners: [FirstVetPartner]
    ) {
        self.partners = partners
    }

    public var body: some View {
        hForm {
            VStack(spacing: .padding8) {
                ForEach(partners, id: \.id) { partner in
                    hSection {
                        hRow {
                            VStack(alignment: .leading, spacing: .padding16) {
                                HStack(spacing: .padding8) {
                                    Image(uiImage: hCoreUIAssets.firstVetQuickNav.image)
                                    hText(partner.title ?? "")
                                    Spacer()
                                }
                                hText(partner.description ?? "")
                                    .foregroundColor(hTextColor.Opaque.secondary)
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
                                .hButtonTakeFullWidth(true)
                            }
                        }
                    }
                }
                .hWithoutDivider
            }
        }
        .hFormAlwaysAttachToBottom {
            buttonComponent
        }
        .navigationBarTitleDisplayMode(.inline)
    }

    private var buttonComponent: some View {
        hButton.LargeButton(type: .ghost) {
            router.dismiss()
        } content: {
            hText(L10n.generalCloseButton)
        }
    }
}

#Preview {
    FirstVetView(partners: [])
}
