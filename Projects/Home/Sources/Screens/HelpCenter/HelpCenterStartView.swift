import Contracts
import Presentation
import SwiftUI
import TravelCertificate
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
            VStack(spacing: 0) {
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
                SupportView()
                    .padding(.top, 16)
            }
        }
        .edgesIgnoringSafeArea(.bottom)
    }

    private func displayQuickActions() -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HelpCenterPill(title: L10n.hcQuickActionsTitle, color: .green)

            let commonClaimsInPair = store.state.allCommonClaims.chunked(into: 2)

            ForEach(commonClaimsInPair, id: \.self) { pair in
                HStack(spacing: 8) {
                    ForEach(pair, id: \.id) { quickAction in
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

    private func quickActionPill(quickAction: CommonClaim) -> some View {
        HStack(alignment: .center) {
            hText(quickAction.displayTitle)
                .colorScheme(.light)
                .frame(maxWidth: .infinity, alignment: .center)
        }
        .padding(.vertical, 16)
        .background(
            Squircle.default()
                .fill(hGrayscaleTranslucent.greyScaleTranslucent100)
        )
        .onTapGesture {
            Task {
                if case quickAction.id = CommonClaim.travelInsurance().id {
                    _ = try? await TravelInsuranceFlowJourney.getTravelCertificate()
                }
                store.send(.goToQuickAction(quickAction))
            }
        }
        .frame(maxWidth: 168)
        .frame(maxHeight: 56)
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
                question: L10n.hcClaimsQ01,
                answer: L10n.hcClaimsA02,
                relatedQuestions: []
            ),
            .init(
                question: L10n.hcInsuranceQ05,
                answer: L10n.hcInsuranceA05,
                relatedQuestions: []
            ),
            .init(
                question: L10n.hcPaymentsQ01,
                answer: L10n.hcPaymentsA01,
                relatedQuestions: []
            ),
            .init(
                question: L10n.hcInsuranceQ03,
                answer: L10n.hcInsuranceA03,
                relatedQuestions: []
            ),
            .init(
                question: L10n.hcInsuranceQ01,
                answer: L10n.hcInsuranceA01,
                relatedQuestions: []
            ),
        ]

        return HostingJourney(
            HomeStore.self,
            rootView: HelpCenterStartView(
                helpCenterModel:
                    .init(
                        title: L10n.hcHomeViewQuestion,
                        description:
                            L10n.hcHomeViewAnswer,
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
                                    ),
                                ],
                                allQuestions: [
                                    .init(
                                        question: L10n.hcPaymentsQ04,
                                        answer: L10n.hcPaymentsA04,
                                        relatedQuestions: []
                                    ),
                                    .init(
                                        question: L10n.hcPaymentsQ05,
                                        answer: L10n.hcPaymentsA05,
                                        relatedQuestions: []
                                    ),
                                    .init(
                                        question: L10n.hcPaymentsQ06,
                                        answer: L10n.hcPaymentsA06,
                                        relatedQuestions: []
                                    ),
                                    .init(
                                        question: L10n.hcPaymentsQ07,
                                        answer: L10n.hcPaymentsA07,
                                        relatedQuestions: []
                                    ),
                                    .init(
                                        question: L10n.hcPaymentsQ08,
                                        answer: L10n.hcPaymentsA08,
                                        relatedQuestions: []
                                    ),
                                    .init(
                                        question: L10n.hcPaymentsQ09,
                                        answer: L10n.hcPaymentsA09,
                                        relatedQuestions: []
                                    ),
                                    .init(
                                        question: L10n.hcPaymentsQ10,
                                        answer: L10n.hcPaymentsA10,
                                        relatedQuestions: []
                                    ),
                                    .init(
                                        question: L10n.hcPaymentsQ11,
                                        answer: L10n.hcPaymentsA11,
                                        relatedQuestions: []
                                    ),
                                    .init(
                                        question: L10n.hcPaymentsQ12,
                                        answer: L10n.hcPaymentsA12,
                                        relatedQuestions: []
                                    ),
                                    .init(
                                        question: L10n.hcPaymentsQ13,
                                        answer: L10n.hcPaymentsA13,
                                        relatedQuestions: []
                                    ),
                                    .init(
                                        question: L10n.hcPaymentsQ14,
                                        answer: L10n.hcPaymentsA14,
                                        relatedQuestions: []
                                    ),
                                ]
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
                                    ),
                                ],
                                allQuestions: [
                                    .init(
                                        question: L10n.hcClaimsQ04,
                                        answer: L10n.hcClaimsA04,
                                        relatedQuestions: []
                                    ),
                                    .init(
                                        question: L10n.hcClaimsQ05,
                                        answer: L10n.hcClaimsA05,
                                        relatedQuestions: []
                                    ),
                                    .init(
                                        question: L10n.hcClaimsQ06,
                                        answer: L10n.hcClaimsA06,
                                        relatedQuestions: []
                                    ),
                                    .init(
                                        question: L10n.hcClaimsQ07,
                                        answer: L10n.hcClaimsA07,
                                        relatedQuestions: []
                                    ),
                                    .init(
                                        question: L10n.hcClaimsQ08,
                                        answer: L10n.hcClaimsA08,
                                        relatedQuestions: []
                                    ),
                                    .init(
                                        question: L10n.hcClaimsQ09,
                                        answer: L10n.hcClaimsA09,
                                        relatedQuestions: []
                                    ),
                                    .init(
                                        question: L10n.hcClaimsQ10,
                                        answer: L10n.hcClaimsA10,
                                        relatedQuestions: []
                                    ),
                                    .init(
                                        question: L10n.hcClaimsQ11,
                                        answer: L10n.hcClaimsA11,
                                        relatedQuestions: []
                                    ),
                                    .init(
                                        question: L10n.hcClaimsQ12,
                                        answer: L10n.hcClaimsA12,
                                        relatedQuestions: []
                                    ),
                                ]
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
                                    ),
                                ],
                                allQuestions: [
                                    .init(
                                        question: L10n.hcCoverageQ04,
                                        answer: L10n.hcCoverageA04,
                                        relatedQuestions: []
                                    ),
                                    .init(
                                        question: L10n.hcCoverageQ05,
                                        answer: L10n.hcCoverageA05,
                                        relatedQuestions: []
                                    ),
                                    .init(
                                        question: L10n.hcCoverageQ06,
                                        answer: L10n.hcCoverageA06,
                                        relatedQuestions: []
                                    ),
                                    .init(
                                        question: L10n.hcCoverageQ07,
                                        answer: L10n.hcCoverageA07,
                                        relatedQuestions: []
                                    ),
                                    .init(
                                        question: L10n.hcCoverageQ08,
                                        answer: L10n.hcCoverageA08,
                                        relatedQuestions: []
                                    ),
                                    .init(
                                        question: L10n.hcCoverageQ09,
                                        answer: L10n.hcCoverageA09(0),
                                        relatedQuestions: []
                                    ),
                                    .init(
                                        question: L10n.hcCoverageQ10,
                                        answer: L10n.hcCoverageA10,
                                        relatedQuestions: []
                                    ),
                                    .init(
                                        question: L10n.hcCoverageQ11,
                                        answer: L10n.hcCoverageA11,
                                        relatedQuestions: []
                                    ),
                                    .init(
                                        question: L10n.hcCoverageQ12,
                                        answer: L10n.hcCoverageA12(0),
                                        relatedQuestions: []
                                    ),
                                    .init(
                                        question: L10n.hcCoverageQ13,
                                        answer: L10n.hcCoverageA13,
                                        relatedQuestions: []
                                    ),
                                    .init(
                                        question: L10n.hcCoverageQ14,
                                        answer: L10n.hcCoverageA14,
                                        relatedQuestions: []
                                    ),
                                    .init(
                                        question: L10n.hcCoverageQ15,
                                        answer: L10n.hcCoverageA15,
                                        relatedQuestions: []
                                    ),
                                    .init(
                                        question: L10n.hcCoverageQ17,
                                        answer: L10n.hcCoverageA17,
                                        relatedQuestions: []
                                    ),
                                    .init(
                                        question: L10n.hcCoverageQ18,
                                        answer: L10n.hcCoverageA18,
                                        relatedQuestions: []
                                    ),
                                    .init(
                                        question: L10n.hcCoverageQ19,
                                        answer: L10n.hcCoverageA19,
                                        relatedQuestions: []
                                    ),
                                    .init(
                                        question: L10n.hcCoverageQ20,
                                        answer: L10n.hcCoverageA20,
                                        relatedQuestions: []
                                    ),
                                    .init(
                                        question: L10n.hcCoverageQ21,
                                        answer: L10n.hcCoverageA21,
                                        relatedQuestions: []
                                    ),
                                    .init(
                                        question: L10n.hcCoverageQ22,
                                        answer: L10n.hcCoverageA22,
                                        relatedQuestions: []
                                    ),
                                ]
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
                                    ),
                                ],
                                allQuestions: [
                                    .init(
                                        question: L10n.hcInsuranceQ04,
                                        answer: L10n.hcInsuranceA04,
                                        relatedQuestions: []
                                    ),
                                    .init(
                                        question: L10n.hcInsuranceQ05,
                                        answer: L10n.hcInsuranceA05,
                                        relatedQuestions: []
                                    ),
                                    .init(
                                        question: L10n.hcInsuranceQ06,
                                        answer: L10n.hcInsuranceA06,
                                        relatedQuestions: []
                                    ),
                                    .init(
                                        question: L10n.hcInsuranceQ07,
                                        answer: L10n.hcInsuranceA07,
                                        relatedQuestions: []
                                    ),
                                    .init(
                                        question: L10n.hcInsuranceQ08,
                                        answer: L10n.hcInsuranceA08,
                                        relatedQuestions: []
                                    ),
                                ]
                            ),
                            .init(
                                title: L10n.hcGeneralTitle,
                                commonQuestions: [
                                    .init(
                                        question: L10n.hcOtherQ01,
                                        answer: L10n.hcOtherA01,
                                        relatedQuestions: []
                                    ),
                                    .init(
                                        question: L10n.hcOtherQ02,
                                        answer: L10n.hcOtherA02,
                                        relatedQuestions: []
                                    ),
                                    .init(
                                        question: L10n.hcOtherQ03,
                                        answer: L10n.hcOtherA03,
                                        relatedQuestions: []
                                    ),
                                ],
                                allQuestions: [
                                    .init(
                                        question: L10n.hcOtherQ04,
                                        answer: L10n.hcOtherA04,
                                        relatedQuestions: []
                                    )
                                ]
                            ),
                        ],
                        commonQuestions: commonQuestions
                    )
            ),
            style: .detented(.scrollViewContentSize),
            options: [.largeNavigationBar, .blurredBackground]
        ) { action in
            if case .goToQuickAction = action {
                DismissJourney()
            } else if case .openFreeTextChat = action {
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
