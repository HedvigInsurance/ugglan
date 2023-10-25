import Kingfisher
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

                PresentableStoreLens(
                    SubmitClaimStore.self,
                    getter: { state in
                        state.emergencyStep
                    }
                ) { emergency in
                    ForEach(emergency?.partners ?? [], id: \.id) { partner in
                        ClaimEmergencyContactCard(
                            imageUrl: partner.imageUrl,
                            label: L10n.submitClaimEmergencyGlobalAssistanceLabel,
                            phoneNumber: partner.phoneNumber,
                            cardTitle: L10n.submitClaimEmergencyGlobalAssistanceTitle,
                            footnote: L10n.submitClaimGlobalAssistanceFootnote
                        )
                    }
                }

                hSection {
                    VStack(alignment: .leading, spacing: 8) {
                        hText(L10n.submitClaimEmergencyInsuranceCoverTitle)
                        hText(L10n.submitClaimEmergencyInsuranceCoverLabel)
                            .foregroundColor(hTextColor.secondary)
                    }
                }
                .padding(.top, 16)
                .sectionContainerStyle(.transparent)

                //                VStack(spacing: 4) {
                //                    InfoExpandableView(
                //                        title: L10n.submitClaimWhatCostTitle,
                //                        text: L10n.submitClaimGlassDamageWhatCostLabel
                //                    )
                //                    InfoExpandableView(
                //                        title: L10n.submitClaimHospitalTitle,
                //                        text: L10n.submitClaimGlassDamageWhatCostLabel
                //                    )
                //                    InfoExpandableView(
                //                        title: L10n.submitClaimRebookTitle,
                //                        text: L10n.submitClaimGlassDamageWorkshopLabel
                //                    )
                //
                //                    InfoExpandableView(
                //                        title: L10n.changeAddressQa,
                //                        text: L10n.submitClaimGlassDamageWorkshopLabel
                //                    )
                //                }
                //                .animation(.easeOut)
                //                .padding(.top, 16)

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
    var imageUrl: String
    var label: String
    var phoneNumber: String?

    init(
        imageUrl: String,
        label: String,
        phoneNumber: String? = nil,
        cardTitle: String? = nil,
        footnote: String? = nil
    ) {
        self.imageUrl = imageUrl
        self.label = label
        self.phoneNumber = phoneNumber
        self.cardTitle = cardTitle
        self.footnote = footnote
    }

    var body: some View {
        hSection {
            VStack(spacing: 16) {
                if let imageUrl = URL(string: imageUrl) {
                    KFImage(imageUrl)
                        .setProcessor(SVGImageProcessor())
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(height: 80)
                        .foregroundColor(hTextColor.negative)
                        .padding(.vertical, 8)
                }
                VStack(spacing: 0) {
                    if let cardTitle = cardTitle {
                        hText(cardTitle)
                            .foregroundColor(hColorScheme(light: hTextColor.negative, dark: hTextColor.primary))
                    }
                    hText(label)
                        .foregroundColor(hTextColor.tertiary)
                        .padding(.horizontal, 18)
                        .fixedSize(horizontal: false, vertical: true)
                        .multilineTextAlignment(.center)
                }
                .padding(.bottom, 8)
                hButton.MediumButton(type: .secondaryAlt) {
                    if let phoneNumber {
                        let tel = "tel://"
                        let formattedString = tel + phoneNumber
                        if let url = URL(string: formattedString) {
                            UIApplication.shared.open(url)
                        }
                    }
                } content: {
                    hText(L10n.submitClaimGlobalAssistanceCallLabel(phoneNumber ?? ""))
                        .foregroundColor(hTextColor.primary)
                        .colorScheme(.light)
                }
                .padding(.horizontal, 16)

                if let footnote = footnote {
                    hText(footnote, style: .caption1)
                        .foregroundColor(hTextColor.tertiary)
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
