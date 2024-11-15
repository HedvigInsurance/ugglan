import ChangeTier
import Combine
//import PresentableStore
import SwiftUI
import hCore
import hCoreUI
import hGraphQL

public class TerminationFlowNavigationViewModel: ObservableObject {
    public init(
        initialStep: TerminationFlowActions?
    ) {
        if let initialStep {
            setModels(initialStep: initialStep)
        }
    }

    private func setModels(initialStep: TerminationFlowActions) {
        Task {
            await reset()
        }
        switch initialStep {
        case .router(let action):
            switch action {
            case .selectInsurance:
                break
            case let .terminationDate(config, model):
                terminationDateStepModel = model
            case let .surveyStep(model):
                terminationSurveyStepModel = model
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
    @Published var changeTierInput: ChangeTierInput?
    @Published var infoText: String?

    var isFlowPresented: (DismissTerminationAction) -> Void = { _ in }
    var redirectAction: FlowTerminationSurveyRedirectAction? {
        didSet {
            switch redirectAction {
            case .updateAddress:
                self.router.dismiss()
                var url = Environment.current.deepLinkUrl
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
                        guard let self = self else { return }
                        do {
                            let newInput = try await ChangeTierNavigationViewModel.getTiers(input: input)
                            DispatchQueue.main.async { [weak self] in
                                self?.changeTierInput = .existingIntent(
                                    intent: newInput,
                                    onSelect: nil
                                )
                                self?.router.dismiss()
                            }
                        } catch let exception {
                            if let exception = exception as? ChangeTierError {
                                switch exception {
                                case .emptyList:
                                    self.infoText = L10n.terminationNoTierQuotesSubtitle
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

    @Inject private var terminateContractsService: TerminateContractsClient

    @Published var currentContext: String?
    @Published var progress: Float?
    @Published var previousProgress: Float?
    @Published var hasSelectInsuranceStep: Bool = false

    @Published var terminationDateStepModel: TerminationFlowDateNextStepModel?
    @Published var terminationDeleteStepModel: TerminationFlowDeletionNextModel?
    @Published var successStepModel: TerminationFlowSuccessNextModel?
    @Published var failedStepModel: TerminationFlowFailedNextModel?
    @Published var terminationSurveyStepModel: TerminationFlowSurveyStepModel?
    @Published var config: TerminationConfirmConfig?

    var isDeletion: Bool {
        terminationDeleteStepModel != nil
    }

    @MainActor
    func startTermination(config: TerminationConfirmConfig) async {
        do {
            let data = try await terminateContractsService.startTermination(contractId: config.contractId)
            navigate(data: data)
        } catch {

        }
    }

    func navigate(data: TerminateStepResponse) {
        currentContext = data.context
        previousProgress = progress
        progress = data.progress
        switch data.step {
        case let .setTerminationDateStep(model):
            terminationDateStepModel = model
            if let config {
                router.push(TerminationFlowRouterActions.terminationDate(config: config, model: model))
            }
        case let .setTerminationDeletion(model):
            terminationDeleteStepModel = model
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

    @MainActor
    func reset() {
        currentContext = nil
        terminationDateStepModel = nil
        terminationDeleteStepModel = nil
        successStepModel = nil
        failedStepModel = nil
        terminationSurveyStepModel = nil
    }
}

struct TerminationFlowNavigation: View {
    @ObservedObject private var vm: TerminationFlowNavigationViewModel
    //    @StateObject var router = Router()
    var configs: [TerminationConfirmConfig] = []

    let initialStep: TerminationFlowActions

    public init(
        initialStep: TerminationFlowActions,
        configs: [TerminationConfirmConfig]
    ) {
        self.initialStep = initialStep
        self.configs = configs
        self.vm = .init(initialStep: initialStep)
    }

    public var body: some View {
        RouterHost(
            router: vm.router,
            options: [.navigationType(type: .withProgress)],
            tracking: initialStep
        ) {
            getView(for: initialStep)
                .addTerminationProgressBar
                .routerDestination(for: [TerminationFlowSurveyStepModelOption].self) { options in
                    TerminationSurveyScreen(vm: .init(options: options, subtitleType: .generic))
                }
                .routerDestination(for: TerminationFlowRouterActions.self) { action in
                    switch action {
                    case let .terminationDate(config, model):
                        openSetTerminationDateLandingScreen(config: config, fromSelectInsurance: false)
                    case let .surveyStep(model):
                        openSurveyScreen(model: model ?? .init(id: "", options: [], subTitleType: .default))
                    case .selectInsurance:
                        openSelectInsuranceScreen()
                    }
                }
                .routerDestination(
                    for: TerminationFlowFinalRouterActions.self,
                    options: .hidesBackButton
                ) { action in
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
        .modally(item: $vm.changeTierInput) { item in
            ChangeTierNavigation(input: item)
        }
        .environmentObject(vm)
        .detent(
            presented: $vm.isDatePickerPresented,
            style: [.height]
        ) {
            openSetTerminationDatePickerScreen()
                .environmentObject(vm)
        }
        .detent(
            presented: $vm.isConfirmTerminationPresented,
            style: [.height]
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
            case let .terminationDate(config, _):
                openSetTerminationDateLandingScreen(config: config, fromSelectInsurance: false)
            case let .surveyStep(model):
                openSurveyScreen(model: model ?? .init(id: "", options: [], subTitleType: .default))
            case .selectInsurance:
                openSelectInsuranceScreen()
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
        config: TerminationConfirmConfig,
        fromSelectInsurance: Bool
    ) -> some View {
        SetTerminationDateLandingScreen(
            onSelected: {
                vm.isConfirmTerminationPresented = true
            }
        )
        .resetProgressToPreviousValueOnDismiss
        .withDismissButton()
        .toolbar {
            ToolbarItem(
                placement: .topBarLeading
            ) {
                if fromSelectInsurance {
                    tabBarInfoView
                }
            }
        }
    }

    private func openSelectInsuranceScreen() -> some View {
        ItemPickerScreen<TerminationConfirmConfig>(
            config: .init(
                items: {
                    let items = configs.map({
                        (
                            object: $0,
                            displayName: ItemModel(
                                title: $0.contractDisplayName,
                                subTitle: $0.contractExposureName
                            )
                        )
                    })
                    return items
                }(),
                preSelectedItems: { [] },
                onSelected: { selected in
                    if let selectedContract = selected.first?.0 {
                        let config = TerminationConfirmConfig(
                            contractId: selectedContract.contractId,
                            contractDisplayName: selectedContract.contractDisplayName,
                            contractExposureName: selectedContract.contractExposureName,
                            activeFrom: selectedContract.activeFrom
                        )
                        Task {
                            await vm.startTermination(config: config)
                        }
                    }
                },
                singleSelect: true,
                attachToBottom: true,
                disableIfNoneSelected: true,
                hButtonText: L10n.generalContinueButton,
                fieldSize: .small
            )
        )
        .hFormTitle(
            title: .init(.small, .heading2, L10n.terminationFlowTitle, alignment: .leading),
            subTitle: .init(.small, .heading2, L10n.terminationFlowBody)
        )
        .withDismissButton()
        .resetProgressToPreviousValueOnDismiss
        .hFieldSize(.small)
        .toolbar {
            ToolbarItem(
                placement: .topBarLeading
            ) {
                tabBarInfoView
            }
        }
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
            .resetProgressToPreviousValueOnDismiss
            .withDismissButton()
    }

    private func openConfirmTerminationScreen() -> some View {
        ConfirmTerminationScreen()
            .withDismissButton()
    }

    private func openSetTerminationDatePickerScreen() -> some View {
        SetTerminationDate(
            onSelected: {
                terminationDate in
                vm.terminationDateStepModel?.date = terminationDate
                vm.isDatePickerPresented = false
            },
            terminationDate: {
                let preSelectedTerminationDate = vm.terminationDateStepModel?.minDate.localDateToDate
                return preSelectedTerminationDate ?? Date()
            }
        )
        .navigationTitle(L10n.setTerminationDateText)
        .embededInNavigation(
            options: [.navigationType(type: .large)],
            tracking: TerminationFlowDetentActions.terminationDate
        )
    }

    private func openProgressScreen() -> some View {
        hProcessingView<TerminationContractStore>(
            showSuccessScreen: false,
            TerminationContractStore.self,
            loading: .sendTerminationDate,
            loadingViewText: L10n.terminateContractTerminatingProgress
        )
    }

    private func openTerminationSuccessScreen(
        isDeletion: Bool,
        terminationDate: String
    ) -> some View {
        SuccessScreen(
            successViewTitle: L10n.terminationFlowSuccessTitle,
            successViewBody: isDeletion
                ? L10n.terminateContractTerminationComplete
                : L10n.terminationFlowSuccessSubtitleWithDate((terminationDate)),
            buttons: .init(
                actionButton: nil,
                primaryButton: .init(buttonAction: { [weak vm] in
                    vm?.router.dismiss()
                    vm?.isFlowPresented(.done)
                })
            )
        )
    }

    private func openTerminationFailScreen() -> some View {
        GenericErrorView(
            title: L10n.terminationNotSuccessfulTitle,
            description: L10n.somethingWentWrong
        )
        .hErrorViewButtonConfig(
            .init(
                actionButton: .init(
                    buttonTitle: L10n.openChat,
                    buttonAction: { [weak vm] in
                        vm?.isFlowPresented(.chat)
                    }
                ),
                dismissButton: .init(
                    buttonTitle: L10n.generalCloseButton,
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

//extension TerminationFlowActionWrapper: TrackingViewNameProtocol {
//    var nameForTracking: String {
//        //TODO: fix later
//        return ""
//    }
//}

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
    case terminationDate(config: TerminationConfirmConfig, model: TerminationFlowDateNextStepModel?)
    case surveyStep(model: TerminationFlowSurveyStepModel?)
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
