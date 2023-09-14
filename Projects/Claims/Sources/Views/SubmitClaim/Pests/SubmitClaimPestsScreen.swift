import SwiftUI
import hCore
import hCoreUI

struct SubmitClaimPestsScreen: View {
    @State var selectedFields: [String] = []

    var body: some View {
        hForm {
            VStack(spacing: 16) {
                hSection {
                    InfoCard(text: L10n.submitClaimPestsInfoLabel, type: .info)
                }
                .padding(.top, 8)

                ClaimContactCard(
                    image: hCoreUIAssets.nomor.image,
                    label: L10n.submitClaimPestsCustomerServiceLabel,
                    buttonText: L10n.submitClaimPestsCustomerServiceButton,
                    title: L10n.submitClaimPartnerTitle
                )

                hSection {
                    VStack(alignment: .leading, spacing: 8) {
                        hText(L10n.submitClaimHowItWorksTitle)
                        hText(L10n.submitClaimPestsHowItWorksLabel)
                            .foregroundColor(hTextColorNew.secondary)
                    }
                }
                .padding(.top, 8)
                .sectionContainerStyle(.transparent)

                VStack(spacing: 4) {
                    infoExpandableView(
                        title: L10n.submitClaimWhatCostTitle,
                        text: L10n.submitClaimGlassDamageWhatCostLabel
                    )
                    infoExpandableView(
                        title: L10n.submitClaimHowBookTitle,
                        text: L10n.submitClaimGlassDamageHowBookLabel
                    )
                    infoExpandableView(
                        title: L10n.submitClaimWorkshopTitle,
                        text: L10n.submitClaimGlassDamageWorkshopLabel
                    )
                }
                .padding(.vertical, 8)

                SupportView()
                    .padding(.vertical, 32)
            }
        }
    }

    func infoExpandableView(title: String, text: String) -> some View {
        hSection {
            hRow {
                hText(title)
                    .lineLimit(1)
            }
            .withCustomAccessory({
                Spacer()
                Image(
                    uiImage: selectedFields.contains(title)
                        ? hCoreUIAssets.minusSmall.image : hCoreUIAssets.plusSmall.image
                )
                .transition(.opacity.animation(.easeOut))
            })
            .onTap {
                if !selectedFields.contains(title) {
                    selectedFields.append(title)
                } else {
                    if let index = selectedFields.firstIndex(of: title) {
                        selectedFields.remove(at: index)
                    }
                }
            }
            .hWithoutDivider

            if selectedFields.contains(title) {
                VStack(alignment: .leading) {
                    hRow {
                        hText(text)
                            .foregroundColor(hTextColorNew.secondary)
                    }
                }
            }
        }
    }
}

struct SubmitClaimPestsScreen_Previews: PreviewProvider {
    static var previews: some View {
        SubmitClaimPestsScreen()
    }
}
