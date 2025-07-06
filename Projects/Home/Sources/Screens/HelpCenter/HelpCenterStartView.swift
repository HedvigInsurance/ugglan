import Combine
import Contracts
import PresentableStore
import SwiftUI
@_spi(Advanced) import SwiftUIIntrospect
import hCore
import hCoreUI

public struct HelpCenterStartView: View {
    @StateObject var vm = HelpCenterStartViewModel()
    @PresentableStore var store: HomeStore
    let onQuickAction: (QuickAction) -> Void
    @EnvironmentObject var router: Router

    public init(
        onQuickAction: @escaping (QuickAction) -> Void
    ) {
        self.onQuickAction = onQuickAction
    }

    public var body: some View {
        hForm {
            VStack(spacing: 0) {
                hSection {
                    VStack(alignment: .leading, spacing: 40) {
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
                            HStack {
                                Spacer()
                                hCoreUIAssets.bigPillowBlack.view
                                    .resizable()
                                    .frame(width: 160, height: 160)
                                    .padding(.bottom, 26)
                                    .padding(.top, 39)
                                Spacer()
                            }
                            .accessibilityHidden(true)
                            VStack(alignment: .leading, spacing: .padding8) {
                                hText(L10n.hcHomeViewQuestion)
                                hText(L10n.hcHomeViewAnswer)
                                    .foregroundColor(hTextColor.Opaque.secondary)
                            }
                            .accessibilityElement(children: .combine)
                            displayQuickActions(from: vm.quickActions)
                            displayTopics()
                            if let helpCenterModel = vm.helpCenterModel {
                                QuestionsItems(
                                    questions: helpCenterModel.commonQuestions,
                                    questionType: .commonQuestions,
                                    source: .homeView
                                )
                            }
                        }
                    }
                }
                .sectionContainerStyle(.transparent)
                if !vm.searchInProgress {
                    SupportView(router: router)
                        .padding(.top, .padding40)
                }
            }
        }
        .hFormBottomBackgroundColor(
            vm.searchInProgress
                ? .transparent : .gradient(from: hBackgroundColor.primary, to: hSurfaceColor.Opaque.primary)
        )
        .edgesIgnoringSafeArea(.bottom)
        .dismissKeyboard()
        .introspect(.viewController, on: .iOS(.v13...)) { [weak vm] vc in
            guard let vm else { return }

            if !vm.didSetInitialSearchAppearance {
                vc.navigationItem.hidesSearchBarWhenScrolling = false
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [weak vc] in
                    vc?.navigationItem.hidesSearchBarWhenScrolling = true
                }
                vm.didSetInitialSearchAppearance = true
            }

            vc.navigationItem.searchController = vm.searchController
            vc.definesPresentationContext = true
            vm.updateColors()
        }
    }

    @ViewBuilder
    func displayQuickActions(from quickActions: [QuickAction]) -> some View {
        if !quickActions.isEmpty {
            VStack(alignment: .leading, spacing: .padding4) {
                HelpCenterPill(title: L10n.hcQuickActionsTitle, color: .green)
                    .padding(.bottom, .padding4)

                ForEach(quickActions, id: \.displayTitle) { quickAction in
                    QuickActionView(quickAction: quickAction) {
                        onQuickAction(quickAction)
                    }
                }
            }
        }
    }

    @ViewBuilder
    private func displayTopics() -> some View {
        if let helpCenterModel = vm.helpCenterModel {
            VStack(alignment: .leading, spacing: .padding8) {
                HelpCenterPill(title: L10n.hcCommonTopicsTitle, color: .yellow)
                topicsItems(topics: helpCenterModel.topics)
            }
        }
    }

    private func topicsItems(topics: [FaqTopic]) -> some View {
        VStack(spacing: .padding4) {
            ForEach(topics, id: \.self) { item in
                hSection {
                    hRow {
                        hText(item.title)
                        Spacer()
                    }
                    .withChevronAccessory
                    .onTap { [weak router] in
                        router?.push(item)
                    }
                }
                .hWithoutHorizontalPadding([.section])
                .sectionContainerStyle(.opaque)
            }
        }
    }
}

@MainActor
class HelpCenterStartViewModel: NSObject, ObservableObject {
    @PresentableStore var store: HomeStore
    @Published var helpCenterModel: HelpCenterFAQModel?
    var didSetInitialSearchAppearance = false
    @Published var quickActions: [QuickAction] = []
    @Inject var homeClient: HomeClient

    //search part
    @Published var focusState: Bool? = false
    @Published var searchResultsQuestions: [FAQModel] = []
    @Published var searchResultsQuickActions: [QuickAction] = []
    @Published var searchInProgress = false
    private var allQuestions: [FAQModel] = []
    private var cancellables: Set<AnyCancellable> = []
    lazy var searchController: UISearchController = {
        let searchController = UISearchController(searchResultsController: nil)
        searchController.delegate = self
        searchController.searchResultsUpdater = self
        searchController.searchBar.placeholder = L10n.searchPlaceholder
        searchController.obscuresBackgroundDuringPresentation = false
        return searchController
    }()

    override init() {
        super.init()
        let store: HomeStore = globalPresentableStoreContainer.get()
        store.stateSignal
            .map({ $0.quickActions })
            .receive(on: RunLoop.main)
            .removeDuplicates()
            .sink { [weak self] quickActions in
                self?.quickActions = quickActions
            }
            .store(in: &cancellables)
        quickActions = store.state.quickActions
        store.stateSignal
            .map({ $0.helpCenterFAQModel })
            .receive(on: RunLoop.main)
            .removeDuplicates()
            .sink { [weak self, weak store] helpCenterFaqModel in
                self?.helpCenterModel = helpCenterFaqModel
                self?.allQuestions = store?.state.getAllFAQ() ?? []
            }
            .store(in: &cancellables)
        helpCenterModel = store.state.helpCenterFAQModel
        allQuestions = store.state.getAllFAQ() ?? []
        store.send(.fetchFAQ)
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

    private func searchInQuestionsByQuery(query: String) -> [FAQModel] {
        allQuestions.filter {
            $0.answer.lowercased().contains(query) || $0.question.lowercased().contains(query)
        }
    }

    private func searchInQuickActionsByQuery(query: String) -> [QuickAction] {
        let query = query.lowercased()
        return quickActions.filter {
            $0.displayTitle.lowercased().contains(query) || $0.displaySubtitle.lowercased().contains(query)
        }
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
        let hColor = hTextColor.Opaque.primary
        let color = UIColor(
            light: hColor.colorFor(.light, .base).color.uiColor(),
            dark: hColor.colorFor(.dark, .base).color.uiColor()
        )
        button?.setTitleColor(color, for: .normal)
    }

}

#Preview {
    return HelpCenterStartView(
        onQuickAction: { _ in

        }
    )
}
