import ChangeTier
import Combine
import Environment
import SwiftUI
import hCore
import hCoreUI

@MainActor
public class TerminationFlowNavigationViewModel: ObservableObject, @preconcurrency Equatable, Identifiable {
    public static func == (lhs: TerminationFlowNavigationViewModel, rhs: TerminationFlowNavigationViewModel) -> Bool {
        return lhs.id == rhs.id
    }

    public let id = UUID().uuidString

    public init(
        stepResponse: TerminateStepResponse,
        config: TerminationConfirmConfig,
        terminateInsuranceViewModel: TerminateInsuranceViewModel?
    ) {
        self.config = config
        self.hasSelectInsuranceStep = false
        self.progress = stepResponse.progress
        self.currentContext = stepResponse.context
        self.initialStep = TerminationFlowNavigationViewModel.getInitialStep(data: stepResponse)
        self.terminationDateStepModel = terminationDateStepModel
        self.terminateInsuranceViewModel = terminateInsuranceViewModel
        setInitialModel(initialStep: initialStep)
    }

    private static func getInitialStep(data: TerminateStepResponse) -> TerminationFlowActions {
        switch data.step {
        case let .setTerminationDateStep(model):
            return .router(action: .terminationDate(model: model))
        case let .setSuccessStep(model):
            return .final(action: .success(model: model))
        case let .setFailedStep(model):
            return .final(action: .fail(model: model))
        case let .setTerminationSurveyStep(model):
            return .router(action: .surveyStep(model: model))
        case .openTerminationUpdateAppScreen:
            return .final(action: .updateApp)
        default:
            return .final(action: .fail(model: nil))
        }
    }

    public init(
        configs: [TerminationConfirmConfig],
        terminateInsuranceViewModel: TerminateInsuranceViewModel?
    ) {
        self.configs = configs
        self.terminateInsuranceViewModel = terminateInsuranceViewModel
        initialStep = .router(action: .selectInsurance(configs: configs))
    }

    private func setInitialModel(initialStep: TerminationFlowActions) {
        reset()
        switch initialStep {
        case .router(let action):
            switch action {
            case .selectInsurance:
                break
            case let .terminationDate(model):
                terminationDateStepModel = model
            case let .surveyStep(model):
                terminationSurveyStepModel = model
            case .summary:
                break
            }
        case .final(let action):
            switch action {
            case let .success(model):
                successStepModel = model
            case let .fail(model):
                failedStepModel = model
            case .updateApp:
                break
            }
        }
    }

