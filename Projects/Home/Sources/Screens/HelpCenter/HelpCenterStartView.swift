import Chat
import Contracts
import EditCoInsured
import EditCoInsuredShared
import MoveFlow
import Payment
import Presentation
import SwiftUI
import TerminateContracts
import TravelCertificate
import hCore
import hCoreUI
import hGraphQL

public class HelpCenterNavigationViewModel: ObservableObject {
    @Published public var isChatPresented = false
    @Published var quickActions = QuickActions()

    struct QuickActions {
        var isConnectPaymentsPresented = false
        var isTravelCertificatePresented = false
        var isChangeAddressPresented = false
        var isEditCoInsuredPresented = false
        var isCancellationPresented = false
        var isFirstVetPresented = false
        var isSickAbroadPresented = false
    }
}

public struct HelpCenterStartView: View {
    private var helpCenterModel: HelpCenterModel
    @PresentableStore var store: HomeStore
    @StateObject var helpCenterVm = HelpCenterNavigationViewModel()

    public init() {

        let commonQuestions: [Question] = [
            ClaimsQuestions.q1,
            InsuranceQuestions.q5,
            PaymentsQuestions.q1,
            InsuranceQuestions.q3,
            InsuranceQuestions.q1,
        ]

        self.helpCenterModel = .init(
            title: L10n.hcHomeViewQuestion,
            description:
                L10n.hcHomeViewAnswer,
            commonTopics: [
                .init(
                    title: L10n.hcPaymentsTitle,
                    type: .payments,
                    commonQuestions: [
                        PaymentsQuestions.q1,
                        PaymentsQuestions.q2,
                        PaymentsQuestions.q3,
                    ],
                    allQuestions: [
                        PaymentsQuestions.q4,
                        PaymentsQuestions.q5,
                        PaymentsQuestions.q6,
                        PaymentsQuestions.q7,
                        PaymentsQuestions.q8,
                        PaymentsQuestions.q9,
                        PaymentsQuestions.q10,
                        PaymentsQuestions.q11,
                        PaymentsQuestions.q12,
                        PaymentsQuestions.q13,
                        PaymentsQuestions.q14,
                    ]
                ),
                .init(
                    title: L10n.hcClaimsTitle,
                    type: .claims,
                    commonQuestions: [
                        ClaimsQuestions.q1,
                        ClaimsQuestions.q2,
                        ClaimsQuestions.q3,
                    ],
                    allQuestions: [
                        ClaimsQuestions.q4,
                        ClaimsQuestions.q5,
                        ClaimsQuestions.q6,
                        ClaimsQuestions.q7,
                        ClaimsQuestions.q8,
                        ClaimsQuestions.q9,
                        ClaimsQuestions.q10,
                        ClaimsQuestions.q11,
                        ClaimsQuestions.q12,
                    ]
                ),
                .init(
                    title: L10n.hcCoverageTitle,
                    type: .coverage,
                    commonQuestions: [
                        CoverageQuestions.q1,
                        CoverageQuestions.q2,
                        CoverageQuestions.q3,
                    ],
                    allQuestions: [
                        CoverageQuestions.q4,
                        CoverageQuestions.q5,
                        CoverageQuestions.q6,
                        CoverageQuestions.q7,
                        CoverageQuestions.q8,
                        CoverageQuestions.q9,
                        CoverageQuestions.q10,
                        CoverageQuestions.q11,
                        CoverageQuestions.q12,
                        CoverageQuestions.q13,
                        CoverageQuestions.q14,
                        CoverageQuestions.q15,
                        CoverageQuestions.q17,
                        CoverageQuestions.q18,
                        CoverageQuestions.q19,
                        CoverageQuestions.q20,
                        CoverageQuestions.q21,
                        CoverageQuestions.q22,
                    ]
                ),
                .init(
                    title: L10n.hcInsurancesTitle,
                    type: .myInsurance,
                    commonQuestions: [
                        InsuranceQuestions.q1,
                        InsuranceQuestions.q2,
                        InsuranceQuestions.q3,
                    ],
                    allQuestions: [
                        InsuranceQuestions.q4,
                        InsuranceQuestions.q5,
                        InsuranceQuestions.q6,
                        InsuranceQuestions.q7,
                        InsuranceQuestions.q8,
                        InsuranceQuestions.q9,
                        InsuranceQuestions.q10,
                    ]
                ),
                .init(
                    title: L10n.hcGeneralTitle,
                    type: nil,
                    commonQuestions: [
                        OtherQuestions.q1,
                        OtherQuestions.q2,
                        OtherQuestions.q3,
                    ],
                    allQuestions: [
                        OtherQuestions.q4
                    ]
                ),
            ],
            commonQuestions: commonQuestions
        )
    }

