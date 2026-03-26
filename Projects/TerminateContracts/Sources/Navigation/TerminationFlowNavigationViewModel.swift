import ChangeTier
import Combine
import Environment
import SwiftUI
import hCore
import hCoreUI

// MARK: - Helper Classes

@MainActor
class TerminationRedirectHandler {
    weak var viewModel: TerminationFlowNavigationViewModel?

    func handle(_ suggestion: TerminationSuggestion) async {
        switch suggestion.type {
        case .updateAddress:
            handleUpdateAddress()
        case .upgradeCoverage:
            await handleChangeTier(source: .betterCoverage)
        case .downgradePrice:
            await handleChangeTier(source: .betterPrice)
        case .redirect:
            handleRedirect(suggestion)
        default:
            break
        }
    }

    private func handleUpdateAddress() {
        viewModel?.router.dismiss()
        var url = Environment.current.deepLinkUrls.last!
        url.appendPathComponent(DeepLink.moveContract.rawValue)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            NotificationCenter.default.post(name: .openDeepLink, object: url)
        }
    }

    private func handleRedirect(_ suggestion: TerminationSuggestion) {
        guard let urlString = suggestion.url, let url = URL(string: urlString) else { return }
        viewModel?.router.dismiss()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            NotificationCenter.default.post(name: .openDeepLink, object: url)
        }
    }

    private func handleChangeTier(source: ChangeTierSource) async {
        guard let viewModel = viewModel,
            let contractId = viewModel.config?.contractId
        else { return }

        let input = ChangeTierInputData(source: source, contractId: contractId)

        do {
            withAnimation {
                viewModel.redirectActionLoadingState = .loading
            }
            let newInput = try await ChangeTierNavigationViewModel.getTiers(input: input)
            withAnimation {
                viewModel.redirectActionLoadingState = .success
            }

            switch newInput {
            case let .changeTierIntentModel(intent):
                DispatchQueue.main.async { [weak viewModel] in
                    viewModel?.terminateInsuranceViewModel?.changeTierInput = .existingIntent(
                        intent: intent,
                        onSelect: nil
                    )
                    viewModel?.router.dismiss()
                }
            case .emptyTier:
                viewModel.infoText = L10n.terminationNoTierQuotesSubtitle
            case let .deflection(deflection):
                viewModel.infoText = deflection.message
            }
        } catch {
            withAnimation {
                viewModel.redirectActionLoadingState = .success
            }
            Toasts.shared.displayToastBar(
                toast: .init(type: .error, text: error.localizedDescription)
            )
        }
    }
}

// MARK: - View Model

@MainActor
public class TerminationFlowNavigationViewModel: ObservableObject, @preconcurrency Equatable, Identifiable {
    public static func == (lhs: TerminationFlowNavigationViewModel, rhs: TerminationFlowNavigationViewModel) -> Bool {
        lhs.id == rhs.id
    }

    public let id = UUID().uuidString

    // MARK: - Helpers
    private let redirectHandler = TerminationRedirectHandler()
    private let terminateContractsService = TerminateContractsService()

    // MARK: - UI State
    @Published var isDatePickerPresented = false
    @Published var isConfirmTerminationPresented = false
    @Published var isProcessingPresented = false
    @Published var infoText: String?
    @Published var redirectActionLoadingState: ProcessingState = .success
    @Published var notification: TerminationNotification?
    @Published var confirmTerminationState: ProcessingState = .loading

    // MARK: - Navigation
    let router = Router()
    let initialStep: TerminationFlowActions

    // MARK: - Configuration
    var configs: [TerminationConfirmConfig] = []
    @Published var config: TerminationConfirmConfig?
    @Published var hasSelectInsuranceStep: Bool = false
    weak var terminateInsuranceViewModel: TerminateInsuranceViewModel?

    // MARK: - Survey State
    @Published var surveyData: TerminationSurveyData?
    @Published var selectedOptionId: String?
    @Published var selectedComment: String?
    @Published var selectedDate: Date?

    // MARK: - Progress
    @Published var progress: Float? = 0
    private var routeCountCancellable: AnyCancellable?
    private var hideProgress = false

    var extraCoverage: [ExtraCoverageItem] {
        guard let action = surveyData?.action else { return [] }
        switch action {
        case let .terminateWithDate(_, _, extraCoverage):
            return extraCoverage
        case let .deleteInsurance(extraCoverage):
            return extraCoverage
        }
    }

