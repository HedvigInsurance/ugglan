import Foundation
import Presentation
import SwiftUI
import hCore
import hCoreUI
import hGraphQL

public class TerminationFlowJourney {

    @JourneyBuilder
    public static func start(
        for configs: [TerminationConfirmConfig],
        onDismissing: @escaping (_ success: Bool) -> Void
    ) -> some JourneyPresentation {
        GroupJourney {
            if configs.count == 1, let config = configs.first {
                openSetTerminationDateLandingScreen(config: config, style: .modally(presentationStyle: .overFullScreen))
            } else {
                openSelectInsuranceScreen(configs: configs)
            }
        }
        .onAction(TerminationContractStore.self) { action, pre in
            if case let .dismissTerminationFlow(success) = action {
                pre.viewController.dismiss(animated: true) {
                    pre.bag.dispose()
                    onDismissing(success)
                }
            } else if case .goToFreeTextChat = action {
                pre.viewController.dismiss(animated: true) {
                    pre.bag.dispose()
                    onDismissing(false)
                }
            }
        }
    }

    @JourneyBuilder
    private static func getScreen(for action: TerminationContractAction) -> some JourneyPresentation {
        if case let .navigationAction(navigationAction) = action {
            if case .openTerminationSuccessScreen = navigationAction {
                let store: TerminationContractStore = globalPresentableStoreContainer.get()
                let terminationDate =
                    store.state.successStep?.terminationDate?.localDateToDate?.displayDateDDMMMYYYYFormat ?? ""
                TerminationFlowJourney.openTerminationSuccessScreen(
                    isDeletion: store.state.isDeletion,
                    terminationDate: terminationDate
                )
            } else if case .openTerminationDatePickerScreen = navigationAction {
                TerminationFlowJourney.openSetTerminationDatePickerScreen()
            } else if case .openTerminationFailScreen = navigationAction {
                TerminationFlowJourney.openTerminationFailScreen()
            } else if case .openTerminationUpdateAppScreen = navigationAction {
                TerminationFlowJourney.openUpdateAppTerminationScreen()
            } else if case .openConfirmTerminationScreen = navigationAction {
                TerminationFlowJourney.openConfirmTerminationScreen()
            } else if case .openTerminationProcessingScreen = navigationAction {
                openProgressScreen()
            } else if case let .openSelectInsuranceScreen(configs) = navigationAction {
                openSelectInsuranceScreen(configs: configs)
            } else if case let .openSetTerminationDateLandingScreen(config) = navigationAction {
                openSetTerminationDateLandingScreen(config: config)
            }
        }
    }

    @JourneyBuilder
    private static func openProgressScreen() -> some JourneyPresentation {
        HostingJourney(
            TerminationContractStore.self,
            rootView: ProcessingView<TerminationContractStore>(
                showSuccessScreen: false,
                TerminationContractStore.self,
                loading: .sendTerminationDate,
                loadingViewText: L10n.terminateContractTerminatingProgress,
                onErrorCancelAction: {
                    let store: TerminationContractStore = globalPresentableStoreContainer.get()
                    store.send(.dismissTerminationFlow(afterCancellationFinished: false))
                }
            ),
            style: .modally(presentationStyle: .overFullScreen)
        ) { action in
            getScreen(for: action)
        }
        .hidesBackButton
    }

    private static func openSetTerminationDatePickerScreen() -> some JourneyPresentation {
        HostingJourney(
            TerminationContractStore.self,
            rootView: SetTerminationDate(
                onSelected: {
                    terminationDate in
                    let store: TerminationContractStore = globalPresentableStoreContainer.get()
                    store.send(.setTerminationDate(terminationDate: terminationDate))
                    store.send(.goBack)
                },
                terminationDate: {
                    let store: TerminationContractStore = globalPresentableStoreContainer.get()
                    let preSelectedTerminationDate = store.state.terminationDateStep?.minDate.localDateToDate
                    return preSelectedTerminationDate ?? Date()
                }
            ),
            style: .detented(.scrollViewContentSize),
            options: [.largeNavigationBarWithoutGrabber, .blurredBackground]
        ) {
            action in
            if case .goBack = action {
                PopJourney()
            } else {
                getScreen(for: action)
            }
        }
        .configureTitle(L10n.setTerminationDateText)
    }

    private static func openSetTerminationDateLandingScreen(
        config: TerminationConfirmConfig,
        style: PresentationStyle = .default
    ) -> some JourneyPresentation {
        return HostingJourney(
            TerminationContractStore.self,
            rootView: SetTerminationDateLandingScreen(
                onSelected: {
                    let store: TerminationContractStore = globalPresentableStoreContainer.get()
                    store.send(.navigationAction(action: .openConfirmTerminationScreen))
                }
            )
            .toolbar {
                ToolbarItem(
                    placement: .topBarLeading
                ) {
                    if style.name != PresentationStyle.default.name {
                        tabBarInfoView
                    }
                }
            },
            style: style
        ) {
            action in
            if case let .navigationAction(navigationAction) = action {
                if case .openTerminationProcessingScreen = navigationAction {
                    ContinueJourney()
                } else if case .openTerminationSuccessScreen = navigationAction {
                    ContinueJourney()
                } else {
                    getScreen(for: action)
                }
            }
        }
        .onPresent {
            let store: TerminationContractStore = globalPresentableStoreContainer.get()
            store.send(.startTermination(config: config))
        }
        .withJourneyDismissButton
    }

