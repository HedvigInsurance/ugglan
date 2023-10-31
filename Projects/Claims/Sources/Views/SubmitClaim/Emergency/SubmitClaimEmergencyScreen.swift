import Home
import Kingfisher
import Presentation
import SwiftUI
import hCore
import hCoreUI

public struct SubmitClaimEmergencyScreen: View {

    public init() {}

    public var body: some View {
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
                    if emergency?.partners != nil {
                        ForEach(emergency?.partners ?? [], id: \.id) { partner in
                            ClaimEmergencyContactCard(
                                imageUrl: partner.imageUrl,
                                label: L10n.submitClaimEmergencyGlobalAssistanceLabel,
                                phoneNumber: partner.phoneNumber,
                                cardTitle: L10n.submitClaimEmergencyGlobalAssistanceTitle,
                                footnote: L10n.submitClaimGlobalAssistanceFootnote
                            )
                        }
                    } else {
                        PresentableStoreLens(
                            HomeStore.self,
                            getter: { state in
                                state.commonClaims
                            }
                        ) { commonClaims in
                            if let index = commonClaims.firstIndex(where: {
                                $0.layout.emergency?.emergencyNumber != nil
                            }) {
                                ClaimEmergencyContactCard(
                                    image: hCoreUIAssets.hedvigBigLogo.image,
                                    label: L10n.submitClaimEmergencyGlobalAssistanceLabel,
                                    phoneNumber: commonClaims[index].layout.emergency?.emergencyNumber,
                                    cardTitle: L10n.submitClaimEmergencyGlobalAssistanceTitle,
                                    footnote: L10n.submitClaimGlobalAssistanceFootnote
                                )
                            }
                        }
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

                VStack(spacing: 4) {
                    InfoExpandableView(
                        title: L10n.submitClaimEmergencyFaq1Title,
                        text: L10n.submitClaimEmergencyFaq1Label
                    )
                    InfoExpandableView(
                        title: L10n.submitClaimEmergencyFaq2Title,
                        text: L10n.submitClaimEmergencyFaq2Label
                    )
                    InfoExpandableView(
                        title: L10n.submitClaimEmergencyFaq3Title,
                        text: L10n.submitClaimEmergencyFaq3Label
                    )
                    InfoExpandableView(
                        title: L10n.submitClaimEmergencyFaq4Title,
                        text: L10n.submitClaimEmergencyFaq4Label
                    )
                    InfoExpandableView(
                        title: L10n.submitClaimEmergencyFaq5Title,
                        text: L10n.submitClaimEmergencyFaq5Label
                    )
                    InfoExpandableView(
                        title: L10n.submitClaimEmergencyFaq6Title,
                        text: L10n.submitClaimEmergencyFaq6Label
                    )
                }
                .animation(.easeOut)
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
    var imageUrl: String?
    var image: UIImage?
    var label: String
    var phoneNumber: String?

    init(
        imageUrl: String? = nil,
        image: UIImage? = nil,
        label: String,
        phoneNumber: String? = nil,
        cardTitle: String? = nil,
        footnote: String? = nil
    ) {
        self.imageUrl = imageUrl
        self.image = image
        self.label = label
        self.phoneNumber = phoneNumber
        self.cardTitle = cardTitle
        self.footnote = footnote
    }

    var body: some View {
        hSection {
            VStack(spacing: 16) {
                Group {
                    if let imageUrl = URL(string: imageUrl) {
                        KFImage(imageUrl)
                            .setProcessor(SVGImageProcessor())
                            .resizable()
                    } else if let image {
                        Image(uiImage: image)
                            .resizable()
                    }
                }
                .aspectRatio(contentMode: .fit)
                .frame(height: 80)
                .foregroundColor(hTextColor.negative)
                .colorScheme(.light)
                .padding(.vertical, 8)
                VStack(spacing: 0) {
                    if let cardTitle = cardTitle {
                        hText(cardTitle)
                            .foregroundColor(hColorScheme(light: hTextColor.negative, dark: hTextColor.primary))
                    }
                    hText(label)
                        .foregroundColor(hTextColor.tertiary)
                        .colorScheme(.light)
                        .padding(.horizontal, 24)
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
                        .colorScheme(.light)
                }
            }
            .padding(.vertical, 24)
        }
        .sectionContainerStyle(.black)

    }
}

extension SubmitClaimEmergencyScreen {
    public static var journey: some JourneyPresentation {
        HostingJourney(
            SubmitClaimStore.self,
            rootView: SubmitClaimEmergencyScreen(),
            style: .detented(.scrollViewContentSize),
            options: [.largeNavigationBar, .blurredBackground]
        ) { action in
            if case .dissmissNewClaimFlow = action {
                DismissJourney()
            }
        }
        .configureTitle(L10n.commonClaimEmergencyTitle)
        .withJourneyDismissButton
    }
}

struct SubmitClaimEmergencyScreen_Previews: PreviewProvider {
    static var previews: some View {
        Localization.Locale.currentLocale = .en_SE
        return SubmitClaimEmergencyScreen()
    }
}
