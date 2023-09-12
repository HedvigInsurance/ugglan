import SwiftUI
import hCore
import hCoreUI

struct SubmitClaimEmergencyScreen: View {
    @State var selectedFields: [String] = []

    var body: some View {
        hForm {
            VStack(spacing: 8) {
                hSection {
                    InfoCard(text: L10n.submitClaimEmergencyInfoLabel, type: .attention)
                }
                .padding(.top, 8)
                ClaimEmergencyContactCard(
                    icon: hCoreUIAssets.hedvigBigLogo,
                    label: L10n.submitClaimEmergencyGlobalAssistanceLabel,
                    buttonText: L10n.submitClaimGlobalAssistanceCallLabel(+45_584_894),
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
                    infoExpandableView(
                        title: L10n.submitClaimWhatCostTitle,
                        text: L10n.submitClaimGlassDamageWhatCostLabel
                    )
                    infoExpandableView(
                        title: L10n.submitClaimHospitalTitle,
                        text: L10n.submitClaimGlassDamageWhatCostLabel
                    )
                    infoExpandableView(
                        title: L10n.submitClaimRebookTitle,
                        text: L10n.submitClaimGlassDamageWorkshopLabel
                    )

                    infoExpandableView(
                        title: L10n.changeAddressQa,
                        text: L10n.submitClaimGlassDamageWorkshopLabel
                    )
                }
                .padding(.top, 16)
                .padding(.bottom, 8)

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
                    .frame(width: 80, height: 80)
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
        SubmitClaimEmergencyScreen()
    }
}
