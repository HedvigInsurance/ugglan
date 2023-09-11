import SwiftUI
import hCoreUI
import hCore

struct SubmitClaimGlassDamageScreen: View {
    var body: some View {
        hForm {
            VStack(spacing: 16) {
                hSection {
                    InfoCard(text: L10n.submitClaimGlassDamageInfoLabel, type: .info)
                }
                hSection {
                    VStack(spacing: 8) {
                        Image(uiImage: hCoreUIAssets.carGlass.image)
                            .resizable()
                            .frame(width: 150, height: 40)
                            .foregroundColor(hTextColorNew.negative)
                            .padding(.vertical, 16)
                        hText(L10n.submitClaimGlassDamageOnlineBookingLabel, style: .title3)
                            .foregroundColor(hTextColorNew.tertiary)
                            .padding(.bottom, 8)
                        hButton.MediumButtonSecondaryAlt {
                            
                        } content: {
                            hText(L10n.submitClaimGlassDamageOnlineBookingButton, style: .title3)
                        }
                    }
                    .padding(.vertical, 16)
                }
                .withHeader {
                    HStack {
                        hText(L10n.submitClaimPartnerTitle, style: .title3)
                        Spacer()
                        Image(uiImage: hCoreUIAssets.infoSmall.image)
                            .foregroundColor(hTextColorNew.secondary)
                    }
                }
                .sectionContainerStyle(.black)
            }
        }
    }
}

struct SubmitClaimGlassDamageScreen_Previews: PreviewProvider {
    static var previews: some View {
        SubmitClaimGlassDamageScreen()
    }
}
