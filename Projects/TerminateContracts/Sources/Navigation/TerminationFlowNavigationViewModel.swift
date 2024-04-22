import Combine
import Presentation
import SwiftUI
import hCore
import hCoreUI
import hGraphQL

public class TerminationFlowNavigationViewModel: ObservableObject {
    @Published var isDatePickerPresented = false
    @Published var isConfirmTerminationPresented = false
    @Published var isProcessingPresented = false
}

enum TerminationFlowRouterActions {
    case success
    case fail
    case updateApp
}

public enum DismissTerminationAction {
    case none
    case chat
    case openFeedback(url: URL)
}

public struct TerminationFlowNavigation: View {
    @StateObject private var terminationFlowVm = TerminationFlowNavigationViewModel()
    let configs: [TerminationConfirmConfig]
    @StateObject var router = Router()
    private var isFlowPresented: (DismissTerminationAction) -> Void
    @State var cancellable: AnyCancellable?

    public init(
        configs: [TerminationConfirmConfig],
        isFlowPresented: @escaping (DismissTerminationAction) -> Void
    ) {
        self.configs = configs
        self.isFlowPresented = isFlowPresented
    }

    public var body: some View {
        RouterHost(router: router) {
            Group {
                if configs.count == 1, let config = configs.first {
                    openSetTerminationDateLandingScreen(config: config, fromSelectInsurance: false)
                } else {
                    openSelectInsuranceScreen()
                        .routerDestination(for: TerminationConfirmConfig.self) { config in
                            openSetTerminationDateLandingScreen(config: config, fromSelectInsurance: false)
                        }
                }
            }
            .routerDestination(
                for: TerminationFlowRouterActions.self,
                options: .hidesBackButton
            ) { action in
                switch action {
                case .success:
                    let store: TerminationContractStore = globalPresentableStoreContainer.get()
                    let terminationDate =
                        store.state.successStep?.terminationDate?.localDateToDate?.displayDateDDMMMYYYYFormat ?? ""
                    openTerminationSuccessScreen(isDeletion: store.state.isDeletion, terminationDate: terminationDate)
                        .onAppear {
                            terminationFlowVm.isProcessingPresented = false
                        }
                case .fail:
                    openTerminationFailScreen()
                        .onAppear {
                            terminationFlowVm.isProcessingPresented = false
                        }
                case .updateApp:
                    openUpdateAppTerminationScreen()
                }
            }
        }
        .environmentObject(terminationFlowVm)
        .onAppear {
            let store: TerminationContractStore = globalPresentableStoreContainer.get()
            cancellable = store.actionSignal.publisher.sink { _ in
            } receiveValue: { action in
                switch action {
                case let .navigationAction(navigationAction):
                    switch navigationAction {
                    case .openTerminationSuccessScreen:
                        router.push(TerminationFlowRouterActions.success)
                    case .openTerminationFailScreen:
                        router.push(TerminationFlowRouterActions.fail)
                    case .openTerminationUpdateAppScreen:
                        router.push(TerminationFlowRouterActions.updateApp)
                    }
                default:
                    break
                }
            }
        }
        .detent(
            presented: $terminationFlowVm.isDatePickerPresented,
            style: .height
        ) {
            openSetTerminationDatePickerScreen()
                .environmentObject(terminationFlowVm)
        }
        .detent(
            presented: $terminationFlowVm.isConfirmTerminationPresented,
            style: .height
        ) {
            openConfirmTerminationScreen()
                .environmentObject(terminationFlowVm)
        }
        .fullScreenCover(isPresented: $terminationFlowVm.isProcessingPresented) {
            openProgressScreen()
        }
    }

    private func openSetTerminationDateLandingScreen(
        config: TerminationConfirmConfig,
        fromSelectInsurance: Bool
    ) -> some View {
        SetTerminationDateLandingScreen(
            onSelected: {
                terminationFlowVm.isConfirmTerminationPresented = true
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
        .onAppear {
            let store: TerminationContractStore = globalPresentableStoreContainer.get()
            store.send(.startTermination(config: config))
        }
    }

    private func openSelectInsuranceScreen() -> some View {
        CheckboxPickerScreen<TerminationConfirmConfig>(
            items: {
                let items = configs.map({
                    (
                        object: $0,
                        displayName: CheckboxItemModel(
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
                    router.push(config)
                }
            },
            singleSelect: true,
            attachToBottom: true,
            disableIfNoneSelected: true,
            hButtonText: L10n.generalContinueButton,
            fieldSize: .small
        )
        .hFormTitle(
            title: .init(.small, .title3, L10n.terminationFlowTitle, alignment: .leading),
            subTitle: .init(.small, .title3, L10n.terminationFlowBody)
        )
        .withDismissButton()
        .hUseColoredCheckbox
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
                isFlowPresented(.none)
            }
        )
        .withDismissButton()
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
                terminationFlowVm.isProcessingPresented = true
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
                terminationFlowVm.isDatePickerPresented = false
            },
            terminationDate: {
                let store: TerminationContractStore = globalPresentableStoreContainer.get()
                let preSelectedTerminationDate = store.state.terminationDateStep?.minDate.localDateToDate
                return preSelectedTerminationDate ?? Date()
            }
        )
        .navigationTitle(L10n.setTerminationDateText)
        .embededInNavigation(options: [.navigationType(type: .large)])
    }

    private func openProgressScreen() -> some View {
        ProcessingView<TerminationContractStore>(
            showSuccessScreen: false,
            TerminationContractStore.self,
            loading: .sendTerminationDate,
            loadingViewText: L10n.terminateContractTerminatingProgress,
            onErrorCancelAction: {
                isFlowPresented(.none)
            }
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
                primaryButton: .init(buttonAction: {
                    isFlowPresented(.none)
                }),
                ghostButton: .init(
                    buttonTitle: L10n.terminationFlowShareFeedback,
                    buttonAction: {
                        log.addUserAction(type: .click, name: "terminationSurvey")
                        let store: TerminationContractStore = globalPresentableStoreContainer.get()
                        if let surveyToURL = URL(string: store.state.successStep?.surveyUrl) {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                                isFlowPresented(.openFeedback(url: surveyToURL))
                            }
                        }
                    }
                )
            ),
            icon: .circularTick
        )
    }

    private func openTerminationFailScreen() -> some View {
        GenericErrorView(
            title: L10n.terminationNotSuccessfulTitle,
            description: L10n.somethingWentWrong,
            icon: .triangle,
            buttons: .init(
                actionButton: .init(
                    buttonTitle: L10n.openChat,
                    buttonAction: {
                        isFlowPresented(.chat)
                    }
                ),
                dismissButton: .init(
                    buttonTitle: L10n.generalCloseButton,
                    buttonAction: {
                        isFlowPresented(.none)
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
        .foregroundColor(hTextColor.primary)
    }
}