    @Published var isDatePickerPresented = false
    @Published var isConfirmTerminationPresented = false
    @Published var isProcessingPresented = false
    @Published var infoText: String?
    @Published var redirectActionLoadingState: ProcessingState = .success
    let initialStep: TerminationFlowActions
    var configs: [TerminationConfirmConfig] = []
    weak var terminateInsuranceViewModel: TerminateInsuranceViewModel?
    var redirectAction: FlowTerminationSurveyRedirectAction? {
        didSet {
            switch redirectAction {
            case .updateAddress:
                self.router.dismiss()
                var url = Environment.current.deepLinkUrls.last!
                url.appendPathComponent(DeepLink.moveContract.rawValue)
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    NotificationCenter.default.post(name: .openDeepLink, object: url)
                }
            case .changeTierFoundBetterPrice, .changeTierMissingCoverageAndTerms:
                if let contractId = config?.contractId,
                    let redirectAction,
                    let source: ChangeTierSource = {
                        if case .changeTierFoundBetterPrice = redirectAction {
                            return .betterPrice
                        } else if case .changeTierMissingCoverageAndTerms = redirectAction {
                            return .betterCoverage
                        }
                        return nil
                    }()
                {
                    let input = ChangeTierInputData(source: source, contractId: contractId)
                    Task { @MainActor [weak self] in
                        do {
                            withAnimation {
                                self?.redirectActionLoadingState = .loading
                            }
                            let newInput = try await ChangeTierNavigationViewModel.getTiers(input: input)
                            withAnimation {
                                self?.redirectActionLoadingState = .success
                            }
                            DispatchQueue.main.async { [weak self] in
                                self?.terminateInsuranceViewModel?.changeTierInput = .existingIntent(
                                    intent: newInput,
                                    onSelect: nil
                                )
                                self?.router.dismiss()
                            }
                        } catch let exception {
                            withAnimation {
                                self?.redirectActionLoadingState = .success
                            }
                            if let exception = exception as? ChangeTierError {
                                switch exception {
                                case .emptyList:
                                    self?.infoText = L10n.terminationNoTierQuotesSubtitle
                                default:
                                    Toasts.shared.displayToastBar(
                                        toast: .init(type: .error, text: exception.localizedDescription)
                                    )
                                }
                            } else {
                                Toasts.shared.displayToastBar(
                                    toast: .init(type: .error, text: exception.localizedDescription)
                                )
                            }
                        }
                    }
                }
            case .none:
                break
            }
        }
    }

    var redirectUrl: URL? {
        didSet {
            if let redirectUrl {
                self.router.dismiss()
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    NotificationCenter.default.post(name: .openDeepLink, object: redirectUrl)
                }
            }
        }
    }
    let router = Router()

    private let terminateContractsService = TerminateContractsService()

    @Published var currentContext: String?
    @Published var progress: Float? = 0
    var previousProgress: Float?
    @Published var hasSelectInsuranceStep: Bool = false
    @Published var successStepModel: TerminationFlowSuccessNextModel?
    @Published var failedStepModel: TerminationFlowFailedNextModel?
    @Published var terminationSurveyStepModel: TerminationFlowSurveyStepModel?
    @Published var config: TerminationConfirmConfig?

    @Published var terminationDateStepModel: TerminationFlowDateNextStepModel? {
        didSet {
            extraCoverage = terminationDateStepModel?.extraCoverageItem ?? []
        }
    }
    @Published var terminationDeleteStepModel: TerminationFlowDeletionNextModel? {
        didSet {
            extraCoverage = terminationDeleteStepModel?.extraCoverageItem ?? []
        }
    }

    @Published var extraCoverage: [ExtraCoverageItem] = []

    var isDeletion: Bool {
        terminationDeleteStepModel != nil
    }

    @MainActor
    func startTermination(config: TerminationConfirmConfig, fromSelectInsurance: Bool) async {
        do {
            let data = try await terminateContractsService.startTermination(contractId: config.contractId)
            self.config = config
            navigate(data: data, fromSelectInsurance: fromSelectInsurance)
        } catch {

        }
    }

    func navigate(data: TerminateStepResponse, fromSelectInsurance: Bool) {
        currentContext = data.context

        if !fromSelectInsurance {
            previousProgress = progress
            progress = data.progress
        }

        switch data.step {
        case let .setTerminationDateStep(model):
            terminationDateStepModel = model
            router.push(TerminationFlowRouterActions.terminationDate(model: model))
        case let .setTerminationDeletion(model):
            terminationDeleteStepModel = model
            router.push(TerminationFlowRouterActions.terminationDate(model: nil))
        case let .setSuccessStep(model):
            successStepModel = model
            router.push(TerminationFlowFinalRouterActions.success(model: model))
        case let .setFailedStep(model):
            failedStepModel = model
            router.push(TerminationFlowFinalRouterActions.fail(model: model))
        case let .setTerminationSurveyStep(model):
            terminationSurveyStepModel = model
            router.push(TerminationFlowRouterActions.surveyStep(model: model))
        case .openTerminationUpdateAppScreen:
            router.push(TerminationFlowFinalRouterActions.updateApp)
        }
    }

    func reset() {
        terminationDateStepModel = nil
        terminationDeleteStepModel = nil
        successStepModel = nil
        failedStepModel = nil
        terminationSurveyStepModel = nil
    }

    @Published var confirmTerminationState: ProcessingState = .loading

    public func sendConfirmTermination() {
        if isDeletion {
            sendConfirmDelete()
        } else {
            sendTerminationDate()
        }
    }

    @MainActor
    public func sendConfirmDelete() {
        Task {
            isProcessingPresented = true
            withAnimation {
                confirmTerminationState = .loading
            }
            do {
                guard let currentContext else {
                    throw TerminationError.missingContext
                }
                let data = try await terminateContractsService.sendConfirmDelete(
                    terminationContext: currentContext,
                    model: terminationDeleteStepModel
                )
                withAnimation {
                    confirmTerminationState = .success
                }
                isProcessingPresented = false
                navigate(data: data, fromSelectInsurance: false)
            } catch let error {
                withAnimation {
                    confirmTerminationState = .error(
                        errorMessage: error.localizedDescription
                    )
                }
            }
        }
    }

    @MainActor
    public func sendTerminationDate() {
        Task {
            isProcessingPresented = true
            withAnimation {
                confirmTerminationState = .loading
            }
            do {
                guard let currentContext else {
                    throw TerminationError.missingContext
                }
                let data = try await terminateContractsService.sendTerminationDate(
                    inputDateToString: terminationDateStepModel?.date?.localDateString ?? "",
                    terminationContext: currentContext
                )
                withAnimation {
                    confirmTerminationState = .success
                }
                navigate(data: data, fromSelectInsurance: false)
                isProcessingPresented = false
            } catch let error {
                withAnimation {
                    confirmTerminationState = .error(
                        errorMessage: error.localizedDescription
                    )
                }
            }
        }
    }
    var fetchNotificationTask: Task<Void, Never>?
    func fetchNotification() {
        fetchNotificationTask?.cancel()
        fetchNotificationTask = Task { [weak self] in
            if let contractId = self?.config?.contractId, let date = self?.terminationDateStepModel?.date {
                do {
                    //check for cancellation before fetching and after fetching
                    try Task.checkCancellation()
                    let data = try await self?.terminateContractsService
                        .getNotification(contractId: contractId, date: date)
                    try Task.checkCancellation()
                    self?.terminationDateStepModel?.notification = data
                } catch _ {
                    // if it fails check again after 1 second
                    // if the task is cancelled, it will throw cancellation error
                    do {
                        try await Task.sleep(nanoseconds: 1_000_000_000)
                        try Task.checkCancellation()
                        self?.fetchNotification()
                    } catch {
                        //ignore since it only be cancellation error
                    }

                }
            }
        }
    }
}