    var isDeletion: Bool {
        guard let action = surveyData?.action else { return false }
        if case .deleteInsurance = action { return true }
        return false
    }

    // MARK: - Initialization

    public init(
        configs: [TerminationConfirmConfig],
        terminateInsuranceViewModel: TerminateInsuranceViewModel?
    ) {
        self.terminateInsuranceViewModel = terminateInsuranceViewModel
        self.configs = configs

        if configs.count == 1, let singleConfig = configs.first {
            self.config = singleConfig
            self.hasSelectInsuranceStep = false
            self.initialStep = .router(action: .survey)
            self.redirectHandler.viewModel = self
            fetchSurvey(for: singleConfig)
        } else {
            self.hasSelectInsuranceStep = true
            self.initialStep = .router(action: .selectInsurance(configs: configs))
            self.redirectHandler.viewModel = self
        }

        routeCountCancellable = router.$count
            .receive(on: RunLoop.main)
            .sink { [weak self] _ in
                self?.updateProgress()
            }
    }

    // MARK: - Survey

    func fetchSurvey(for config: TerminationConfirmConfig) {
        self.config = config
        Task { [weak self] in
            guard let self else { return }
            do {
                let data = try await terminateContractsService.getTerminationSurvey(contractId: config.contractId)
                self.surveyData = data
                if hasSelectInsuranceStep {
                    router.push(TerminationFlowRouterActions.survey)
                }
            } catch {
                router.push(TerminationFlowFinalRouterActions.failure(message: error.localizedDescription))
            }
        }
    }

    // MARK: - Survey Completion

    func proceedAfterSurvey(optionId: String, comment: String?) {
        selectedOptionId = optionId
        selectedComment = comment
        guard let action = surveyData?.action else { return }

        switch action {
        case .terminateWithDate:
            router.push(TerminationFlowRouterActions.datePicker)
        case .deleteInsurance:
            fetchNotification(for: Date())
            router.push(TerminationFlowRouterActions.confirmation)
        }
    }

    func handleSuggestion(_ suggestion: TerminationSuggestion) {
        if suggestion.isDeflect, let content = DeflectScreenContent.from(suggestionType: suggestion.type) {
            hideProgress = true
            updateProgress()
            router.push(TerminationFlowRouterActions.deflect(content: content))
        } else if !suggestion.isDeflect {
            Task {
                await redirectHandler.handle(suggestion)
            }
        }
    }

    // MARK: - Termination Submission

    func submitTermination() {
        guard let contractId = config?.contractId,
            let optionId = selectedOptionId
        else { return }

        Task { [weak self] in
            guard let self else { return }
            isProcessingPresented = true
            withAnimation {
                confirmTerminationState = .loading
            }

            do {
                let result: TerminationContractResult
                if isDeletion {
                    result = try await terminateContractsService.deleteContract(
                        contractId: contractId,
                        surveyOptionId: optionId,
                        comment: selectedComment
                    )
                } else {
                    result = try await terminateContractsService.terminateContract(
                        contractId: contractId,
                        terminationDate: selectedDate?.localDateString ?? "",
                        surveyOptionId: optionId,
                        comment: selectedComment
                    )
                }

                withAnimation {
                    confirmTerminationState = .success
                }
                isProcessingPresented = false

                switch result {
                case .success:
                    hideProgress = true
                    router.push(TerminationFlowFinalRouterActions.success)
                case let .userError(message):
                    hideProgress = true
                    router.push(TerminationFlowFinalRouterActions.failure(message: message))
                }
            } catch {
                isProcessingPresented = false
                withAnimation {
                    confirmTerminationState = .error(errorMessage: error.localizedDescription)
                }
            }
        }
    }

    // MARK: - Notification

    var fetchNotificationTask: Task<Void, Never>?

    func fetchNotification(for date: Date?) {
        fetchNotificationTask?.cancel()
        fetchNotificationTask = Task { [weak self] in
            guard let self, let contractId = config?.contractId, let date else { return }
            do {
                try Task.checkCancellation()
                let data = try await terminateContractsService.getNotification(
                    contractId: contractId,
                    date: date
                )
                try Task.checkCancellation()
                notification = data
            } catch {
                do {
                    try await Task.sleep(seconds: 1)
                    try Task.checkCancellation()
                    fetchNotification(for: date)
                } catch {}
            }
        }
    }

    // MARK: - Progress Calculation

