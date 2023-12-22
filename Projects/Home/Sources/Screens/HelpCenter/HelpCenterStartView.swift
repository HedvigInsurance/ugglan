import Contracts
import Presentation
import SwiftUI
import hCore
import hCoreUI

public struct HelpCenterStartView: View {
    private var helpCenterModel: HelpCenterModel
    @PresentableStore var store: HomeStore

    public init(
        helpCenterModel: HelpCenterModel
    ) {
        self.helpCenterModel = helpCenterModel
    }

    public var body: some View {
        hForm {
            hSection {
                VStack(spacing: 40) {
                    Image(uiImage: hCoreUIAssets.bigPillowBlack.image)
                        .resizable()
                        .frame(width: 170, height: 170)
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
        }
    }

    private func displayQuickActions() -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HelpCenterPill(title: L10n.hcQuickActionsTitle, color: .green)

            let quickActionsInPair = helpCenterModel.quickActions.chunked(into: 2)

            ForEach(quickActionsInPair, id: \.self) { pair in
                HStack(spacing: 8) {
                    ForEach(pair, id: \.title) { quickAction in
                        quickActionPill(quickAction: quickAction)
                    }
                }
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

    private func quickActionPill(quickAction: QuickAction) -> some View {
        HStack(alignment: .center) {
            hText(quickAction.title)
                .colorScheme(.light)
                .frame(maxWidth: .infinity, alignment: .center)
        }
        .padding(.vertical, 16)
        .background(
            Squircle.default()
                .fill(hGrayscaleTranslucent.greyScaleTranslucent100)
        )
        .onTapGesture {
            store.send(.goToQuickAction(quickAction))
        }
        .frame(maxWidth: 168)
    }

    private func commonTopicsItems(commonTopics: [CommonTopic]) -> some View {
        VStack(spacing: 4) {
            ForEach(commonTopics, id: \.self) { item in
                hSection {
                    hRow {
                        hText(item.title)
                    }
                    .withChevronAccessory
                }
                .withoutHorizontalPadding
                .sectionContainerStyle(.opaque)
                .onTapGesture {
                    store.send(.openHelpCenterTopicView(commonTopic: item))
                }
            }
        }
    }
}

extension HelpCenterStartView {
    public static var journey: some JourneyPresentation {

        let commonQuestions: [Question] = [
            .init(
                question: L10n.hcCommonQuestionsQ01,
                answer: L10n.hcCommonQuestionsA01,
                relatedQuestions: [
                    .init(question: "When does my insurance activate?", answer: "", relatedQuestions: []),
                    .init(question: "When does my insurance activate?", answer: "", relatedQuestions: []),
                    .init(question: "When does my insurance activate?", answer: "", relatedQuestions: []),
                ]
            ),
            .init(
                question: L10n.hcCommonQuestionsQ02,
                answer: L10n.hcCommonQuestionsA02,
                relatedQuestions: []
            ),
            .init(
                question: L10n.hcCommonQuestionsQ03,
                answer:L10n.hcCommonQuestionsA03,
                relatedQuestions: []
            ),
            .init(
                question: L10n.hcCommonQuestionsQ04,
                answer: L10n.hcCommonQuestionsA04,
                relatedQuestions: []
            ),
            .init(
                question: L10n.hcCommonQuestionsQ05,
                answer: L10n.hcCommonQuestionsA05,
                relatedQuestions: []
            ),
        ]

        var quickActions: [QuickAction] {
            var quickActions: [QuickAction] = []
            let contractStore: ContractStore = globalPresentableStoreContainer.get()
            let contracts = contractStore.state.activeContracts

            quickActions.append(.changeBank)

            if !contracts.filter({ $0.supportsAddressChange }).isEmpty {
                quickActions.append(.updateAddress)
            }

            if !contracts.filter({ $0.showEditCoInsuredInfo }).isEmpty {
                quickActions.append(.editCoInsured)
            }

            if !contracts.filter({ $0.hasTravelInsurance }).isEmpty {
                quickActions.append(.travelCertificate)
            }
            return quickActions
        }

        return HostingJourney(
            HomeStore.self,
            rootView: HelpCenterStartView(
                helpCenterModel:
                    .init(
                        title: L10n.hcHomeViewQuestion,
                        description:
                            L10n.hcHomeViewAnswer,
                        quickActions: quickActions,
                        commonTopics: [
                            .init(
                                title: L10n.hcPaymentsTitle,
                                commonQuestions: [
                                    .init(
                                        question: L10n.hcPaymentsQ01,
                                        answer: L10n.hcPaymentsA01,
                                        relatedQuestions: []
                                    ),
                                    .init(
                                        question: L10n.hcPaymentsQ02,
                                        answer: L10n.hcPaymentsA02,
                                        relatedQuestions: []
                                    ),
                                    .init(
                                        question: L10n.hcPaymentsQ03,
                                        answer: L10n.hcPaymentsA03,
                                        relatedQuestions: []
                                    )
                                ],
                                allQuestions: commonQuestions
                            ),
                            .init(
                                title: L10n.hcClaimsTitle,
                                commonQuestions: [
                                    .init(
                                        question: L10n.hcClaimsQ01,
                                        answer: L10n.hcClaimsA01,
                                        relatedQuestions: []
                                    ),
                                    .init(
                                        question: L10n.hcClaimsQ02,
                                        answer: L10n.hcClaimsA02,
                                        relatedQuestions: []
                                    ),
                                    .init(
                                        question: L10n.hcClaimsQ03,
                                        answer: L10n.hcClaimsA03,
                                        relatedQuestions: []
                                    )
                                ],
                                allQuestions: commonQuestions
                            ),
                            .init(
                                title: L10n.hcCoverageTitle,
                                commonQuestions: [
                                    .init(
                                        question: L10n.hcCoverageQ01,
                                        answer: L10n.hcCoverageA01,
                                        relatedQuestions: []
                                    ),
                                    .init(
                                        question: L10n.hcCoverageQ02,
                                        answer: L10n.hcCoverageA02,
                                        relatedQuestions: []
                                    ),
                                    .init(
                                        question: L10n.hcCoverageQ03,
                                        answer: L10n.hcCoverageA03,
                                        relatedQuestions: []
                                    )
                                ],
                                allQuestions: commonQuestions
                            ),
                            .init(
                                title: L10n.hcInsurancesTitle,
                                commonQuestions: [
                                    .init(
                                        question: L10n.hcInsuranceQ01,
                                        answer: L10n.hcInsuranceA01,
                                        relatedQuestions: []
                                    ),
                                    .init(
                                        question: L10n.hcInsuranceQ02,
                                        answer: L10n.hcInsuranceA02,
                                        relatedQuestions: []
                                    ),
                                    .init(
                                        question: L10n.hcInsuranceQ03,
                                        answer: L10n.hcInsuranceA03,
                                        relatedQuestions: []
                                    )
                                ],
                                allQuestions: commonQuestions
                            ),
                            .init(
                                title: L10n.hcGeneralTitle,
                                commonQuestions: [],
                                allQuestions: commonQuestions
                            )
                        ],
                        commonQuestions: commonQuestions
                    )
            ),
            style: .detented(.scrollViewContentSize),
            options: [.largeNavigationBar, .blurredBackground]
        ) { action in
            if case .goToQuickAction = action {
                DismissJourney()
            } else if case let .openHelpCenterTopicView(topic) = action {
                HelpCenterTopicView.journey(commonTopic: topic)
            } else if case let .openHelpCenterQuestionView(question) = action {
                HelpCenterQuestionView.journey(question: question, title: nil)
            }
        }
        .configureTitle(L10n.hcTitle)
        .withJourneyDismissButton
    }
}

#Preview{
    let commonQuestions: [Question] = [
        .init(
            question: "When do you charge for my insurance?",
            answer: "",
            relatedQuestions: []
        ),
        .init(
            question: "When do you charge for my insurance?",
            answer: "",
            relatedQuestions: []
        ),
        .init(
            question: "How do I make a claim?",
            answer: "",
            relatedQuestions: []
        ),
        .init(
            question: "How can I view my payment history?",
            answer: "",
            relatedQuestions: []
        ),
        .init(
            question: "What should I do if my payment fails?",
            answer: "",
            relatedQuestions: []
        ),
    ]

    return HelpCenterStartView(
        helpCenterModel:
            .init(
                title: L10n.hcHomeViewQuestion,
                description:
                    L10n.hcHomeViewAnswer,
                quickActions: [
                    .changeBank,
                    .updateAddress,
                    .editCoInsured,
                    .travelCertificate,
                ],
                commonTopics: [
                    .init(
                        title: "Payments",
                        commonQuestions: commonQuestions,
                        allQuestions: []
                    ),
                    .init(
                        title: "Claims",
                        commonQuestions: commonQuestions,
                        allQuestions: []
                    ),
                    .init(
                        title: "My insurance",
                        commonQuestions: commonQuestions,
                        allQuestions: []
                    ),
                    .init(
                        title: "Co-insured",
                        commonQuestions: commonQuestions,
                        allQuestions: []
                    ),
                    .init(
                        title: "FirstVet",
                        commonQuestions: commonQuestions,
                        allQuestions: []
                    ),
                    .init(
                        title: "Campaigns",
                        commonQuestions: commonQuestions,
                        allQuestions: []
                    ),

                ],
                commonQuestions: commonQuestions
            )
    )
}

extension Array {
    func chunked(into size: Int) -> [[Element]] {
        return stride(from: 0, to: count, by: size)
            .map {
                Array(self[$0..<Swift.min($0 + size, count)])
            }
    }
}