struct TerminationFlowNavigation: View {
    @ObservedObject private var vm: TerminationFlowNavigationViewModel
    let isFlowPresented: (DismissTerminationAction) -> Void

    public init(
        vm: TerminationFlowNavigationViewModel,
        isFlowPresented: @escaping (DismissTerminationAction) -> Void = { _ in }
    ) {
        self.isFlowPresented = isFlowPresented
        self.vm = vm
    }

    public var body: some View {
        RouterHost(
            router: vm.router,
            options: [.navigationType(type: .withProgress)],
            tracking: vm.initialStep
        ) {
            getView(for: vm.initialStep)
                .addNavigationInfoButton(
                    placement: .leading,
                    title: L10n.terminationFlowCancelInfoTitle,
                    description: L10n.terminationFlowCancelInfoText
                )
                .resetProgressOnDismiss(to: vm.previousProgress, for: $vm.progress)
                .routerDestination(for: [TerminationFlowSurveyStepModelOption].self) { options in
                    TerminationSurveyScreen(vm: .init(options: options, subtitleType: .generic))
                }
                .routerDestination(for: TerminationFlowRouterActions.self) { action in
                    Group {
                        switch action {
                        case .terminationDate:
                            openSetTerminationDateLandingScreen(fromSelectInsurance: false)
                        case let .surveyStep(model):
                            openSurveyScreen(model: model ?? .init(id: "", options: [], subTitleType: .default))
                        case .selectInsurance:
                            openSelectInsuranceScreen()
                        case .summary:
                            openTerminationSummaryScreen()
                        }
                    }
                    .resetProgressOnDismiss(to: vm.previousProgress, for: $vm.progress)
                }
                .routerDestination(
                    for: TerminationFlowFinalRouterActions.self,
                    options: .hidesBackButton
                ) { [weak vm] action in
                    Group {
                        switch action {
                        case .success:
                            let terminationDate =
                                vm?.successStepModel?.terminationDate?.localDateToDate?.displayDateDDMMMYYYYFormat ?? ""
                            openTerminationSuccessScreen(
                                isDeletion: vm?.isDeletion ?? false,
                                terminationDate: terminationDate
                            )
                            .onAppear {
                                vm?.isProcessingPresented = false
                            }
                        case .fail:
                            openTerminationFailScreen()
                                .onAppear {
                                    vm?.isProcessingPresented = false
                                }
                        case .updateApp:
                            openUpdateAppTerminationScreen()
                        }
                    }
                    .resetProgressOnDismiss(to: vm?.previousProgress, for: $vm.progress)
                }
        }
        .modifier(ProgressBarView(progress: $vm.progress))
        .environmentObject(vm)
        .detent(
            presented: $vm.isDatePickerPresented,
            transitionType: .detent(style: [.height])
        ) {
            openSetTerminationDatePickerScreen()
        }
        .detent(
            presented: $vm.isConfirmTerminationPresented,
            transitionType: .detent(style: [.height])
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
            case .terminationDate:
                openSetTerminationDateLandingScreen(fromSelectInsurance: false)
            case let .surveyStep(model):
                openSurveyScreen(model: model ?? .init(id: "", options: [], subTitleType: .default))
            case .selectInsurance:
                openSelectInsuranceScreen()
            case .summary:
                openTerminationSummaryScreen()
            }
        case let .final(action):
            switch action {
            case .success:
                let terminationDate =
                    vm.successStepModel?.terminationDate?.localDateToDate?.displayDateDDMMMYYYYFormat ?? ""
                openTerminationSuccessScreen(
                    isDeletion: vm.isDeletion,
                    terminationDate: terminationDate
                )
                .onAppear {
                    vm.isProcessingPresented = false
                }
            case .fail:
                openTerminationFailScreen()
                    .onAppear {
                        vm.isProcessingPresented = false
                    }
            case .updateApp:
                openUpdateAppTerminationScreen()
            }
        }
    }

    private func openSetTerminationDateLandingScreen(
        fromSelectInsurance: Bool
    ) -> some View {
        SetTerminationDateLandingScreen(
            terminationNavigationVm: vm
        )
        .withDismissButton()
    }

    private func openSelectInsuranceScreen() -> some View {
        TerminationSelectInsuranceScreen(vm: vm)
    }

    private func openUpdateAppTerminationScreen() -> some View {
        UpdateAppScreen(
            onSelected: {
                vm.router.dismiss()
            }
        )
        .withDismissButton()
    }

    private func openSurveyScreen(
        model: TerminationFlowSurveyStepModel
    ) -> some View {
        let vm = SurveyScreenViewModel(options: model.options, subtitleType: model.subTitleType)
        return TerminationSurveyScreen(vm: vm)
            .withDismissButton()
    }

    private func openConfirmTerminationScreen() -> some View {
        ConfirmTerminationScreen()
            .withDismissButton()
    }

    private func openTerminationSummaryScreen() -> some View {
        TerminationSummaryScreen()
            .withDismissButton()
    }

    private func openSetTerminationDatePickerScreen() -> some View {
        SetTerminationDate(
            terminationDate: {
                let preSelectedTerminationDate = vm.terminationDateStepModel?.minDate.localDateToDate
                return preSelectedTerminationDate ?? Date()
            },
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
                : L10n.terminationFlowSuccessSubtitleWithDate((terminationDate))
        )
        .hStateViewButtonConfig(
            .init(
                actionButton: nil,
                actionButtonAttachedToBottom: nil,
                dismissButton: .init(buttonAction: { [weak vm] in
                    vm?.router.dismiss()
                    self.isFlowPresented(.done)
                })
            )
        )
    }

    private func openTerminationFailScreen() -> some View {
        GenericErrorView(
            title: L10n.terminationNotSuccessfulTitle,
            description: L10n.somethingWentWrong,
            formPosition: .center
        )
        .hStateViewButtonConfig(
            .init(
                actionButton: .init(
                    buttonTitle: L10n.openChat,
                    buttonAction: {
                        self.isFlowPresented(.chat)
                    }
                ),
                dismissButton: .init(
                    buttonAction: { [weak vm] in
                        vm?.router.dismiss()
                    }
                )
            )
        )
    }

    private var tabBarInfoView: some View {
        InfoViewHolder(
            title: L10n.terminationFlowCancelInfoTitle,
            description: L10n.terminationFlowCancelInfoText,
            type: .navigation
        )
        .foregroundColor(hTextColor.Opaque.primary)
    }
}

