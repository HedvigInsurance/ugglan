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

                VStack(spacing: 8) {
                    PresentableStoreLens(
                        SubmitClaimStore.self,
                        getter: { state in
                            state.pestsStep
                        }
                    ) { pests in
                        let partners = pests?.partners
                        ForEach(Array((partners ?? []).enumerated()), id: \.element) { index, partner in
                            ClaimContactCard(
                                imageUrl: partner.imageUrl,
                                label: L10n.submitClaimPestsCustomerServiceLabel,
                                url: partner.url ?? "",
                                title: index == 0 ? L10n.submitClaimPartnerTitle : nil,
                                buttonText: L10n.submitClaimPestsCustomerServiceButton
                            )
                        }
                    }

                    hSection {
                        VStack(alignment: .leading, spacing: 8) {
                            hText(L10n.submitClaimHowItWorksTitle)
                            hText(L10n.submitClaimPestsHowItWorksLabel)
                                .foregroundColor(hTextColor.secondary)
                        }
                    }
                    .padding(.top, 8)
                    .sectionContainerStyle(.transparent)

                    //                    VStack(spacing: 4) {
                    //                        InfoExpandableView(
                    //                            title: L10n.submitClaimWhatCostTitle,
                    //                            text: L10n.submitClaimGlassDamageWhatCostLabel
                    //                        )
                    //                        InfoExpandableView(
                    //                            title: L10n.submitClaimHowBookTitle,
                    //                            text: L10n.submitClaimGlassDamageHowBookLabel
                    //                        )
                    //                        InfoExpandableView(
                    //                            title: L10n.submitClaimWorkshopTitle,
                    //                            text: L10n.submitClaimGlassDamageWorkshopLabel
                    //                        )
                    //                    }
                    //                    .padding(.vertical, 8)

                    SupportView()
                        .padding(.vertical, 56)
                }
            }
        }
    }
}

struct SubmitClaimPestsScreen_Previews: PreviewProvider {
    static var previews: some View {
        Localization.Locale.currentLocale = .en_SE
        return SubmitClaimPestsScreen()
    }
}
