import Foundation
import Presentation
import SwiftUI
import hCore
import hCoreUI

public class TerminationFlowJourney {

    public static func start(for action: TerminationNavigationAction) -> some JourneyPresentation {
        getScreen(for: .navigationAction(action: action)).hidesBackButton
    }

    @JourneyBuilder
    private static func getScreen(for action: TerminationContractAction) -> some JourneyPresentation {
        if case let .navigationAction(navigationAction) = action {
            if case .openTerminationSuccessScreen = navigationAction {
                let store: TerminationContractStore = globalPresentableStoreContainer.get()
                let terminationDate =
                    store.state.successStep?.terminationDate?.localDateToDate?.displayDateDDMMMYYYYFormat ?? ""
                TerminationFlowJourney.openTerminationSuccessScreen(terminationDate: terminationDate)
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
            } else if case let .openSelectInsuranceScreen(config) = navigationAction {
                openSelectInsuranceScreen(config: config)
            } else if case .openSetTerminationDateLandingScreen = navigationAction {
                let store: TerminationContractStore = globalPresentableStoreContainer.get()
                let fromSelectInsurances = store.state.config?.fromSelectInsurances
                openSetTerminationDateLandingScreen(fromSelectInsurances: fromSelectInsurances ?? false)
            }
        } else if case .dismissTerminationFlow = action {
            withAnimation {
                DismissJourney()
            }
        } else if case .goToFreeTextChat = action {
            withAnimation {
                DismissJourney()
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
                    store.send(.dismissTerminationFlow)
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

    private static func openSetTerminationDateLandingScreen(fromSelectInsurances: Bool) -> some JourneyPresentation {
        HostingJourney(
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
                    if !fromSelectInsurances {
                        tabBarInfoView
                    }
                }
            },
            style: fromSelectInsurances ? .default : .modally(presentationStyle: .overFullScreen)
        ) {
            action in
            getScreen(for: action)
        }
        .withJourneyDismissButton
    }

    private static func openTerminationSuccessScreen(terminationDate: String) -> some JourneyPresentation {
        HostingJourney(
            TerminationContractStore.self,
            rootView: SuccessScreen(
                successViewTitle: "Insurance cancelled",
                successViewBody: L10n.terminateContractConfirmationInfoText(terminationDate),
                successViewButtonAction: {
                    let store: TerminationContractStore = globalPresentableStoreContainer.get()
                    store.send(.dismissTerminationFlow)
                },
                icon: .circularTick
            )
            .hUsePrimaryButton
        ) {
            action in
            getScreen(for: action)
        }
        .hidesBackButton
        .onDismiss {
            @PresentableStore var store: TerminationContractStore
            store.send(.dismissTerminationFlow)
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
                            store.send(.dismissTerminationFlow)
                            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                                store.send(.goToFreeTextChat)
                            }
                        }
                    ),
                    dismissButton: .init(
                        buttonTitle: L10n.generalCloseButton,
                        buttonAction: {
                            let store: TerminationContractStore = globalPresentableStoreContainer.get()
                            store.send(.dismissTerminationFlow)
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
                    store.send(.dismissTerminationFlow)
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
                    if store.state.config?.isDeletion ?? false {
                        store.send(.sendConfirmDelete)
                    } else {
                        store.send(.sendTerminationDate)
                    }
                    store.send(.navigationAction(action: .openTerminationProcessingScreen))
                }
            ),
            style: .detented(.scrollViewContentSize),
            options: [.blurredBackground]
        ) {
            action in
            if case .goBack = action {
                PopJourney()
            } else {
                getScreen(for: action)
            }
        }
        .withJourneyDismissButton
    }

    private static func openSelectInsuranceScreen(config: TerminationContractConfig) -> some JourneyPresentation {
        HostingJourney(
            TerminationContractStore.self,
            rootView: CheckboxPickerScreen<TerminationConfirmConfig>(
                items: {
                    let items = config.contracts.map({
                        (
                            object: $0,
                            displayName: DisplayString(
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
                            activeFrom: selectedContract.activeFrom,
                            fromSelectInsurances: true
                        )
                        store.send(.startTermination(config: config))
                    }
                },
                singleSelect: true,
                attachToBottom: true,
                disableIfNoneSelected: true,
                hButtonText: L10n.generalContinueButton,
                title: L10n.terminationFlowCancellationTitle,
                subTitle: L10n.terminationFlowChooseContractSubtitle,
                fieldSize: .small
            )
            .hUseColoredCheckbox
            .toolbar {
                ToolbarItem(
                    placement: .topBarLeading
                ) {
                    tabBarInfoView
                }
            },
            style: .modally(presentationStyle: .overFullScreen)
        ) {
            action in
            getScreen(for: action)
        }
        .withJourneyDismissButton
    }

    private static var tabBarInfoView: some View {
        InfoViewHolder(
            title: "About cancelling your insurance",
            description:
                "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Suspendisse nec lobortis est. Maecenas fermentum, sapien at venenatis cursus, diam neque tristique nulla, ac tempor purus magna et magna.",
            type: .navigation
        )
        .foregroundColor(hTextColor.primary)
    }
}