struct TerminationFlowActionWrapper: Identifiable, Equatable {
    var id = UUID().uuidString
    let action: TerminationFlowActions
}

public enum TerminationFlowActions: Hashable {
    case router(action: TerminationFlowRouterActions)
    case final(action: TerminationFlowFinalRouterActions)
}

enum TerminationFlowDetentActions: Hashable, TrackingViewNameProtocol {
    var nameForTracking: String {
        switch self {
        case .terminationDate:
            return .init(describing: SetTerminationDate.self)
        }
    }

    case terminationDate
}

extension TerminationFlowActions: TrackingViewNameProtocol {
    public var nameForTracking: String {
        switch self {
        case .router(let action):
            return action.nameForTracking
        case .final(let action):
            return action.nameForTracking
        }
    }
}

public enum TerminationFlowRouterActions: Hashable {
    case selectInsurance(configs: [TerminationConfirmConfig])
    case terminationDate(model: TerminationFlowDateNextStepModel?)
    case surveyStep(model: TerminationFlowSurveyStepModel?)
    case summary
}

extension TerminationFlowRouterActions: TrackingViewNameProtocol {
    public var nameForTracking: String {
        switch self {
        case .selectInsurance:
            return "Select Insurance"
        case .terminationDate:
            return .init(describing: SetTerminationDateLandingScreen.self)
        case .surveyStep:
            return .init(describing: TerminationSurveyScreen.self)
        case .summary:
            return .init(describing: TerminationSummaryScreen.self)
        }
    }
}

public enum TerminationFlowFinalRouterActions: Hashable {
    case success(model: TerminationFlowSuccessNextModel?)
    case fail(model: TerminationFlowFailedNextModel?)
    case updateApp
}

extension TerminationFlowFinalRouterActions: TrackingViewNameProtocol {
    public var nameForTracking: String {
        switch self {
        case .success:
            return "TerminationSuccessScreen"
        case .fail:
            return "TerminationFailScreen"
        case .updateApp:
            return .init(describing: UpdateAppScreen.self)
        }
    }
}

public enum DismissTerminationAction {
    case done
    case chat
    case openFeedback(url: URL)
    case changeTierFoundBetterPriceStarted
    case changeTierMissingCoverageAndTermsStarted
}
