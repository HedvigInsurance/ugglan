import Contracts
import Presentation
import SwiftUI
import TravelCertificate
import hCore
import hCoreUI
import hGraphQL

public struct HelpCenterStartView: View {
    @ObservedObject var vm: HelpCenterStartViewModel
    @PresentableStore var store: HomeStore
    public init(
        helpCenterModel: HelpCenterModel
    ) {
        self.vm = .init(helpCenterModel: helpCenterModel)
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
                            hText(vm.helpCenterModel.title)
                            hText(vm.helpCenterModel.description)
                                .foregroundColor(hTextColor.secondary)
                        }

                        hFloatingTextField(
                            masking: Masking(type: .none),
                            value: $vm.inputText,
                            equals: $vm.focusState,
                            focusValue: true,
                            placeholder: "Search"
                        )
                        .hFieldSize(.small)
                        .hFieldAttachToLeft {
                            hCoreUIAssets.search.view
                                .foregroundColor(hTextColor.secondary)
                        }
                        if let showSearchResults = vm.showSearchResults {
                            if showSearchResults {
                                if let searchResultsQuickActions =
                                    vm.searchResultsQuickActions {
                                    displayResultsInQuickActions(let: searchResultsQuickActions)
                                }
                                if let searchResultsQuestions = vm.searchResultsQuestions {
                                    SearchResultsInQuestions(
                                        questions: searchResultsQuestions,
                                        questionType: .commonQuestions,
                                        source: .homeView
                                    )
                                }
                            }
                            else {
                                NothingFound()
                            }
                        } else {
                            displayQuickActions()
                            displayCommonTopics()
                            QuestionsItems(
                                questions: vm.helpCenterModel.commonQuestions,
                                questionType: .commonQuestions,
                                source: .homeView
                            )
                        }
                    }
                }
                .sectionContainerStyle(.transparent)
                SupportView(topic: nil)
                    .padding(.top, 40)
            }
        }
        .hFormBottomBackgroundColor(.gradient(from: hBackgroundColor.primary, to: hFillColor.opaqueOne))
        .hFormObserveKeyboard
        .edgesIgnoringSafeArea(.bottom)
        .dismissKeyboard()
        .onChange(of: vm.inputText) { _ in
            vm.startSearch()
        }
    }

    @ViewBuilder
    private func displayQuickActions() -> some View {
        if !vm.store.state.quickActions.isEmpty {
            VStack(alignment: .leading, spacing: 4) {

                HelpCenterPill(title: L10n.hcQuickActionsTitle, color: .green)
                    .padding(.bottom, 4)

                ForEach(vm.store.state.quickActions, id: \.displayTitle) { quickAction in
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
                            Task {
                                vm.store.send(.goToQuickAction(quickAction))
                            }
                        }
                    }
                    .withoutHorizontalPadding
                    .sectionContainerStyle(.opaque)
                }
            }
        }
    }
    
    @ViewBuilder
    private func displayResultsInQuickActions(
        `let` quickActions: [QuickAction]
    ) -> some View {
        if !quickActions.isEmpty {
            VStack(alignment: .leading, spacing: 4) {

                HelpCenterPill(title: L10n.hcQuickActionsTitle, color: .green)
                    .padding(.bottom, 4)

                ForEach(quickActions, id: \.displayTitle) { quickAction in
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
                            Task {
                                vm.store.send(.goToQuickAction(quickAction))
                            }
                        }
                    }
                    .withoutHorizontalPadding
                    .sectionContainerStyle(.opaque)
                }
            }
        }
    }

    private func displayCommonTopics() -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HelpCenterPill(title: L10n.hcCommonTopicsTitle, color: .yellow)

            let commonTopics = vm.helpCenterModel.commonTopics
            commonTopicsItems(commonTopics: commonTopics)
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
                    .onTap {
                        vm.store.send(.openHelpCenterTopicView(commonTopic: item))
                    }
                }
                .withoutHorizontalPadding
                .hSectionMinimumPadding
                .sectionContainerStyle(.opaque)
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
            if case .openFreeTextChat = action {
                DismissJourney()
            } else if case let .openHelpCenterTopicView(topic) = action {
                HelpCenterTopicView.journey(commonTopic: topic)
            } else if case let .openHelpCenterQuestionView(question) = action {
                HelpCenterQuestionView.journey(question: question, title: nil)
            } else if case .dismissHelpCenter = action {
                DismissJourney()
            }
        }
        .configureTitle(L10n.hcTitle)
        .withJourneyDismissButton
    }
}

class HelpCenterStartViewModel: ObservableObject {
    var helpCenterModel: HelpCenterModel
    @PresentableStore var store: HomeStore
    @Published var inputText = ""
    @Published var focusState: Bool? = false
    @Published var searchResultsQuestions: [Question]?
    @Published var searchResultsQuickActions: [QuickAction]?
    @Published var showSearchResults: Bool?  = nil
    let allQuestions: [Question]

    init(helpCenterModel: HelpCenterModel) {
        allQuestions = [
            PaymentsQuestions.q1,
            PaymentsQuestions.q2,
            PaymentsQuestions.q3,
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
        self.helpCenterModel = helpCenterModel
    }

    func startSearch() {
        if !inputText.isEmpty {
            let trimmedQuery: String =
                inputText.lowercased().trimmingCharacters(in: .whitespaces)
            let questions = searchInQuestionsByQuery(query: trimmedQuery)
            let actions = searchInQuickActionsByQuery(query: trimmedQuery)
            searchResultsQuestions = questions
            searchResultsQuickActions = actions
            showSearchResults = if (questions.isEmpty && actions.isEmpty) {
                false
            } else { true }
        } else {
            searchResultsQuestions = nil
            searchResultsQuickActions = nil
            showSearchResults = nil
        }
    }

    private func searchInQuestionsByQuery(query: String) -> [Question] {
        var results: [Question] = [Question]()
        allQuestions.forEach { question in
            if question.answer.lowercased().contains(query) || question.question.lowercased().contains(query) {
                results.append(question)
            }
        }
        return results
    }

    private func searchInQuickActionsByQuery(query: String) -> [QuickAction] {
        var results: [QuickAction] = [QuickAction]()
        store.state.quickActions.forEach { quickAction in
            if quickAction.displayTitle.lowercased().contains(query)
                || quickAction.displaySubtitle.lowercased().contains(query)
            {
                results.append(quickAction)
            }
        }
        return results
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
