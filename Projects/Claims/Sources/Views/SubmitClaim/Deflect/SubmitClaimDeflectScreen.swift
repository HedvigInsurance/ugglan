import Home
import Presentation
import SwiftUI
import hCore
import hCoreUI

public struct SubmitClaimDeflectScreen: View {
    private let model: FlowClaimDeflectStepModel?
    private let isEmergencyStep: Bool
    private let openChat: () -> Void

    init(
        model: FlowClaimDeflectStepModel?,
        openChat: @escaping () -> Void
    ) {
        self.model = model
        self.isEmergencyStep = model?.isEmergencyStep ?? false
        self.openChat = openChat
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
                    let title =
                        model?.partners.count == 1 ? L10n.submitClaimPartnerSingularTitle : L10n.submitClaimPartnerTitle

                    VStack(spacing: 8) {
                        ForEach(Array((model?.partners ?? []).enumerated()), id: \.element) { index, partner in
                            ClaimContactCard(
                                imageUrl: partner.imageUrl,
                                url: partner.url ?? "",
                                phoneNumber: partner.phoneNumber,
                                title: index == 0 ? title : nil,
                                model: model
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

                SupportView(openChat: openChat)
                    .padding(.vertical, 56)
            }
            .padding(.top, 8)
        }
    }
}

extension SubmitClaimDeflectScreen {
    public static var journey: some JourneyPresentation {
        let model: FlowClaimDeflectStepModel? = {
            let store: HomeStore = globalPresentableStoreContainer.get()
            let quickActions = store.state.quickActions
            if let sickAbroadPartners = quickActions.first(where: { $0.sickAboardPartners != nil })?.sickAboardPartners
            {
                return FlowClaimDeflectStepModel(
                    id: .FlowClaimDeflectEmergencyStep,
                    partners: sickAbroadPartners.compactMap({
                        .init(
                            id: "",
                            imageUrl: "",
                            url: "",
                            phoneNumber: $0.phoneNumber
                        )
                    }),
                    isEmergencyStep: true
                )
            }
            return nil
        }()
        return HostingJourney(
            SubmitClaimStore.self,
            rootView: SubmitClaimDeflectScreen(
                model: model,
                openChat: {
                    let homeStore: HomeStore = globalPresentableStoreContainer.get()
                    homeStore.send(.openFreeTextChat(from: nil))
                }
            ),
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
    let model = FlowClaimDeflectStepModel(
        id: .FlowClaimDeflectEmergencyStep,
        partners: [
            .init(
                id: "",
                imageUrl: "",
                url: "",
                phoneNumber: "+46177272727"
            )
        ],
        isEmergencyStep: true
    )
    return SubmitClaimDeflectScreen(model: model, openChat: {})
}