    private static func openTerminationSuccessScreen(
        isDeletion: Bool,
        terminationDate: String
    ) -> some JourneyPresentation {
        HostingJourney(
            TerminationContractStore.self,
            rootView: SuccessScreen(
                successViewTitle: L10n.terminationFlowSuccessTitle,
                successViewBody: isDeletion
                    ? L10n.terminationFlowSuccessSubtitleWithoutDate
                    : L10n.terminationFlowSuccessSubtitleWithDate((terminationDate)),
                buttons: .init(
                    primaryButton: .init(buttonAction: {
                        let store: TerminationContractStore = globalPresentableStoreContainer.get()
                        store.send(.dismissTerminationFlow(afterCancellationFinished: true))
                    }),
                    ghostButton: .init(
                        buttonTitle: "Share feedback",
                        buttonAction: {
                            log.addUserAction(type: .click, name: "terminationSurvey")
                            let store: TerminationContractStore = globalPresentableStoreContainer.get()
                            if let surveyToURL = URL(string: store.state.successStep?.surveyUrl) {
                                store.send(.dismissTerminationFlow(afterCancellationFinished: true))
                                DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                                    store.send(.goToUrl(url: surveyToURL))
                                }
                            }
                        }
                    )
                ),
                icon: .circularTick
            )
        ) {
            action in
            getScreen(for: action)
        }
        .hidesBackButton
        .onDismiss {
            @PresentableStore var store: TerminationContractStore
            store.send(.dismissTerminationFlow(afterCancellationFinished: true))
        }
    }

    private static func openTerminationFailScreen() -> some JourneyPresentation {
        HostingJourney(
            TerminationContractStore.self,
            rootView: GenericErrorView(
                title: L10n.terminationNotSuccessfulTitle,
                description: L10n.somethingWentWrong,
                icon: .triangle,
                buttons: .init(
                    actionButton: .init(
                        buttonTitle: L10n.openChat,
                        buttonAction: {
                            let store: TerminationContractStore = globalPresentableStoreContainer.get()
                            store.send(.dismissTerminationFlow(afterCancellationFinished: false))
                            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                                store.send(.goToFreeTextChat)
                            }
                        }
                    ),
                    dismissButton: .init(
                        buttonTitle: L10n.generalCloseButton,
                        buttonAction: {
                            let store: TerminationContractStore = globalPresentableStoreContainer.get()
                            store.send(.dismissTerminationFlow(afterCancellationFinished: false))
                        }
                    )
                )
            )
        ) {
            action in
            getScreen(for: action)
        }
        .hidesBackButton
    }

    private static func openUpdateAppTerminationScreen() -> some JourneyPresentation {
        HostingJourney(
            TerminationContractStore.self,
            rootView: UpdateAppScreen(
                onSelected: {
                    let store: TerminationContractStore = globalPresentableStoreContainer.get()
                    store.send(.dismissTerminationFlow(afterCancellationFinished: false))
                }
            ),
            style: .detented(.large, modally: true)
        ) {
            action in
            getScreen(for: action)
        }
        .withJourneyDismissButton
        .hidesBackButton
    }

    private static func openConfirmTerminationScreen() -> some JourneyPresentation {
        HostingJourney(
            TerminationContractStore.self,
            rootView: ConfirmTerminationScreen(
                onSelected: {
                    let store: TerminationContractStore = globalPresentableStoreContainer.get()
                    if store.state.isDeletion {
                        store.send(.sendConfirmDelete)
                    } else {
                        store.send(.sendTerminationDate)
                    }
                    store.send(.navigationAction(action: .openTerminationProcessingScreen))
                }
            ),
            style: .detented(.scrollViewContentSize),
            options: [.blurredBackground]
        ) { action in
            if case .goBack = action {
                PopJourney()
            } else {
                getScreen(for: action)
            }
        }
        .withJourneyDismissButton
    }

    private static func openSelectInsuranceScreen(configs: [TerminationConfirmConfig]) -> some JourneyPresentation {
        HostingJourney(
            TerminationContractStore.self,
            rootView: CheckboxPickerScreen<TerminationConfirmConfig>(
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
                    let store: TerminationContractStore = globalPresentableStoreContainer.get()
                    if let selectedContract = selected.first?.0 {
                        let config = TerminationConfirmConfig(
                            contractId: selectedContract.contractId,
                            contractDisplayName: selectedContract.contractDisplayName,
                            contractExposureName: selectedContract.contractExposureName,
                            activeFrom: selectedContract.activeFrom
                        )
                        store.send(.navigationAction(action: .openSetTerminationDateLandingScreen(with: config)))
                    }
                },
                singleSelect: true,
                attachToBottom: true,
                disableIfNoneSelected: true,
                hButtonText: L10n.generalContinueButton,
                title: L10n.terminationFlowCancellationTitle,
                subTitle: L10n.terminationFlowChooseContractSubtitle
            )
            .hUseColoredCheckbox
            .hFieldSize(.small)
            .toolbar {
                ToolbarItem(
                    placement: .topBarLeading
                ) {
                    tabBarInfoView
                }
            },
            style: .modally(presentationStyle: .overFullScreen)
        ) { action in
            getScreen(for: action)
        }
        .withJourneyDismissButton
    }

    private static var tabBarInfoView: some View {
        InfoViewHolder(
            title: L10n.terminationFlowCancelInfoTitle,
            description: L10n.terminationFlowCancelInfoText,
            type: .navigation
        )
        .foregroundColor(hTextColor.primary)
    }
}