    public var body: some View {
        NavigationStack {
            hForm {
                VStack(spacing: 0) {
                    hSection {
                        VStack(spacing: 40) {
                            Image(uiImage: hCoreUIAssets.bigPillowBlack.image)
                                .resizable()
                                .frame(width: 160, height: 160)
                                .padding(.bottom, 26)
                                .padding(.top, 39)

                            VStack(alignment: .leading, spacing: 8) {
                                hText(helpCenterModel.title)
                                hText(helpCenterModel.description)
                                    .foregroundColor(hTextColor.secondary)
                            }

                            displayQuickActions()
                            displayCommonTopics()

                            QuestionsItems(
                                questions: helpCenterModel.commonQuestions,
                                questionType: .commonQuestions,
                                source: .homeView
                            )
                        }
                    }
                    .sectionContainerStyle(.transparent)
                    SupportView(topic: nil)
                        .environmentObject(helpCenterVm)
                        .padding(.top, 40)
                }
            }
            .navigationTitle(L10n.hcTitle)
            .navigationBarTitleDisplayMode(.inline)
            .navigationDestination(
                for: CommonTopic.self,
                destination: { topic in
                    HelpCenterTopicView(commonTopic: topic)
                        .environmentObject(helpCenterVm)
                }
            )
            .navigationDestination(
                for: Question.self,
                destination: { question in
                    HelpCenterQuestionView(question: question)
                        .environmentObject(helpCenterVm)
                }
            )
            .sheet(isPresented: $helpCenterVm.quickActions.isConnectPaymentsPresented) {
                PaymentsView()
                    .presentationDetents([.large, .medium])
            }
            .sheet(isPresented: $helpCenterVm.quickActions.isEditCoInsuredPresented) {
                let contractStore: ContractStore = globalPresentableStoreContainer.get()

                let contractsSupportingCoInsured = contractStore.state.activeContracts
                    .filter({ $0.showEditCoInsuredInfo })
                    .compactMap({
                        InsuredPeopleConfig(contract: $0)
                    })

                EditCoInsuredViewJourney(configs: contractsSupportingCoInsured)
                    .presentationDetents([.large, .medium])
            }
            .sheet(isPresented: $helpCenterVm.isChatPresented) {
                ChatScreen(vm: .init(topicType: nil))
                    .presentationDetents([.large, .medium])
            }
            .sheet(isPresented: $helpCenterVm.quickActions.isFirstVetPresented) {
                if let hasVetPartners = store.state.quickActions.getFirstVetPartners {
                    FirstVetView(partners: hasVetPartners)
                        .presentationDetents([.large])
                }
            }
            .sheet(isPresented: $helpCenterVm.quickActions.isSickAbroadPresented) {
                let store: HomeStore = globalPresentableStoreContainer.get()
                let quickActions = store.state.quickActions

                let sickAbroadPartners: [Partner]? = quickActions.first(where: { $0.sickAboardPartners != nil })?
                    .sickAboardPartners
                    .map { sickabr in
                        sickabr.map { partner in
                            Partner(id: "", imageUrl: partner.imageUrl, url: "", phoneNumber: partner.phoneNumber)
                        }
                    }

                let config = FlowClaimDeflectConfig(
                    infoText: L10n.submitClaimEmergencyInfoLabel,
                    infoSectionText: L10n.submitClaimEmergencyInsuranceCoverLabel,
                    infoSectionTitle: L10n.submitClaimEmergencyInsuranceCoverTitle,
                    cardTitle: L10n.submitClaimEmergencyGlobalAssistanceTitle,
                    cardText: L10n.submitClaimEmergencyGlobalAssistanceLabel,
                    buttonText: nil,
                    infoViewTitle: nil,
                    infoViewText: nil,
                    questions: [
                        .init(question: L10n.submitClaimEmergencyFaq1Title, answer: L10n.submitClaimEmergencyFaq1Label),
                        .init(question: L10n.submitClaimEmergencyFaq2Title, answer: L10n.submitClaimEmergencyFaq2Label),
                        .init(question: L10n.submitClaimEmergencyFaq3Title, answer: L10n.submitClaimEmergencyFaq3Label),
                        .init(question: L10n.submitClaimEmergencyFaq4Title, answer: L10n.submitClaimEmergencyFaq4Label),
                        .init(question: L10n.submitClaimEmergencyFaq5Title, answer: L10n.submitClaimEmergencyFaq5Label),
                        .init(question: L10n.submitClaimEmergencyFaq6Title, answer: L10n.submitClaimEmergencyFaq6Label),

                    ]
                )

                SubmitClaimDeflectScreen(
                    openChat: {},
                    isEmergencyStep: true,
                    partners: sickAbroadPartners ?? [],
                    config: config
                )
                .presentationDetents([.large, .large])
            }
            .fullScreenCover(
                isPresented: $helpCenterVm.quickActions.isTravelCertificatePresented,
                content: {
                    ListScreen(canAddTravelInsurance: true, infoButtonPlacement: .topBarLeading)
                }
            )
            .fullScreenCover(
                isPresented: $helpCenterVm.quickActions.isChangeAddressPresented,
                content: {
                    MovingFlowViewJourney()
                }
            )
            .fullScreenCover(
                isPresented: $helpCenterVm.quickActions.isCancellationPresented,
                content: {
                    let contractStore: ContractStore = globalPresentableStoreContainer.get()

                    let contractsConfig: [TerminationConfirmConfig] = contractStore.state.activeContracts
                        .filter({ $0.canTerminate })
                        .map({
                            $0.asTerminationConfirmConfig
                        })
                    TerminationViewJourney(configs: contractsConfig)
                }
            )
            .hFormBottomBackgroundColor(.gradient(from: hBackgroundColor.primary, to: hFillColor.opaqueOne))
            .edgesIgnoringSafeArea(.bottom)
        }
    }

