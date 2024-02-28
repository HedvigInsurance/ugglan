import Home
import Presentation
import SwiftUI
import hCore
import hCoreUI

public struct SubmitClaimDeflectScreen: View {
    var model: FlowClaimDeflectStepModel?
    var isEmergencyStep: Bool = false

    init(
        deflectModel: @escaping () -> FlowClaimDeflectStepModel?
    ) {
        self.isEmergencyStep = deflectModel()?.id == .FlowClaimDeflectEmergencyStep || deflectModel() == nil
        self.model = {
            if deflectModel() == nil {
                if isEmergencyStep {
                    let store: HomeStore = globalPresentableStoreContainer.get()
                    let commonClaims = store.state.commonClaims
                    if let index = commonClaims.firstIndex(where: { $0.layout.emergency?.emergencyNumber != nil }) {
                        return FlowClaimDeflectStepModel(
                            id: .FlowClaimDeflectEmergencyStep,
                            partners: [
                                .init(
                                    id: "",
                                    imageUrl: "",
                                    url: "",
                                    phoneNumber: commonClaims[index].layout.emergency?.emergencyNumber
                                )
                            ]
                        )
                    }
                }
            }
            return deflectModel()
        }()
    }

    public var body: some View {
        hForm {
            VStack(spacing: 16) {
                hSection {
                    let type: InfoCardType = isEmergencyStep ? .attention : .info
                    InfoCard(text: model?.config?.infoText ?? "", type: type)
                }
                if isEmergencyStep {
                    ForEach(model?.partners ?? [], id: \.id) { partner in
                        ClaimEmergencyContactCard(
                            imageUrl: partner.imageUrl,
                            image: partner.imageUrl == "" ? hCoreUIAssets.hedvigBigLogo.image : nil,
                            label: model?.config?.cardText ?? "",
                            phoneNumber: partner.phoneNumber,
                            cardTitle: model?.config?.cardTitle,
                            footnote: L10n.submitClaimGlobalAssistanceFootnote
                        )
                    }
                } else {
                    VStack(spacing: 8) {
                        ForEach(Array((model?.partners ?? []).enumerated()), id: \.element) { index, partner in
                            ClaimContactCard(
                                imageUrl: partner.imageUrl,
                                label: model?.config?.cardText ?? "",
                                url: partner.url ?? "",
                                title: index == 0 ? model?.config?.cardTitle : nil,
                                buttonText: model?.config?.buttonText ?? ""
                            )
                        }
                    }
                }

                hSection {
                    VStack(alignment: .leading, spacing: 8) {
                        hText(model?.config?.infoSectionTitle ?? "")
                        hText(model?.config?.infoSectionText ?? "")
                            .foregroundColor(hTextColor.secondary)
                    }
                }
                .padding(.top, 8)
                .sectionContainerStyle(.transparent)

                VStack(spacing: 4) {
                    ForEach(model?.config?.questions ?? [], id: \.question) { question in
                        InfoExpandableView(
                            title: question.question,
                            text: question.answer
                        )
                    }
                }
                .animation(.easeOut)
                .padding(.top, 8)

                SupportView()
                    .padding(.vertical, 56)
            }
            .padding(.top, 8)
        }
    }
}

extension SubmitClaimDeflectScreen {
    public static var journey: some JourneyPresentation {
        HostingJourney(
            SubmitClaimStore.self,
            rootView: SubmitClaimDeflectScreen(deflectModel: {
                let store: SubmitClaimStore = globalPresentableStoreContainer.get()
                return store.state.emergencyStep
            }),
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

#Preview{
    Localization.Locale.currentLocale = .en_SE
    return SubmitClaimDeflectScreen(deflectModel: { .init(id: .FlowClaimDeflectGlassDamageStep, partners: []) })
}
