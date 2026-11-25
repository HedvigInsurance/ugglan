import ChangeTierCore
import ChangeTierUI
import Environment
import SwiftUI
import TerminateContractsCore
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

    func handleUpdateAddress() {
        viewModel?.router.dismiss()
        var url = Environment.current.deepLinkUrl
        url.appendPathComponent(DeepLink.moveContract.rawValue)
        url = url.appending(DeeplinkProperty.source.rawValue, value: DeepLink.terminateContract.rawValue)
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
@Observable
class TerminationFlowNavigationViewModel: @MainActor Equatable, @MainActor Identifiable {
    static func == (lhs: TerminationFlowNavigationViewModel, rhs: TerminationFlowNavigationViewModel) -> Bool {
        lhs.id == rhs.id
    }

    let id = UUID().uuidString

    // MARK: - Helpers
    private let redirectHandler = TerminationRedirectHandler()
    private let terminateContractsService = TerminateContractsService()

    // MARK: - UI State
    var isDatePickerPresented = false
    var isConfirmTerminationPresented = false
    var isProcessingPresented = false
    var infoText: String?
    var redirectActionLoadingState: ProcessingState = .success
    var notification: TerminationNotification?
    var confirmTerminationState: ProcessingState = .loading
    var fetchingSurvey: Bool = false

    // MARK: - Navigation
    let router = NavigationRouter()
    let initialStep: TerminationFlowActions

    // MARK: - Configuration
    var config: TerminationConfirmConfig?
    var hasSelectInsuranceStep: Bool = false
    @ObservationIgnored weak var terminateInsuranceViewModel: TerminateInsuranceViewModel?

    // MARK: - Survey State
    var surveyData: TerminationSurveyData?
    var selectedOptionId: String?
    var selectedComment: String?
    var selectedDate: Date?
    var progress: Float? = 0

    // MARK: - Withdrawal State
    /// Set when the member chose to withdraw instead of cancelling: the flow then skips the survey.
    var withdrawal: ContractWithdrawalData?

    var isWithdrawal: Bool {
        withdrawal != nil
    }

    /// The action for the path the member is on: the withdrawal's when withdrawing, otherwise the survey's.
    var action: TerminationAction? {
        withdrawal?.action ?? surveyData?.action
    }

    var extraCoverage: [ExtraCoverageItem] {
        guard let action else { return [] }
        switch action {
        case let .terminateWithDate(_, _, extraCoverage):
            return extraCoverage
        case let .deleteInsurance(extraCoverage):
            return extraCoverage
        }
    }

    var isDeletion: Bool {
        guard let action else { return false }
        if case .deleteInsurance = action { return true }
        return false
    }

    var terminationDateLimits: (min: Date?, max: Date?)? {
        guard case let .terminateWithDate(minDate, maxDate, _) = action else { return nil }
        return (minDate.localDateToDate, maxDate.localDateToDate)
    }

    // MARK: - Initialization

    init(
        configs: [TerminationConfirmConfig],
        terminateInsuranceViewModel: TerminateInsuranceViewModel?
    ) {
        self.terminateInsuranceViewModel = terminateInsuranceViewModel
        self.hasSelectInsuranceStep = true
        self.initialStep = .router(action: .selectInsurance(configs: configs))
        self.redirectHandler.viewModel = self

        observeRouteCount()
    }

    init(
        config: TerminationConfirmConfig,
        surveyData: TerminationSurveyData,
        terminateInsuranceViewModel: TerminateInsuranceViewModel?
    ) {
        self.terminateInsuranceViewModel = terminateInsuranceViewModel
        self.config = config
        self.surveyData = surveyData
        self.hasSelectInsuranceStep = false
        self.initialStep = .router(action: .survey)
        self.redirectHandler.viewModel = self
        observeRouteCount()
    }

    /// Starts by asking the member whether to withdraw or cancel the contract.
    init(
        withdrawalChoiceFor config: TerminationConfirmConfig,
        terminateInsuranceViewModel: TerminateInsuranceViewModel?
    ) {
        self.terminateInsuranceViewModel = terminateInsuranceViewModel
        self.config = config
        self.hasSelectInsuranceStep = false
        self.initialStep = .router(action: .withdrawalChoice)
        self.redirectHandler.viewModel = self
        observeRouteCount()
    }

    /// Starts straight on review and confirm of a withdrawal, for contracts that can't be cancelled.
    init(
        config: TerminationConfirmConfig,
        withdrawal: ContractWithdrawalData,
        terminateInsuranceViewModel: TerminateInsuranceViewModel?
    ) {
        self.terminateInsuranceViewModel = terminateInsuranceViewModel
        self.config = config
        self.hasSelectInsuranceStep = false
        self.initialStep = .router(action: .confirmation)
        self.redirectHandler.viewModel = self
        applyWithdrawal(withdrawal)
        observeRouteCount()
    }

    // MARK: - Survey

    func fetchSurvey(for config: TerminationConfirmConfig) async {
        self.config = config
        if config.isWithdrawalOnly {
            await startWithdrawal()
            return
        }
        if config.supportsWithdrawal {
            router.push(TerminationFlowRouterActions.withdrawalChoice)
            return
        }
        await startTermination()
    }

    /// Continues with the regular cancellation flow, starting with the survey.
    func startTermination() async {
        guard let config else { return }
        withAnimation {
            fetchingSurvey = true
        }
        do {
            let data = try await terminateContractsService.getTerminationSurvey(contractId: config.contractId)
            resetPathState()
            self.surveyData = data
            router.push(TerminationFlowRouterActions.survey)
        } catch {
            router.push(TerminationFlowFinalRouterActions.failure(message: error.localizedDescription))
        }
        withAnimation {
            fetchingSurvey = false
        }
    }

    // MARK: - Withdrawal

    /// Continues with a withdrawal: there is no survey and no date selection, so the flow goes straight to
    /// review and confirm.
    func startWithdrawal() async {
        guard let config else { return }
        withAnimation {
            fetchingSurvey = true
        }
        do {
            let data = try await terminateContractsService.getContractWithdrawal(contractId: config.contractId)
            applyWithdrawal(data)
            router.push(TerminationFlowRouterActions.confirmation)
        } catch {
            router.push(TerminationFlowFinalRouterActions.failure(message: error.localizedDescription))
        }
        withAnimation {
            fetchingSurvey = false
        }
    }

    func applyWithdrawal(_ data: ContractWithdrawalData) {
        resetPathState()
        withdrawal = data
        if case let .terminateWithDate(minDate, maxDate, _) = data.action, minDate == maxDate {
            selectedDate = minDate.localDateToDate
        } else {
            selectedDate = nil
        }
        if isDeletion {
            fetchNotification(for: Date())
        } else if let selectedDate {
            // A withdrawal skips date selection and goes straight to review and confirm, so the date picker
            // never fetches the notification for its date: it has to be fetched here.
            fetchNotification(for: selectedDate)
        }
    }

    /// Clears everything chosen on the withdrawal or cancellation path, so switching between them (by going back to
    /// the choice screen) can't carry over a date, survey answer or notification from the other path.
    private func resetPathState() {
        withdrawal = nil
        selectedOptionId = nil
        selectedComment = nil
        selectedDate = nil
        fetchNotificationTask?.cancel()
        fetchNotificationTask = nil
        notification = nil
    }

    // MARK: - Survey Completion
    func proceedAfterSurvey(optionId: String, comment: String?) {
        selectedOptionId = optionId
        selectedComment = comment
        guard action != nil else { return }
        if isDeletion {
            fetchNotification(for: Date())
        }
        router.push(TerminationFlowRouterActions.datePicker)
    }

    func handleSuggestion(_ suggestion: TerminationSuggestion) {
        if suggestion.isDeflect, let content = DeflectScreenContent.from(suggestion: suggestion) {
            router.push(content)
        } else if !suggestion.isDeflect {
            Task {
                await redirectHandler.handle(suggestion)
            }
        }
    }

    func handleRedirection(_ redirection: TerminationRedirection) {
        switch redirection.type {
        case .updateAddress:
            openMoveFlow()
        case .unknown:
            break
        }
    }

    func continueSurvey(option: TerminationSurveyOption, comment: String?) {
        if !option.subOptions.isEmpty {
            router.push(option.subOptions)
        } else if let suggestion = option.suggestion, suggestion.isDeflect || suggestion.isBlocking {
            selectedOptionId = option.id
            selectedComment = comment
            handleSuggestion(suggestion)
        } else {
            proceedAfterSurvey(optionId: option.id, comment: comment)
        }
    }

    func openMoveFlow() {
        redirectHandler.handleUpdateAddress()
    }

    // MARK: - Termination Submission

    func submitTermination() {
        guard let contractId = config?.contractId, let submission = pendingSubmission else { return }

        Task { [weak self] in
            guard let self else { return }
            isProcessingPresented = true
            withAnimation {
                confirmTerminationState = .loading
            }

            do {
                let result: TerminationContractResult
                switch submission {
                case .withdrawal:
                    result = try await terminateContractsService.withdrawContract(contractId: contractId)
                case let .deletion(optionId):
                    result = try await terminateContractsService.deleteContract(
                        contractId: contractId,
                        surveyOptionId: optionId,
                        comment: selectedComment
                    )
                case let .termination(optionId):
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
                    router.push(TerminationFlowFinalRouterActions.success)
                case let .userError(message):
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

    /// Title of the success screen. A withdrawal says the insurance was withdrawn rather than cancelled.
    var successTitle: String {
        isWithdrawal ? L10n.terminationFlowWithdrawalSuccessTitle : L10n.terminationFlowSuccessTitle
    }

    /// Body of the success screen. A withdrawal ending today says so, and one without a date set by the backend
    /// doesn't show an empty date.
    var successBody: String {
        if isDeletion {
            return L10n.terminateContractTerminationComplete
        }
        guard let selectedDate else {
            return isWithdrawal
                ? L10n.terminationFlowConfirmation
                : L10n.terminationFlowSuccessSubtitleWithDate("")
        }
        let date = selectedDate.displayDateDDMMMYYYYFormat
        if isWithdrawal, Calendar.current.isDateInToday(selectedDate) {
            return L10n.terminationFlowConfirmationSubtitleToday(date)
        }
        return L10n.terminationFlowSuccessSubtitleWithDate(date)
    }

    /// What `submitTermination()` sends. A withdrawal has no survey, so only the other two need a selected option.
    private var pendingSubmission: TerminationSubmission? {
        if isWithdrawal { return .withdrawal }
        guard let selectedOptionId else { return nil }
        return isDeletion ? .deletion(optionId: selectedOptionId) : .termination(optionId: selectedOptionId)
    }

    // MARK: - Notification
    @ObservationIgnored var fetchNotificationTask: Task<Void, Never>?

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
                withAnimation {
                    notification = data
                }
            } catch {
                do {
                    try await Task.sleep(for: .seconds(1))
                    try Task.checkCancellation()
                    fetchNotification(for: date)
                } catch { /* cancellation expected */  }
            }
        }
    }

    // MARK: - Progress Calculation
    private var remainingSteps: Int {
        2  // datePicker + confirmation// datePicker + confirmation
    }

    private func updateProgress() {
        let pushedTypes = router.routeTypes
        if pushedTypes.last == TerminationFlowFinalRouterActions.self
            || pushedTypes.last == DeflectScreenContent.self
        {
            progress = nil
        } else {
            let count = router.routeTypes.count
            progress = Float(count) / Float(count + remainingSteps)
        }
    }

    // routeTypes is @Observable now, so progress is re-read by re-arming a tracking scope:
    // withObservationTracking fires once per change and has to be renewed each time.
    private func observeRouteCount() {
        withObservationTracking {
            _ = router.routeTypes
        } onChange: { [weak self] in
            Task { @MainActor in
                guard let self else { return }
                self.updateProgress()
                self.observeRouteCount()
            }
        }
    }
}

// MARK: - Navigation View

struct TerminationFlowNavigation: View {
    @Bindable private var vm: TerminationFlowNavigationViewModel
    let isFlowPresented: (DismissTerminationAction) -> Void

    init(
        vm: TerminationFlowNavigationViewModel,
        isFlowPresented: @escaping (DismissTerminationAction) -> Void = { _ in }
    ) {
        self.isFlowPresented = isFlowPresented
        self.vm = vm
    }

    var body: some View {
        hNavigationStack(
            router: vm.router,
            options: [
                .extendedNavigationWidth
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
                        .withDismissButton()
                }
                .routerDestination(for: TerminationSurveyRedirectionRoute.self) { route in
                    TerminationSurveyRedirectionScreen(route: route)
                        .withDismissButton()
                }
                .routerDestination(for: TerminationFlowRouterActions.self) { action in
                    Group {
                        switch action {
                        case .survey:
                            openSurveyScreen()
                        case .datePicker:
                            openSetTerminationDateLandingScreen()
                        case let .selectInsurance(configs):
                            openSelectInsuranceScreen(configs: configs)
                        case .confirmation:
                            openTerminationSummaryScreen()
                        case .withdrawalChoice:
                            openWithdrawalChoiceScreen()
                        }
                    }
                }
                .routerDestination(
                    for: DeflectScreenContent.self,
                    destination: { content in
                        openDeflectScreen(content: content)
                    }
                )
                .routerDestination(
                    for: TerminationFlowFinalRouterActions.self,
                    options: .hidesBackButton
                ) { action in
                    Group {
                        switch action {
                        case .success:
                            openTerminationSuccessScreen(
                                title: vm.successTitle,
                                body: vm.successBody
                            )
                        case let .failure(message):
                            openTerminationFailScreen(message: message)
                        }
                    }
                }
        }
        .addProgressBar(with: $vm.progress)
        .environment(vm)
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
                .environment(vm)
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
            case let .selectInsurance(configs):
                openSelectInsuranceScreen(configs: configs)
            case .confirmation:
                openTerminationSummaryScreen()
            case .withdrawalChoice:
                openWithdrawalChoiceScreen()
            }
        case let .final(action):
            switch action {
            case .success:
                openTerminationSuccessScreen(
                    title: vm.successTitle,
                    body: vm.successBody
                )
            case let .failure(message):
                openTerminationFailScreen(message: message)
            }
        case let .deflect(content):
            openDeflectScreen(content: content)
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

    private func openWithdrawalChoiceScreen() -> some View {
        TerminationWithdrawalChoiceScreen()
            .withDismissButton()
    }

    private func openSetTerminationDateLandingScreen() -> some View {
        SetTerminationDateLandingScreen(terminationNavigationVm: vm)
            .withDismissButton()
    }

    private func openSelectInsuranceScreen(configs: [TerminationConfirmConfig]) -> some View {
        TerminationSelectInsuranceScreen(vm: vm, configs: configs)
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

    private func openTerminationSuccessScreen(title: String, body: String) -> some View {
        SuccessScreen(
            successViewTitle: title,
            successViewBody: body,

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

private enum TerminationSubmission {
    case withdrawal
    case deletion(optionId: String)
    case termination(optionId: String)
}

public enum TerminationFlowRouterActions: Hashable {
    case selectInsurance(configs: [TerminationConfirmConfig])
    case survey
    case datePicker
    case confirmation
    case withdrawalChoice
}

extension TerminationFlowRouterActions: TrackingViewNameProtocol {
    public var nameForTracking: String {
        switch self {
        case .selectInsurance:
            return .init(describing: TerminationSelectInsuranceScreen.self)
        case .survey:
            return .init(describing: TerminationSurveyScreen.self)
        case .datePicker:
            return .init(describing: SetTerminationDateLandingScreen.self)
        case .confirmation:
            return .init(describing: TerminationSummaryScreen.self)
        case .withdrawalChoice:
            return .init(describing: TerminationWithdrawalChoiceScreen.self)
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

extension DeflectScreenContent: @retroactive TrackingViewNameProtocol {
    public var nameForTracking: String {
        .init(describing: TerminationDeflectScreen.self)
    }
}

public enum TerminationFlowActions: Hashable {
    case router(action: TerminationFlowRouterActions)
    case final(action: TerminationFlowFinalRouterActions)
    case deflect(content: DeflectScreenContent)
}

extension TerminationFlowActions: TrackingViewNameProtocol {
    public var nameForTracking: String {
        switch self {
        case let .router(action):
            return action.nameForTracking
        case let .final(action):
            return action.nameForTracking
        case let .deflect(content):
            return content.nameForTracking
        }
    }
}

extension [TerminationSurveyOption]: @retroactive TrackingViewNameProtocol {
    public var nameForTracking: String {
        "TerminationSurveySubOptions"
    }
}

public struct TerminationSurveyRedirectionRoute: Hashable {
    let option: TerminationSurveyOption
    let comment: String?
    let redirection: TerminationRedirection

    init?(option: TerminationSurveyOption, comment: String?) {
        guard let redirection = option.redirection else { return nil }
        self.option = option
        self.comment = comment
        self.redirection = redirection
    }
}

extension TerminationSurveyRedirectionRoute: TrackingViewNameProtocol {
    public var nameForTracking: String {
        .init(describing: TerminationSurveyRedirectionScreen.self)
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
