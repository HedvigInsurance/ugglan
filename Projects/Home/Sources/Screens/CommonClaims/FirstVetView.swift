import Kingfisher
import PresentableStore
import SwiftUI
import hCore
import hCoreUI

public struct FirstVetView: View {
    @PresentableStore var store: HomeStore
    @EnvironmentObject var router: Router
    private let partners: [FirstVetPartner]

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

                                hButton(
                                    .medium,
                                    .secondaryAlt,
                                    title: L10n.commonClaimButton,
                                    {
                                        if let url = URL(
                                            string: partner.url
                                        ) {
                                            UIApplication.shared.open(url)
                                        }
                                    }
                                )
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
        hCloseButton {
            router.dismiss()
        }
    }
}

#Preview {
    FirstVetView(partners: [])
}
