import Contracts
import Presentation
import SwiftUI
import TravelCertificate
import hCore
import hCoreUI
import hGraphQL

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
                    .padding(.top, 40)
            }
        }
        .hFormBottomBackgroundColor(.gradient(from: hBackgroundColor.primary, to: hFillColor.opaqueOne))
        .edgesIgnoringSafeArea(.bottom)
    }

    private func displayQuickActions() -> some View {
        VStack(alignment: .leading, spacing: 4) {
            HelpCenterPill(title: L10n.hcQuickActionsTitle, color: .green)
                .padding(.bottom, 4)

            let commonClaimsInPair = store.state.allCommonClaims.chunked(into: 2)

            ForEach(commonClaimsInPair, id: \.self) { pair in
                HStack(spacing: 4) {
                    ForEach(pair, id: \.id) { quickAction in
                        if pair.count > 1 {
                            quickActionPill(quickAction: quickAction)
                        } else {
                            quickActionPill(quickAction: quickAction)
                            quickActionPill(quickAction: nil)
                        }
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

    private func quickActionPill(quickAction: CommonClaim?) -> some View {
        HStack(alignment: .center) {
            hText(quickAction?.displayTitle ?? "")
                .frame(maxWidth: .infinity, alignment: .center)
        }
        .padding(.vertical, 16)
        .background(
            Squircle.default()
                .fill(
                    getColor(quickAction: quickAction)
                )
        )
        .onTapGesture {
            if let quickAction {
                log.addUserAction(
                    type: .click,
                    name: "help center quick action",
                    attributes: ["action": quickAction.id]
                )
                Task {
                    store.send(.goToQuickAction(quickAction))
                }
            }
        }
        .frame(maxHeight: 56)
    }

    @hColorBuilder
    private func getColor(quickAction: CommonClaim?) -> some hColor {
        if quickAction != nil {
            hColorScheme(
                light: hGrayscaleTranslucent.greyScaleTranslucent100,
                dark: hGrayscaleColor.greyScale900
            )
        } else {
            hColorScheme(
                light: hBackgroundColor.clear,
                dark: hBackgroundColor.clear
            )
        }
    }

    private func commonTopicsItems(commonTopics: [CommonTopic]) -> some View {
        VStack(spacing: 4) {
            ForEach(commonTopics, id: \.self) { item in
                hSection {
                    hRow {
                        hText(item.title)
                        Spacer()
                    }
                    .withChevronAccessory
                }
                .withoutHorizontalPadding
                .hSectionMinimumPadding
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
            ClaimsQuestions.q1,
            InsuranceQuestions.q5,
            PaymentsQuestions.q1,
            InsuranceQuestions.q3,
            InsuranceQuestions.q1,
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
                                    CoverageQuestions.q16,
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
            ),
            style: .modally(presentationStyle: .overFullScreen),
            options: [.largeNavigationBar, .blurredBackground]
        ) { action in
            if case let .goToQuickAction(quickAction) = action {
                if quickAction != .changeBank() {
                    DismissJourney()
                }
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

    return HelpCenterStartView(
        helpCenterModel:
            .init(
                title: L10n.hcHomeViewQuestion,
                description:
                    L10n.hcHomeViewAnswer,
                commonTopics: [
                    .init(
                        title: "Payments",
                        type: .payments,
                        commonQuestions: commonQuestions,
                        allQuestions: []
                    ),
                    .init(
                        title: "Claims",
                        type: .claims,
                        commonQuestions: commonQuestions,
                        allQuestions: []
                    ),
                    .init(
                        title: "My insurance",
                        type: .myInsurance,
                        commonQuestions: commonQuestions,
                        allQuestions: []
                    ),
                ],
                commonQuestions: commonQuestions
            )
    )
}
