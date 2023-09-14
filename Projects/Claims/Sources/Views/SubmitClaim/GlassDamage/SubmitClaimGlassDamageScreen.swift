import SwiftUI
import hCore
import hCoreUI

struct SubmitClaimGlassDamageScreen: View {
    @State var selectedFields: [String] = []

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
                    .padding(.vertical, 56)
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

struct ClaimContactCard: View {
    @PresentableStore var store: SubmitClaimStore
    var title: String?
    var image: UIImage
    var label: String
    var buttonText: String

    init(
        image: UIImage,
        label: String,
        buttonText: String,
        title: String? = nil
    ) {
        self.image = image
        self.label = label
        self.buttonText = buttonText
        self.title = title
    }

    var body: some View {
        if let title {
            hSection {
                sectionContent
            }
            .withHeader({
                HStack {
                    hText(title)
                    Spacer()
                    Image(uiImage: hCoreUIAssets.infoSmall.image)
                        .foregroundColor(hTextColorNew.secondary)
                        .fixedSize()
                        .onTapGesture {
                            store.send(
                                .navigationAction(
                                    action: .openInfoScreen(title: L10n.submitClaimPartnerTitle, description: "")
                                )
                            )
                        }
                }
            })
            .sectionContainerStyle(.black)
        } else {
            hSection {
                sectionContent
            }
            .sectionContainerStyle(.black)
        }
    }

    private var sectionContent: some View {
        VStack(spacing: 8) {
            Image(uiImage: image)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(height: 40)
                .foregroundColor(hTextColorNew.negative)
                .padding(.vertical, 16)
            hText(label)
                .foregroundColor(hTextColorNew.tertiary)
                .padding(.bottom, 8)
            hButton.MediumButtonSecondaryAlt {

            } content: {
                hText(buttonText)
            }
            .padding(.horizontal, 16)
        }
        .padding(.vertical, 16)

    }
}

struct SupportView: View {
    @PresentableStore var store: SubmitClaimStore

    var body: some View {
        VStack(spacing: 24) {
            VStack(spacing: 0) {
                hText(L10n.submitClaimNeedHelpTitle)
                    .foregroundColor(hTextColorNew.primaryTranslucent)
                hText(L10n.submitClaimNeedHelpLabel)
                    .foregroundColor(hTextColorNew.secondary)
            }
            hButton.MediumButtonPrimary {
                store.send(.dissmissNewClaimFlow)
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    store.send(.submitClaimOpenFreeTextChat)
                }
            } content: {
                hText(L10n.CrossSell.Info.faqChatButton)
            }
            .fixedSize(horizontal: true, vertical: false)

        }
    }
}

struct SubmitClaimGlassDamageScreen_Previews: PreviewProvider {
    static var previews: some View {
        SubmitClaimGlassDamageScreen()
    }
}
