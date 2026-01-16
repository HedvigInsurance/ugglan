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

    func handle(_ action: FlowTerminationSurveyRedirectAction?) async {
        guard let action = action else { return }

        switch action {
        case .updateAddress:
            handleUpdateAddress()
        case .changeTierFoundBetterPrice, .changeTierMissingCoverageAndTerms:
            await handleChangeTier(action: action)
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

    private func handleChangeTier(action: FlowTerminationSurveyRedirectAction) async {
        guard let viewModel = viewModel,
            let contractId = viewModel.config?.contractId,
            let source = getChangeTierSource(for: action)
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
        } catch let exception {
            withAnimation {
                viewModel.redirectActionLoadingState = .success
            }
            Toasts.shared.displayToastBar(
                toast: .init(type: .error, text: exception.localizedDescription)
            )
        }
    }

    private func getChangeTierSource(for action: FlowTerminationSurveyRedirectAction) -> ChangeTierSource? {
        switch action {
        case .changeTierFoundBetterPrice:
            return .betterPrice
        case .changeTierMissingCoverageAndTerms:
            return .betterCoverage
        default:
            return nil
        }
    }
}

class TerminationStepHandler {
    @MainActor func route(step: TerminationContractStep, to router: Router) -> (model: Any?, progress: Float?) {
        switch step {
        case let .setTerminationDateStep(model):
            router.push(TerminationFlowRouterActions.terminationDate(model: model))
            return (model, nil)
        case let .setTerminationDeletion(model):
            router.push(TerminationFlowRouterActions.terminationDate(model: nil))
            return (model, nil)
        case let .setSuccessStep(model):
            router.push(TerminationFlowFinalRouterActions.success(model: model))
            return (model, nil)
        case let .setFailedStep(model):
            router.push(TerminationFlowFinalRouterActions.fail(model: model))
            return (model, nil)
        case let .setTerminationSurveyStep(model):
            router.push(TerminationFlowRouterActions.surveyStep(model: model))
            return (model, nil)
        case .openTerminationUpdateAppScreen:
            router.push(TerminationFlowFinalRouterActions.updateApp)
            return (nil, nil)
        case let .setDeflectAutoDecom(model):
            router.push(TerminationFlowRouterActions.deflectAutoDecom(model: model))
            return (model, nil)
        case let .setDeflectAutoCancel(model):
            router.push(TerminationFlowRouterActions.deflectAutoCancel(model: model))
            return (model, nil)
        }
    }