    private func displayQuickActions() -> some View {
        VStack(alignment: .leading, spacing: 4) {
            HelpCenterPill(title: L10n.hcQuickActionsTitle, color: .green)
                .padding(.bottom, 4)

            ForEach(store.state.quickActions, id: \.displayTitle) { quickAction in
                hSection {
                    hRow {
                        VStack(alignment: .leading, spacing: 0) {
                            hText(quickAction.displayTitle)
                            hText(quickAction.displaySubtitle, style: .standardSmall)
                                .foregroundColor(hTextColor.secondary)
                        }
                        Spacer()
                    }
                    .withChevronAccessory
                    .verticalPadding(12)
                    .onTap {
                        log.addUserAction(
                            type: .click,
                            name: "help center quick action",
                            attributes: ["action": quickAction.id]
                        )

                        switch quickAction {
                        case .connectPayments:
                            helpCenterVm.quickActions.isConnectPaymentsPresented = true
                        case .travelInsurance:
                            helpCenterVm.quickActions.isTravelCertificatePresented = true
                        case .changeAddress:
                            helpCenterVm.quickActions.isChangeAddressPresented = true
                        case .cancellation:
                            helpCenterVm.quickActions.isCancellationPresented = true
                        case .firstVet:
                            helpCenterVm.quickActions.isFirstVetPresented = true
                        case .sickAbroad:
                            helpCenterVm.quickActions.isSickAbroadPresented = true
                        case .editCoInsured:
                            helpCenterVm.quickActions.isEditCoInsuredPresented = true
                        }
                    }
                }
                .withoutHorizontalPadding
                .sectionContainerStyle(.opaque)
            }
        }
    }

    private func displayCommonTopics() -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HelpCenterPill(title: L10n.hcCommonTopicsTitle, color: .yellow)

            let commonTopics = helpCenterModel.commonTopics
            commonTopicsItems(commonTopics: commonTopics)
        }
    }

    private func commonTopicsItems(commonTopics: [CommonTopic]) -> some View {
        VStack(spacing: 4) {
            ForEach(commonTopics, id: \.self) { item in
                hSection {
                    hRow {
                        NavigationLink(value: item) {
                            hText(item.title)
                            Spacer()
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                    .withChevronAccessory
                }
                .withoutHorizontalPadding
                .hSectionMinimumPadding
                .sectionContainerStyle(.opaque)
            }
        }
    }
}

#Preview{
    let commonQuestions: [Question] = [
        .init(
            question: "When do you charge for my insurance?",
            questionEn: "When do you charge for my insurance?",
            answer: "",
            topicType: .payments,
            relatedQuestions: []
        ),
        .init(
            question: "When do you charge for my insurance?",
            questionEn: "When do you charge for my insurance?",
            answer: "",
            topicType: .payments,
            relatedQuestions: []
        ),
        .init(
            question: "How do I make a claim?",
            questionEn: "How do I make a claim?",
            answer: "",
            topicType: .payments,
            relatedQuestions: []
        ),
        .init(
            question: "How can I view my payment history?",
            questionEn: "How can I view my payment history?",
            answer: "",
            topicType: .payments,
            relatedQuestions: []
        ),
        .init(
            question: "What should I do if my payment fails?",
            questionEn: "What should I do if my payment fails?",
            answer: "",
            topicType: .payments,
            relatedQuestions: []
        ),
    ]

    return HelpCenterStartView()
}