    private var totalSteps: Int {
        hasSelectInsuranceStep ? 4 : 3
    }

    private func updateProgress() {
        if hideProgress {
            progress = nil
        } else {
            progress = min(Float(router.count) / Float(totalSteps), 1.0)
        }
    }
}

// MARK: - Navigation View

struct TerminationFlowNavigation: View {
    @ObservedObject private var vm: TerminationFlowNavigationViewModel
    let isFlowPresented: (DismissTerminationAction) -> Void

    init(
        vm: TerminationFlowNavigationViewModel,
        isFlowPresented: @escaping (DismissTerminationAction) -> Void = { _ in }
    ) {
        self.isFlowPresented = isFlowPresented
        self.vm = vm
    }

    var body: some View {
        RouterHost(
            router: vm.router,
            options: [
                .navigationType(type: .withProgress),
                .extendedNavigationWidth,
            ],
            tracking: vm.initialStep
        ) {
            getView(for: vm.initialStep)
                .addNavigationInfoButton(
                    title: L10n.terminationFlowCancelInfoTitle,
                    description: L10n.terminationFlowCancelInfoText
                )
                .routerDestination(for: [TerminationSurveyOption].self) { options in
                    TerminationSurveyScreen(vm: .init(options: options, subtitleType: .generic))
                }
                .routerDestination(for: TerminationFlowRouterActions.self) { action in
                    Group {
                        switch action {
                        case .survey:
                            openSurveyScreen()
                        case .datePicker:
                            openSetTerminationDateLandingScreen()
                        case .selectInsurance:
                            openSelectInsuranceScreen()
                        case .confirmation:
                            openTerminationSummaryScreen()
                        case let .deflect(content):
                            openDeflectScreen(content: content)
                        }
                    }
                }
                .routerDestination(
                    for: TerminationFlowFinalRouterActions.self,
                    options: .hidesBackButton
                ) { [weak vm] action in
                    Group {
                        switch action {
                        case .success:
                            openTerminationSuccessScreen(
                                isDeletion: vm?.isDeletion ?? false,
                                terminationDate: vm?.selectedDate?.displayDateDDMMMYYYYFormat ?? ""
                            )
                        case let .failure(message):
                            openTerminationFailScreen(message: message)
                        }
                    }
                }
        }
        .modifier(ProgressBarView(progress: $vm.progress))
        .environmentObject(vm)
        .detent(
            presented: $vm.isDatePickerPresented,
            presentationStyle: .detent(style: [.height])
        ) {
            openSetTerminationDatePickerScreen()
        }
        .detent(
            presented: $vm.isConfirmTerminationPresented,
            presentationStyle: .detent(style: [.height])
        ) {
            openConfirmTerminationScreen()
                .environmentObject(vm)
        }
        .modally(presented: $vm.isProcessingPresented) {
            openProgressScreen()
        }
        .showInfoScreen(text: $vm.infoText, dismissButtonTitle: L10n.embarkGoBackButton)
    }

    @ViewBuilder
    private func getView(for action: TerminationFlowActions) -> some View {
        switch action {
        case let .router(action):
            switch action {
            case .survey:
                openSurveyScreen()
            case .datePicker:
                openSetTerminationDateLandingScreen()
            case .selectInsurance:
                openSelectInsuranceScreen()
            case .confirmation:
                openTerminationSummaryScreen()
            case let .deflect(content):
                openDeflectScreen(content: content)
            }
        case let .final(action):
            switch action {
            case .success:
                openTerminationSuccessScreen(
                    isDeletion: vm.isDeletion,
                    terminationDate: vm.selectedDate?.displayDateDDMMMYYYYFormat ?? ""
                )
            case let .failure(message):
                openTerminationFailScreen(message: message)
            }
        }
    }

    private func openSurveyScreen() -> some View {
        TerminationSurveyScreen(
            vm: .init(
                options: vm.surveyData?.options ?? [],
                subtitleType: .default
            )
        )
        .withDismissButton()
    }

    private func openSetTerminationDateLandingScreen() -> some View {
        SetTerminationDateLandingScreen(terminationNavigationVm: vm)
            .withDismissButton()
    }

    private func openSelectInsuranceScreen() -> some View {
        TerminationSelectInsuranceScreen(vm: vm)
    }

    private func openTerminationSummaryScreen() -> some View {
        TerminationSummaryScreen()
            .withDismissButton()
    }

