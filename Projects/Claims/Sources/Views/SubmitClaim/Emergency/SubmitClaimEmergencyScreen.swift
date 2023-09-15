import SwiftUI
import hCore
import hCoreUI

struct SubmitClaimEmergencyScreen: View {
    var body: some View {
        hForm {
            VStack(spacing: 8) {
                hSection {
                    InfoCard(text: L10n.submitClaimEmergencyInfoLabel, type: .attention)
                }
                ClaimEmergencyContactCard(
                    icon: hCoreUIAssets.hedvigBigLogo,
                    label: L10n.submitClaimEmergencyGlobalAssistanceLabel,
                    buttonText: L10n.submitClaimGlobalAssistanceCallLabel("+45 38 48 94 61"),
                    cardTitle: L10n.submitClaimEmergencyGlobalAssistanceTitle,
                    footnote: L10n.submitClaimGlobalAssistanceFootnote
                )
                
                hSection {
                    VStack(alignment: .leading, spacing: 8) {
                        hText(L10n.submitClaimEmergencyInsuranceCoverTitle)
                        hText(L10n.submitClaimEmergencyInsuranceCoverLabel)
                            .foregroundColor(hTextColorNew.secondary)
                    }
                }
                .padding(.top, 16)
                .sectionContainerStyle(.transparent)
                
                VStack(spacing: 4) {
                    InfoExpandableView(
                        title: L10n.submitClaimWhatCostTitle,
                        text: L10n.submitClaimGlassDamageWhatCostLabel
                    )
                    InfoExpandableView(
                        title: L10n.submitClaimHospitalTitle,
                        text: L10n.submitClaimGlassDamageWhatCostLabel
                    )
                    InfoExpandableView(
                        title: L10n.submitClaimRebookTitle,
                        text: L10n.submitClaimGlassDamageWorkshopLabel
                    )
                    
                    InfoExpandableView(
                        title: L10n.changeAddressQa,
                        text: L10n.submitClaimGlassDamageWorkshopLabel
                    )
                }
                .padding(.top, 16)
                SupportView()
                    .padding(.vertical, 56)
            }
            .padding(.top, 8)
        }
    }
}

struct ClaimEmergencyContactCard: View {
    @PresentableStore var store: SubmitClaimStore
    var cardTitle: String?
    var footnote: String?
    var icon: ImageAsset
    var label: String
    var buttonText: String
    
    init(
        icon: ImageAsset,
        label: String,
        buttonText: String,
        cardTitle: String? = nil,
        footnote: String? = nil
    ) {
        self.icon = icon
        self.label = label
        self.buttonText = buttonText
        self.cardTitle = cardTitle
        self.footnote = footnote
    }
    
    var body: some View {
        hSection {
            VStack(spacing: 16) {
                Image(uiImage: icon.image)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(height: 80)
                    .foregroundColor(hTextColorNew.negative)
                    .padding(.vertical, 8)
                VStack(spacing: 0) {
                    if let cardTitle = cardTitle {
                        hText(cardTitle)
                            .foregroundColor(hTextColorNew.negative)
                    }
                    hText(label)
                        .foregroundColor(hTextColorNew.tertiary)
                        .padding(.horizontal, 18)
                        .fixedSize(horizontal: false, vertical: true)
                        .multilineTextAlignment(.center)
                }
                .padding(.bottom, 8)
                hButton.MediumButtonSecondaryAlt {
                    
                } content: {
                    hText(buttonText)
                }
                .padding(.horizontal, 16)
                
                if let footnote = footnote {
                    hText(footnote, style: .caption1)
                        .foregroundColor(hTextColorNew.tertiary)
                }
            }
            .padding(.vertical, 24)
        }
        .sectionContainerStyle(.black)
        
    }
}

struct SubmitClaimEmergencyScreen_Previews: PreviewProvider {
    static var previews: some View {
        Localization.Locale.currentLocale = .en_SE
        return SubmitClaimEmergencyScreen()
    }
}