    func getInitialAction(from step: TerminationContractStep) -> TerminationFlowActions {
        switch step {
        case let .setTerminationDateStep(model):
            return .router(action: .terminationDate(model: model))
        case .setTerminationDeletion:
            return .router(action: .terminationDate(model: nil))
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
}

// MARK: - View Model

@MainActor
public class TerminationFlowNavigationViewModel: ObservableObject, @preconcurrency Equatable, Identifiable {
    public static func == (lhs: TerminationFlowNavigationViewModel, rhs: TerminationFlowNavigationViewModel) -> Bool {
        lhs.id == rhs.id
    }

    public let id = UUID().uuidString

    // MARK: - Helper Properties
    private let stepHandler = TerminationStepHandler()
    private let redirectHandler = TerminationRedirectHandler()

    // MARK: - UI State
    @Published var isDatePickerPresented = false
    @Published var isConfirmTerminationPresented = false
    @Published var isProcessingPresented = false
    @Published var infoText: String?
    @Published var redirectActionLoadingState: ProcessingState = .success
    @Published var notification: TerminationNotification?

    // MARK: - Properties
    let initialStep: TerminationFlowActions
    var configs: [TerminationConfirmConfig] = []
    weak var terminateInsuranceViewModel: TerminateInsuranceViewModel?

    var redirectAction: FlowTerminationSurveyRedirectAction? {
        didSet {
            Task {
                await redirectHandler.handle(redirectAction)
            }
        }
    }

    var redirectUrl: URL? {
        didSet {
            if let redirectUrl {
                router.dismiss()
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    NotificationCenter.default.post(name: .openDeepLink, object: redirectUrl)
                }
            }
        }
    }

    let router = Router()

    private let terminateContractsService = TerminateContractsService()

    @Published private(set) var currentContext: String?
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

    // MARK: - Initialization

    public init(
        stepResponse: TerminateStepResponse,
        config: TerminationConfirmConfig,
        terminateInsuranceViewModel: TerminateInsuranceViewModel?
    ) {
        self.config = config
        self.hasSelectInsuranceStep = false
        self.progress = stepResponse.progress
        self.currentContext = stepResponse.context
        self.initialStep = stepHandler.getInitialAction(from: stepResponse.step)
        self.terminateInsuranceViewModel = terminateInsuranceViewModel
        self.redirectHandler.viewModel = self
        setInitialModel(from: stepResponse.step)
    }

    public init(
        configs: [TerminationConfirmConfig],
        terminateInsuranceViewModel: TerminateInsuranceViewModel?
    ) {
        self.configs = configs
        self.terminateInsuranceViewModel = terminateInsuranceViewModel
        self.initialStep = .router(action: .selectInsurance(configs: configs))
        self.redirectHandler.viewModel = self
    }

    private func setInitialModel(from step: TerminationContractStep) {
        reset()
        switch step {
        case let .setTerminationDateStep(model):
            terminationDateStepModel = model
        case let .setSuccessStep(model):
            successStepModel = model
        case let .setFailedStep(model):
            failedStepModel = model
        case let .setTerminationSurveyStep(model):
            terminationSurveyStepModel = model
        case let .setTerminationDeletion(model):
            terminationDeleteStepModel = model
        default:
            break
        }
    }

    @MainActor
    func startTermination(config: TerminationConfirmConfig, fromSelectInsurance: Bool) async {
        reset()
        do {
            let data = try await terminateContractsService.startTermination(contractId: config.contractId)
            self.config = config
            navigate(data: data, fromSelectInsurance: fromSelectInsurance)
        } catch {}
    }

    func navigate(data: TerminateStepResponse, fromSelectInsurance: Bool) {
        currentContext = data.context

        if !fromSelectInsurance {
            previousProgress = progress
            progress = data.progress
        }

        updateStepModel(for: data.step)
        _ = stepHandler.route(step: data.step, to: router)
    }

    private func updateStepModel(for step: TerminationContractStep) {
        switch step {
        case let .setTerminationDateStep(model):
            terminationDateStepModel = model
        case let .setTerminationDeletion(model):
            terminationDeleteStepModel = model
        case let .setSuccessStep(model):
            successStepModel = model
        case let .setFailedStep(model):
            failedStepModel = model
        case let .setTerminationSurveyStep(model):
            terminationSurveyStepModel = model
        default:
            break
        }
    }

    func reset() {
        terminationDateStepModel = nil
        terminationDeleteStepModel = nil
        successStepModel = nil
        failedStepModel = nil
        terminationSurveyStepModel = nil
        notification = nil
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
            } catch {
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
            } catch {
                withAnimation {
                    confirmTerminationState = .error(
                        errorMessage: error.localizedDescription
                    )
                }
            }
        }
    }
    var fetchNotificationTask: Task<Void, Never>?
    func fetchNotification(isDeletion deletion: Bool) {
        fetchNotificationTask?.cancel()
        fetchNotificationTask = Task { [weak self] in
            let date: Date? = {
                if deletion {
                    return Date()
                }
                return self?.terminationDateStepModel?.date
            }()
            if let contractId = self?.config?.contractId, let date = date {
                do {
                    //check for cancellation before fetching and after fetching
                    try Task.checkCancellation()
                    let data = try await self?.terminateContractsService
                        .getNotification(contractId: contractId, date: date)
                    try Task.checkCancellation()
                    self?.notification = data
                } catch _ {
                    // if it fails check again after 1 second
                    // if the task is cancelled, it will throw cancellation error
                    do {
                        try await Task.sleep(seconds: 1)
                        try Task.checkCancellation()
                        self?.fetchNotification(isDeletion: deletion)
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
                            openSurveyScreen(model: model ?? .init(options: [], subTitleType: .default))
                        case .selectInsurance:
                            openSelectInsuranceScreen()
                        case .summary:
                            openTerminationSummaryScreen()
                        case let .deflectAutoDecom(model):
                            openDeflectAutoDecom(model: model)
                        case let .deflectAutoCancel(model):
                            openDeflectAutoCancel(model: model)
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
                openSurveyScreen(model: model ?? .init(options: [], subTitleType: .default))
            case .selectInsurance:
                openSelectInsuranceScreen()
            case .summary:
                openTerminationSummaryScreen()
            case .deflectAutoDecom(model: let model):
                openDeflectAutoDecom(model: model)
            case let .deflectAutoCancel(model):
                openDeflectAutoCancel(model: model)
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
        fromSelectInsurance _: Bool
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

    private func openDeflectAutoDecom(model: TerminationFlowDeflectAutoDecomModel) -> some View {
        TerminationDeflectAutoDecomScreen(model: model, navigation: vm)
            .withDismissButton()
    }
    private func openDeflectAutoCancel(model: TerminationFlowDeflectAutoCancelModel) -> some View {
        TerminationDeflectAutoCancelScreen(model: model)
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
                : L10n.terminationFlowSuccessSubtitleWithDate(terminationDate)
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
                        isFlowPresented(.chat)
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
        case let .router(action):
            return action.nameForTracking
        case let .final(action):
            return action.nameForTracking
        }
    }
}

public enum TerminationFlowRouterActions: Hashable {
    case selectInsurance(configs: [TerminationConfirmConfig])
    case terminationDate(model: TerminationFlowDateNextStepModel?)
    case surveyStep(model: TerminationFlowSurveyStepModel?)
    case deflectAutoDecom(model: TerminationFlowDeflectAutoDecomModel)
    case deflectAutoCancel(model: TerminationFlowDeflectAutoCancelModel)
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
        case .deflectAutoDecom:
            return .init(describing: TerminationDeflectAutoDecomScreen.self)
        case .deflectAutoCancel:
            return .init(describing: TerminationDeflectAutoCancelScreen.self)
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
