import SwiftUI
import hCore
import hCoreUI

struct SubmitClaimGlassDamageScreen: View {
    var body: some View {
        hForm {
            VStack(spacing: 16) {
                hSection {
                    InfoCard(text: L10n.submitClaimGlassDamageInfoLabel, type: .info)
                }
                VStack(spacing: 8) {
                    ClaimContactCard(
                        image: hCoreUIAssets.carGlass.image,
                        label: L10n.submitClaimGlassDamageOnlineBookingLabel,
                        buttonText: L10n.submitClaimGlassDamageOnlineBookingButton,
                        title: L10n.submitClaimPartnerTitle
                    )

                    ClaimContactCard(
                        image: hCoreUIAssets.rydsBilglas.image,
                        label: L10n.submitClaimGlassDamageOnlineBookingLabel,
                        buttonText: L10n.submitClaimGlassDamageOnlineBookingButton
                    )
                }

                hSection {
                    VStack(alignment: .leading, spacing: 8) {
                        hText(L10n.submitClaimHowItWorksTitle)
                        hText(L10n.submitClaimGlassDamageHowItWorksLabel)
                            .foregroundColor(hTextColorNew.secondary)
                    }
                }
                .padding(.top, 8)
                .sectionContainerStyle(.transparent)

                VStack(spacing: 4) {
                    InfoExpandableView(
                        title: L10n.submitClaimWhatCostTitle,
                        text: L10n.submitClaimGlassDamageWhatCostLabel
                    )
                    InfoExpandableView(
                        title: L10n.submitClaimHowBookTitle,
                        text: L10n.submitClaimGlassDamageHowBookLabel
                    )
                    InfoExpandableView(
                        title: L10n.submitClaimWorkshopTitle,
                        text: L10n.submitClaimGlassDamageWorkshopLabel
                    )
                }
                .padding(.top, 8)

                SupportView()
                    .padding(.vertical, 56)
            }
            .padding(.top, 8)

        }
    }
}

struct SubmitClaimGlassDamageScreen_Previews: PreviewProvider {
    static var previews: some View {
        Localization.Locale.currentLocale = .en_SE
        return SubmitClaimGlassDamageScreen()
    }
}
