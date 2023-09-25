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
                    PresentableStoreLens(
                        SubmitClaimStore.self,
                        getter: { state in
                            state.glassDamageStep
                        }
                    ) { glassDamage in
                        let partners = glassDamage?.partners
                        ForEach(Array((partners ?? []).enumerated()), id: \.element) { index, partner in
                            ClaimContactCard(
                                imageUrl: partner.imageUrl,
                                label: L10n.submitClaimGlassDamageOnlineBookingLabel,
                                url: partner.url ?? "",
                                title: index == 0 ? L10n.submitClaimPartnerTitle : nil,
                                buttonText: L10n.submitClaimGlassDamageOnlineBookingButton
                            )
                        }
                    }
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