    private func openDeflectScreen(content: DeflectScreenContent) -> some View {
        TerminationDeflectScreen(content: content)
            .withDismissButton()
    }

    private func openConfirmTerminationScreen() -> some View {
        ConfirmTerminationScreen()
            .withDismissButton()
            .embededInNavigation(
                options: .navigationBarHidden,
                tracking: TerminationFlowDetentActions.confirmTermination
            )
    }

    private func openSetTerminationDatePickerScreen() -> some View {
        SetTerminationDate(
            terminationNavigationVm: vm
        )
        .navigationTitle(L10n.setTerminationDateText)
        .embededInNavigation(
            options: [.navigationType(type: .large)],
            tracking: TerminationFlowDetentActions.terminationDate
        )
    }

    private func openProgressScreen() -> some View {
        TerminationProcessingScreen(terminationNavigationVm: vm)
    }

    private func openTerminationSuccessScreen(
        isDeletion: Bool,
        terminationDate: String
    ) -> some View {
        SuccessScreen(
            successViewTitle: L10n.terminationFlowSuccessTitle,
            successViewBody: isDeletion
                ? L10n.terminateContractTerminationComplete
                : L10n.terminationFlowSuccessSubtitleWithDate(terminationDate),

        )
        .hStateViewButtonConfig(
            .init(
                actionButton: nil,
                actionButtonAttachedToBottom: nil,
                dismissButton: .init(buttonAction: { [weak vm] in
                    vm?.router.dismiss()
                    isFlowPresented(.done)
                })
            )
        )
    }

    private func openTerminationFailScreen(message: String = "") -> some View {
        GenericErrorView(
            title: L10n.terminationNotSuccessfulTitle,
            description: message.isEmpty ? L10n.somethingWentWrong : message,
            formPosition: .center
        )
        .hStateViewButtonConfig(
            .init(
                actionButton: .init(
                    buttonTitle: L10n.openChat,
                    buttonAction: {
                        isFlowPresented(.chat)
                    }
                ),
                dismissButton: .init(
                    buttonTitle: L10n.alertCancel,
                    buttonAction: { [weak vm] in
                        vm?.router.dismiss()
                    }
                )
            )
        )
    }
}

// MARK: - Router Action Enums

public enum TerminationFlowRouterActions: Hashable {
    case selectInsurance(configs: [TerminationConfirmConfig])
    case survey
    case datePicker
    case confirmation
    case deflect(content: DeflectScreenContent)
}

extension TerminationFlowRouterActions: TrackingViewNameProtocol {
    public var nameForTracking: String {
        switch self {
        case .selectInsurance:
            return "Select Insurance"
        case .survey:
            return .init(describing: TerminationSurveyScreen.self)
        case .datePicker:
            return .init(describing: SetTerminationDateLandingScreen.self)
        case .confirmation:
            return .init(describing: TerminationSummaryScreen.self)
        case .deflect:
            return "TerminationDeflectScreen"
        }
    }
}

public enum TerminationFlowFinalRouterActions: Hashable {
    case success
    case failure(message: String)
}

extension TerminationFlowFinalRouterActions: TrackingViewNameProtocol {
    public var nameForTracking: String {
        switch self {
        case .success:
            return "TerminationSuccessScreen"
        case .failure:
            return "TerminationFailScreen"
        }
    }
}

public enum TerminationFlowActions: Hashable {
    case router(action: TerminationFlowRouterActions)
    case final(action: TerminationFlowFinalRouterActions)
}

extension TerminationFlowActions: TrackingViewNameProtocol {
    public var nameForTracking: String {
        switch self {
        case let .router(action):
            return action.nameForTracking
        case let .final(action):
            return action.nameForTracking
        }
    }
}

extension [TerminationSurveyOption]: @retroactive TrackingViewNameProtocol {
    public var nameForTracking: String {
        "TerminationSurveySubOptions"
    }
}

enum TerminationFlowDetentActions: Hashable, TrackingViewNameProtocol {
    var nameForTracking: String {
        switch self {
        case .terminationDate:
            return .init(describing: SetTerminationDate.self)
        case .confirmTermination:
            return .init(describing: ConfirmTerminationScreen.self)
        }
    }

    case terminationDate
    case confirmTermination
}

public enum DismissTerminationAction {
    case done
    case chat
    case openFeedback(url: URL)
    case changeTierFoundBetterPriceStarted
    case changeTierMissingCoverageAndTermsStarted
}
