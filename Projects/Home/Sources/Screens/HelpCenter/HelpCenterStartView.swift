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
                    Image(uiImage: hCoreUIAssets.bigPillowHome.image)
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
                    QuestionsItems(questions: helpCenterModel.commonQuestions, isCommonQuestions: true)
                }
            }
            .sectionContainerStyle(.transparent)
        }
    }

    private func displayQuickActions() -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HelpCenterPill(title: "Quick actions", color: .green)

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
            HelpCenterPill(title: "Common topics", color: .yellow)

            let commonTopics = helpCenterModel.commonTopics
            commonTopicsItems(commonTopics: commonTopics)
        }
    }

    private func quickActionPill(quickAction: QuickAction) -> some View {
        HStack(alignment: .center) {
            hText(quickAction.title)
                .frame(maxWidth: .infinity, alignment: .center)
        }
        .padding(.vertical, 16)
        .background(
            Squircle.default()
                .fill(hGrayscaleTranslucent.greyScaleTranslucent100)
        )
        .onTapGesture {
            store.send(.goToDeepLink(quickAction.deepLink))
        }
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
                question: "When do you charge for my insurance?",
                answer: ""
            ),
            .init(
                question: "When do you charge for my insurance?",
                answer: ""
            ),
            .init(
                question: "How do I make a claim?",
                answer: ""
            ),
            .init(
                question: "How can I view my payment history?",
                answer: ""
            ),
            .init(
                question: "What should I do if my payment fails?",
                answer: ""
            ),
        ]

        return HostingJourney(
            HomeStore.self,
            rootView: HelpCenterStartView(
                helpCenterModel:
                    .init(
                        title: "Need help?",
                        description:
                            "There is a lot you can do directly here in the app. Select a topic to resolve your issue quickly, or chat with us if you need.",
                        quickActions: [
                            .init(title: "Change bank", deepLink: .contract),
                            .init(title: "Update address", deepLink: .contract),
                            .init(title: "Edit co-insured", deepLink: .contract),
                            .init(title: "Travel certificate", deepLink: .contract),
                        ],
                        commonTopics: [
                            .init(
                                title: "Payments",
                                commonQuestions: commonQuestions,
                                allQuestions: commonQuestions
                            ),
                            .init(
                                title: "Claims",
                                commonQuestions: commonQuestions,
                                allQuestions: commonQuestions
                            ),
                            .init(
                                title: "My insurance",
                                commonQuestions: commonQuestions,
                                allQuestions: commonQuestions
                            ),
                            .init(
                                title: "Co-insured",
                                commonQuestions: commonQuestions,
                                allQuestions: commonQuestions
                            ),
                            .init(
                                title: "FirstVet",
                                commonQuestions: commonQuestions,
                                allQuestions: commonQuestions
                            ),
                            .init(
                                title: "Campaigns",
                                commonQuestions: commonQuestions,
                                allQuestions: commonQuestions
                            ),

                        ],
                        commonQuestions: commonQuestions
                    )
            ),
            style: .detented(.scrollViewContentSize),
            options: [.largeNavigationBar, .blurredBackground]
        ) { action in
            if case .goToDeepLink = action {
                DismissJourney()
            } else if case let .openHelpCenterTopicView(topic) = action {
                HelpCenterTopicView.journey(commonTopic: topic)
            }
        }
        .configureTitle("Help Center")
        .withJourneyDismissButton
    }
}

#Preview{

    let commonQuestions: [Question] = [
        .init(
            question: "When do you charge for my insurance?",
            answer: ""
        ),
        .init(
            question: "When do you charge for my insurance?",
            answer: ""
        ),
        .init(
            question: "How do I make a claim?",
            answer: ""
        ),
        .init(
            question: "How can I view my payment history?",
            answer: ""
        ),
        .init(
            question: "What should I do if my payment fails?",
            answer: ""
        ),
    ]

    return HelpCenterStartView(
        helpCenterModel:
            .init(
                title: "Need help?",
                description:
                    "There is a lot you can do directly here in the app. Select a topic to resolve your issue quickly, or chat with us if you need.",
                quickActions: [
                    .init(title: "Change bank", deepLink: .payments),
                    .init(title: "Update address", deepLink: .contract),
                    .init(title: "Edit co-insured", deepLink: .contract),
                    .init(title: "Travel certificate", deepLink: .contract),
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
