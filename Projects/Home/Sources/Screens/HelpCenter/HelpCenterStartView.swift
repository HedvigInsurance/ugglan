import Combine
import Contracts
import PresentableStore
import SwiftUI
@_spi(Advanced) import SwiftUIIntrospect
import hCore
import hCoreUI
import hGraphQL

public struct HelpCenterStartView: View {
    @StateObject var vm = HelpCenterStartViewModel(helpCenterModel: .getDefault())
    @PresentableStore var store: HomeStore
    let onQuickAction: (QuickAction) -> Void
    @EnvironmentObject var router: Router

    public init(
        onQuickAction: @escaping (QuickAction) -> Void
    ) {
        self.onQuickAction = onQuickAction
    }

    public var body: some View {
        hUpdatedForm {
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
                                Image(uiImage: hCoreUIAssets.bigPillowBlack.image)
                                    .resizable()
                                    .frame(width: 160, height: 160)
                                    .padding(.bottom, 26)
                                    .padding(.top, 39)
                                Spacer()
                            }
                            .accessibilityHidden(true)

                            VStack(alignment: .leading, spacing: .padding8) {
                                hText(vm.helpCenterModel.title)
                                hText(vm.helpCenterModel.description)
                                    .foregroundColor(hTextColor.Opaque.secondary)
                            }
                            .accessibilityElement(children: .combine)
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
            if !(vm?.didSetInitialSearchAppearance ?? false) {
                vc.navigationItem.hidesSearchBarWhenScrolling = false
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [weak vc] in
                    vc?.navigationItem.hidesSearchBarWhenScrolling = true

                }
                vm?.didSetInitialSearchAppearance = true
            }
        }
        .introspect(.viewController, on: .iOS(.v13...)) { vc in
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

    private func displayCommonTopics() -> some View {
        VStack(alignment: .leading, spacing: .padding8) {
            HelpCenterPill(title: L10n.hcCommonTopicsTitle, color: .yellow)

            let commonTopics = vm.helpCenterModel.commonTopics
            commonTopicsItems(commonTopics: commonTopics)
        }
    }

    private func commonTopicsItems(commonTopics: [CommonTopic]) -> some View {
        VStack(spacing: .padding4) {
            ForEach(commonTopics, id: \.self) { item in
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
                .hSectionWithoutHorizontalPadding
                .sectionContainerStyle(.opaque)
            }
        }
    }
}

@MainActor
class HelpCenterStartViewModel: NSObject, ObservableObject {
    let helpCenterModel: HelpCenterModel
    @PresentableStore var store: HomeStore
    var didSetInitialSearchAppearance = false
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

        quickActionCancellable = store.stateSignal
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

extension HelpCenterModel {
    static func getDefault() -> HelpCenterModel {
        let commonQuestions: [Question] = [
            ClaimsQuestions.claimsQuestion1.question,
            InsuranceQuestions.insuranceQuestion5.question,
            PaymentsQuestions.paymentsQuestion1.question,
            InsuranceQuestions.insuranceQuestion3.question,
            InsuranceQuestions.insuranceQuestion1.question,
        ]

        return .init(
            title: L10n.hcHomeViewQuestion,
            description:
                L10n.hcHomeViewAnswer,
            commonTopics: [
                .init(
                    title: L10n.hcPaymentsTitle,
                    commonQuestions: PaymentsQuestions.common().asQuestions(),
                    allQuestions: PaymentsQuestions.others().asQuestions()
                ),
                .init(
                    title: L10n.hcClaimsTitle,
                    commonQuestions: ClaimsQuestions.common().asQuestions(),
                    allQuestions: ClaimsQuestions.others().asQuestions()
                ),
                .init(
                    title: L10n.hcCoverageTitle,
                    commonQuestions: CoverageQuestions.common().asQuestions(),
                    allQuestions: CoverageQuestions.others().asQuestions()
                ),
                .init(
                    title: L10n.hcInsurancesTitle,
                    commonQuestions: InsuranceQuestions.common().asQuestions(),
                    allQuestions: InsuranceQuestions.others().asQuestions()
                ),
                .init(
                    title: L10n.hcGeneralTitle,
                    commonQuestions: OtherQuestions.common().asQuestions(),
                    allQuestions: OtherQuestions.others().asQuestions()
                ),
            ],
            commonQuestions: commonQuestions
        )
    }
}
