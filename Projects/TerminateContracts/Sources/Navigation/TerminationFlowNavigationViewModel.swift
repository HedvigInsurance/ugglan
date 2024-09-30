import Combine
import PresentableStore
import SwiftUI
import hCore
import hCoreUI
import hGraphQL

class TerminationFlowNavigationViewModel: ObservableObject {
    @Published var isDatePickerPresented = false
    @Published var isConfirmTerminationPresented = false
    @Published var isProcessingPresented = false
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
            case .changeTierFoundBetterPrice:
                break
            case .changeTierMissingCoverageAndTerms:
                break
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
    var cancellable: AnyCancellable?

    init() {}

}

struct TerminationFlowNavigation: View {
    @StateObject private var vm = TerminationFlowNavigationViewModel()
    let configs: [TerminationConfirmConfig]
    let initialStep: TerminationFlowActions
    private var isFlowPresented: (DismissTerminationAction) -> Void

    public init(
        initialStep: TerminationFlowActions,
        configs: [TerminationConfirmConfig],
        isFlowPresented: @escaping (DismissTerminationAction) -> Void
    ) {
        self.initialStep = initialStep
        self.configs = configs
        self.isFlowPresented = isFlowPresented
    }

    public var body: some View {
        RouterHost(router: vm.router, tracking: initialStep) {
            getView(for: initialStep)
                .routerDestination(for: [TerminationFlowSurveyStepModelOption].self) { options in
                    TerminationSurveyScreen(vm: .init(options: options, subtitleType: .generic))
                }
                .routerDestination(for: TerminationFlowRouterActions.self) { action in
                    switch action {
                    case let .terminationDate(config):
                        openSetTerminationDateLandingScreen(config: config, fromSelectInsurance: false)
                    case let .surveyStep(options, type):
                        openSurveyScreen(options: options, subtitleType: type)
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
                        let store: TerminationContractStore = globalPresentableStoreContainer.get()
                        let terminationDate =
                            store.state.successStep?.terminationDate?.localDateToDate?.displayDateDDMMMYYYYFormat ?? ""
                        openTerminationSuccessScreen(
                            isDeletion: store.state.isDeletion,
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
        .environmentObject(vm)
        .onAppear { [weak vm] in
            let store: TerminationContractStore = globalPresentableStoreContainer.get()
            vm?.cancellable = store.actionSignal
                .receive(on: RunLoop.main)
                .sink { _ in
                } receiveValue: { [weak vm] action in
                    switch action {
                    case let .navigationAction(navigationAction):
                        switch navigationAction {
                        case .openTerminationSuccessScreen:
                            vm?.router.push(TerminationFlowFinalRouterActions.success)
                        case .openTerminationFailScreen:
                            vm?.router.push(TerminationFlowFinalRouterActions.fail)
                        case .openTerminationUpdateAppScreen:
                            vm?.router.push(TerminationFlowFinalRouterActions.updateApp)
                        case .openTerminationSurveyStep(let options, let type):
                            vm?.router
                                .push(TerminationFlowRouterActions.surveyStep(options: options, subtitleType: type))
                        case let .openSetTerminationDateLandingScreen(config):
                            vm?.router.push(TerminationFlowRouterActions.terminationDate(config: config))
                        }
                    default:
                        break
                    }
                }
        }
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
    }

    @ViewBuilder
    private func getView(for action: TerminationFlowActions) -> some View {
        switch action {
        case let .router(action):
            switch action {
            case let .terminationDate(config):
                openSetTerminationDateLandingScreen(config: config, fromSelectInsurance: false)
            case let .surveyStep(options, type):
                openSurveyScreen(options: options, subtitleType: type)
            case .selectInsurance:
                openSelectInsuranceScreen()
            }
        case let .final(action):
            switch action {
            case .success:
                let store: TerminationContractStore = globalPresentableStoreContainer.get()
                let terminationDate =
                    store.state.successStep?.terminationDate?.localDateToDate?.displayDateDDMMMYYYYFormat ?? ""
                openTerminationSuccessScreen(
                    isDeletion: store.state.isDeletion,
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
                        //                    vm.router.push(config)
                        let store: TerminationContractStore = globalPresentableStoreContainer.get()
                        store.send(.startTermination(config: config))
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
        .hFieldSize(.small)
        .toolbar {
            ToolbarItem(
                placement: .topBarLeading
            ) {
                tabBarInfoView
            }
        }
        .trackLoading(TerminationContractStore.self, action: .getInitialStep)
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
        options: [TerminationFlowSurveyStepModelOption],
        subtitleType: SurveyScreenSubtitleType
    ) -> some View {
        let vm = SurveyScreenViewModel(options: options, subtitleType: subtitleType)
        return TerminationSurveyScreen(vm: vm).withDismissButton()
    }

    private func openConfirmTerminationScreen() -> some View {
        ConfirmTerminationScreen(
            onSelected: {
                let store: TerminationContractStore = globalPresentableStoreContainer.get()
                if store.state.isDeletion {
                    store.send(.sendConfirmDelete)
                } else {
                    store.send(.sendTerminationDate)
                }
                vm.isProcessingPresented = true
            }
        )
        .withDismissButton()
    }

    private func openSetTerminationDatePickerScreen() -> some View {
        SetTerminationDate(
            onSelected: {
                terminationDate in
                let store: TerminationContractStore = globalPresentableStoreContainer.get()
                store.send(.setTerminationDate(terminationDate: terminationDate))
                vm.isDatePickerPresented = false
            },
            terminationDate: {
                let store: TerminationContractStore = globalPresentableStoreContainer.get()
                let preSelectedTerminationDate = store.state.terminationDateStep?.minDate.localDateToDate
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
                    isFlowPresented(.done)
                })
                //                ,
                //                ghostButton: .init(
                //                    buttonTitle: L10n.terminationFlowShareFeedback,
                //                    buttonAction: { [weak router] in
                //                        router?.dismiss()
                //                        log.addUserAction(type: .click, name: "terminationSurvey")
                //                        let store: TerminationContractStore = globalPresentableStoreContainer.get()
                //                        if let surveyToURL = URL(string: store.state.successStep?.surveyUrl) {
                //                            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                //                                isFlowPresented(.openFeedback(url: surveyToURL))
                //                            }
                //                        }
                //                    }
                //                )
            )
        )
    }

    private func openTerminationFailScreen() -> some View {
        GenericErrorView(
            title: L10n.terminationNotSuccessfulTitle,
            description: L10n.somethingWentWrong,
            buttons: .init(
                actionButton: .init(
                    buttonTitle: L10n.openChat,
                    buttonAction: {
                        isFlowPresented(.chat)
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

extension View {
    public func handleTerminateInsurance(
        vm: TerminateInsuranceViewModel,
        onDismiss: @escaping (DismissTerminationAction) -> Void
    ) -> some View {
        modifier(TerminateInsurance(vm: vm, onDismiss: onDismiss))

    }
}

struct TerminateInsurance: ViewModifier {
    @ObservedObject var vm: TerminateInsuranceViewModel
    let onDismiss: (DismissTerminationAction) -> Void
    func body(content: Content) -> some View {
        content
            .modally(
                item: $vm.initialStep,
                options: .constant(.alwaysOpenOnTop)
            ) { item in

                TerminationFlowNavigation(
                    initialStep: item.action,
                    configs: vm.configs,
                    isFlowPresented: { dismissType in
                        onDismiss(dismissType)
                    }
                )
            }
    }
}

public class TerminateInsuranceViewModel: ObservableObject {
    @Published var initialStep: TerminationFlowActionWrapper?
    var configs: [TerminationConfirmConfig] = []
    private var firstStepCancellable: AnyCancellable?
    public init() {}

    public func start(with configs: [TerminationConfirmConfig]) {
        self.configs = configs
        if configs.count > 1 {
            self.initialStep = .init(action: .router(action: .selectInsurance(configs: configs)))
        } else if let config = configs.first {
            let store: TerminationContractStore = globalPresentableStoreContainer.get()
            firstStepCancellable = store.actionSignal
                .receive(on: RunLoop.main)
                .sink { _ in
                } receiveValue: { [weak self] action in
                    switch action {
                    case let .navigationAction(navigationAction):
                        switch navigationAction {
                        case .openTerminationSuccessScreen:
                            self?.initialStep = .init(action: .final(action: .success))
                        case .openTerminationFailScreen:
                            self?.initialStep = .init(action: .final(action: .fail))
                        case .openTerminationUpdateAppScreen:
                            self?.initialStep = .init(action: .final(action: .updateApp))
                        case let .openTerminationSurveyStep(options, type):
                            self?.initialStep = .init(
                                action: .router(action: .surveyStep(options: options, subtitleType: type))
                            )
                        case let .openSetTerminationDateLandingScreen(config):
                            self?.initialStep = .init(action: .router(action: .terminationDate(config: config)))
                        }
                        self?.firstStepCancellable = nil
                    default:
                        break
                    }
                }
            store.send(.startTermination(config: config))
        }
    }
}

struct TerminationFlowActionWrapper: Identifiable, Equatable {
    var id = UUID().uuidString
    let action: TerminationFlowActions
}

enum TerminationFlowActions: Hashable {
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
    var nameForTracking: String {
        switch self {
        case .router(let action):
            return action.nameForTracking
        case .final(let action):
            return action.nameForTracking
        }
    }
}

enum TerminationFlowRouterActions: Hashable {
    case selectInsurance(configs: [TerminationConfirmConfig])
    case terminationDate(config: TerminationConfirmConfig)
    case surveyStep(options: [TerminationFlowSurveyStepModelOption], subtitleType: SurveyScreenSubtitleType)
}

extension TerminationFlowRouterActions: TrackingViewNameProtocol {
    var nameForTracking: String {
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

enum TerminationFlowFinalRouterActions: Hashable {
    case success
    case fail
    case updateApp
}

extension TerminationFlowFinalRouterActions: TrackingViewNameProtocol {
    var nameForTracking: String {
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
}
