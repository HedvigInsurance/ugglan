import Combine
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
    @State var vc: UIViewController?

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
                        if vm.searchInProgress {
                            VStack(spacing: 40) {
                                displayQuickActions(from: vm.searchResultsQuickActions)

                                if !vm.searchResultsQuestions.isEmpty {
                                    QuestionsItems(
                                        questions: vm.searchResultsQuestions,
                                        questionType: .searchQuestions,
                                        source: .homeView
                                    )
                                }
                            }
                            .padding(.top, 20)
                        } else {
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
                            displayQuickActions(from: vm.quickActions)
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
                if !vm.searchInProgress {
                    SupportView(topic: nil)
                        .padding(.top, 40)
                }
            }
        }
        .hFormBottomBackgroundColor(
            vm.searchInProgress ? .transparent : .gradient(from: hBackgroundColor.primary, to: hFillColor.opaqueOne)
        )
        .hFormObserveKeyboard
        .edgesIgnoringSafeArea(.bottom)
        .dismissKeyboard()
        .introspectViewController(customize: { vc in
            vc.navigationItem.hidesSearchBarWhenScrolling = false
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [weak vc] in
                vc?.navigationItem.hidesSearchBarWhenScrolling = true

            }
        })
        .introspectViewController { vc in
            vc.navigationItem.searchController = vm.searchController
            vc.definesPresentationContext = true
            vm.updateColors()
        }
    }

    @ViewBuilder
    func displayQuickActions(from quickActions: [QuickAction]) -> some View {
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
            ClaimsQuestions.q1.question,
            InsuranceQuestions.q5.question,
            PaymentsQuestions.q1.question,
            InsuranceQuestions.q3.question,
            InsuranceQuestions.q1.question,
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
                                commonQuestions: PaymentsQuestions.common().asQuestions(),
                                allQuestions: PaymentsQuestions.others().asQuestions()
                            ),
                            .init(
                                title: L10n.hcClaimsTitle,
                                type: .claims,
                                commonQuestions: ClaimsQuestions.common().asQuestions(),
                                allQuestions: ClaimsQuestions.others().asQuestions()
                            ),
                            .init(
                                title: L10n.hcCoverageTitle,
                                type: .coverage,
                                commonQuestions: CoverageQuestions.common().asQuestions(),
                                allQuestions: CoverageQuestions.others().asQuestions()
                            ),
                            .init(
                                title: L10n.hcInsurancesTitle,
                                type: .myInsurance,
                                commonQuestions: InsuranceQuestions.common().asQuestions(),
                                allQuestions: InsuranceQuestions.others().asQuestions()
                            ),
                            .init(
                                title: L10n.hcGeneralTitle,
                                type: nil,
                                commonQuestions: OtherQuestions.common().asQuestions(),
                                allQuestions: OtherQuestions.others().asQuestions()
                            ),
                        ],
                        commonQuestions: commonQuestions
                    )

            ),
            style: .modally(presentationStyle: .overFullScreen),
            options: [.defaults]
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

extension HelpCenterStartViewModel: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        withAnimation {
            searchInProgress = searchController.isActive
            startSearch(for: searchController.searchBar.text ?? "")
        }
        updateColors()
    }
}

extension HelpCenterStartViewModel: UISearchControllerDelegate {
    func didPresentSearchController(_ searchController: UISearchController) {
        updateColors()
    }

    func willPresentSearchController(_ searchController: UISearchController) {
        updateColors()
    }

    func updateColors() {
        let button = searchController.searchBar.subviews.first?.subviews.last?.subviews.last as? UIButton
        let hColor = hTextColor.primary
        let color = UIColor(
            light: hColor.colorFor(.light, .base).color.uiColor(),
            dark: hColor.colorFor(.dark, .base).color.uiColor()
        )
        button?.setTitleColor(color, for: .normal)
    }

}

class HelpCenterStartViewModel: NSObject, ObservableObject {
    var helpCenterModel: HelpCenterModel
    @PresentableStore var store: HomeStore

    @Published var quickActions: [QuickAction] = []

    //search part
    @Published var focusState: Bool? = false
    @Published var searchResultsQuestions: [Question] = []
    @Published var searchResultsQuickActions: [QuickAction] = []
    @Published var searchInProgress = false
    private let allQuestions: [Question]
    private var quickActionCancellable: AnyCancellable?
    lazy var searchController: UISearchController = {
        let searchController = UISearchController(searchResultsController: nil)
        searchController.delegate = self
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = L10n.searchPlaceholder
        searchController.obscuresBackgroundDuringPresentation = false
        return searchController
    }()

    init(helpCenterModel: HelpCenterModel) {
        allQuestions =
            PaymentsQuestions.all().asQuestions()
            + ClaimsQuestions.all().asQuestions()
            + CoverageQuestions.all().asQuestions()
            + InsuranceQuestions.all().asQuestions()
            + OtherQuestions.all().asQuestions()
        self.helpCenterModel = helpCenterModel
        let store: HomeStore = globalPresentableStoreContainer.get()
        super.init()

        quickActionCancellable = store.stateSignal.plain().publisher
            .map({ $0.quickActions })
            .receive(on: RunLoop.main)
            .removeDuplicates()
            .sink { [weak self] quickActions in
                self?.quickActions = quickActions
            }
        quickActions = store.state.quickActions
    }

    func startSearch(for inputText: String) {
        if !inputText.isEmpty {
            let trimmedQuery: String =
                inputText.lowercased().trimmingCharacters(in: .whitespaces)
            let questions = searchInQuestionsByQuery(query: trimmedQuery)
            let actions = searchInQuickActionsByQuery(query: trimmedQuery)
            searchResultsQuestions = questions
            searchResultsQuickActions = actions
        } else {
            searchResultsQuestions = allQuestions
            searchResultsQuickActions = quickActions
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
        let query = query.lowercased()
        var results: [QuickAction] = [QuickAction]()
        quickActions.forEach { quickAction in
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
