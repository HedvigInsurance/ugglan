import Foundation
import Presentation
import hAnalytics
import hCore
import hCoreUI

public class ClaimJourneys {
    @JourneyBuilder
    public static func getScreenForAction(
        for action: SubmitClaimsAction,
        withHidesBack: Bool = false
    ) -> some JourneyPresentation {
        if withHidesBack {
            getScreen(for: action).hidesBackButton
        } else {
            getScreen(for: action).showsBackButton
        }
    }

    @JourneyBuilder
    private static func getScreen(for action: SubmitClaimsAction) -> some JourneyPresentation {
        if case let .navigationAction(navigationAction) = action {
            if case let .openPhoneNumberScreen(model) = navigationAction {
                submitClaimPhoneNumberScreen(model: model).addDismissClaimsFlow()
            } else if case let .openDateOfOccurrencePlusLocationScreen(options) = navigationAction {
                submitClaimOccurrancePlusLocationScreen(options: options).addDismissClaimsFlow()
            } else if case .openAudioRecordingScreen = navigationAction {
                openAudioRecordingSceen().addDismissClaimsFlow()
            } else if case .openSuccessScreen = navigationAction {
                openSuccessScreen()
            } else if case .openSingleItemScreen = navigationAction {
                openSingleItemScreen().addDismissClaimsFlow()
            } else if case .openSummaryScreen = navigationAction {
                openSummaryScreen().addDismissClaimsFlow().configureTitle(L10n.Claims.Summary.Screen.title)
            } else if case .openDamagePickerScreen = navigationAction {
                openDamagePickerScreen().configureTitle(L10n.Claims.Item.Screen.Damage.button)
            } else if case .openCheckoutNoRepairScreen = navigationAction {
                openCheckoutNoRepairScreen().addDismissClaimsFlow()
                    .configureTitle(L10n.Claims.Payout.Summary.title)
            } else if case .openFailureSceen = navigationAction {
                showClaimFailureScreen().withJourneyDismissButton
            } else if case .openSummaryEditScreen = navigationAction {
                openSummaryEditScreen().addDismissClaimsFlow().configureTitle(L10n.Claims.Edit.Screen.title)
            } else if case .openLocationPicker = navigationAction {
                openLocationScreen().configureTitle(L10n.Claims.Incident.Screen.location)
            } else if case .openUpdateAppScreen = navigationAction {
                openUpdateAppTerminationScreen().withJourneyDismissButton
            } else if case .openTriagingEntrypointScreen = navigationAction {
                showClaimEntrypointType().addDismissClaimsFlow()
            } else if case .openTriagingOptionScreen = navigationAction {
                showClaimEntrypointOption().addDismissClaimsFlow()
            } else if case .openSelectContractScreen = navigationAction {
                openSelectContractScreen().addDismissClaimsFlow()
            } else if case .openGlassDamageScreen = navigationAction {
                openGlassDamageScreen().addDismissClaimsFlow().configureTitle(L10n.submitClaimGlassDamageTitle)
            } else if case .openEmergencyScreen = navigationAction {
                openEmergencyScreen().addDismissClaimsFlow().configureTitle(L10n.commonClaimEmergencyTitle)
            } else if case .openConfirmEmergencyScreen = navigationAction {
                openEmergencySelectScreen().addDismissClaimsFlow()
            } else if case .openPestsScreen = navigationAction {
                openPestsScreen().addDismissClaimsFlow().configureTitle(L10n.submitClaimPestsTitle)
            }
        }
    }

    private static func submitClaimPhoneNumberScreen(model: FlowClaimPhoneNumberStepModel) -> some JourneyPresentation {
        HostingJourney(
            SubmitClaimStore.self,
            rootView: SubmitClaimContactScreen(model: model)
        ) { action in
            getScreen(for: action)
        }
        .resetProgressToPreviousValueOnDismiss
    }

    @JourneyBuilder
    private static func openSelectContractScreen() -> some JourneyPresentation {
        HostingJourney(
            SubmitClaimStore.self,
            rootView: SelectContractScreen()
        ) {
            action in
            getScreen(for: action)
        }
        .resetProgressToPreviousValueOnDismiss
    }

    @JourneyBuilder
    private static func openGlassDamageScreen() -> some JourneyPresentation {
        HostingJourney(
            SubmitClaimStore.self,
            rootView: SubmitClaimGlassDamageScreen()
        ) {
            action in
            if case let .navigationAction(action: .openInfoScreen(title, description)) = action {
                openInfoView(title: title, description: description)
            } else {
                getScreen(for: action)
            }
        }
        .resetProgressToPreviousValueOnDismiss
    }

    @JourneyBuilder
    private static func openEmergencySelectScreen() -> some JourneyPresentation {
        HostingJourney(
            SubmitClaimStore.self,
            rootView: SumitClaimEmergencySelectScreen(title: {
                let store: SubmitClaimStore = globalPresentableStoreContainer.get()
                return store.state.emergencyConfirm?.text ?? ""
            })
        ) {
            action in
            getScreen(for: action)
        }
        .resetProgressToPreviousValueOnDismiss
    }

    @JourneyBuilder
    private static func openEmergencyScreen() -> some JourneyPresentation {
        HostingJourney(
            SubmitClaimStore.self,
            rootView: SubmitClaimEmergencyScreen()
        ) {
            action in
            getScreen(for: action)
        }
        .resetProgressToPreviousValueOnDismiss
    }

    @JourneyBuilder
    private static func openPestsScreen() -> some JourneyPresentation {
        HostingJourney(
            SubmitClaimStore.self,
            rootView: SubmitClaimPestsScreen()
        ) {
            action in
            getScreen(for: action)
        }
        .resetProgressToPreviousValueOnDismiss
    }

    @JourneyBuilder
    private static func openInfoView(title: String?, description: String?) -> some JourneyPresentation {
        HostingJourney(
            SubmitClaimStore.self,
            rootView: InfoView(
                title: title ?? "",
                description: description ?? "",
                onDismiss: {}
            ),
            style: .detented(.scrollViewContentSize),
            options: [.blurredBackground]
        ) {
            action in
            if case .navigationAction(action: .dismissScreen) = action {
                PopJourney()
            } else {
                getScreen(for: action)
            }
        }
        .resetProgressToPreviousValueOnDismiss
    }

    @JourneyBuilder
    static func submitClaimOccurrancePlusLocationScreen(
        options: SubmitClaimsNavigationAction.SubmitClaimOption
    ) -> some JourneyPresentation {
        HostingJourney(
            SubmitClaimStore.self,
            rootView: SubmitClaimOccurrencePlusLocationScreen(options: options)
        ) {
            action in
            getScreen(for: action)
        }
        .resetProgressToPreviousValueOnDismiss
    }

    static func openLocationScreen() -> some JourneyPresentation {
        HostingJourney(
            SubmitClaimStore.self,
            rootView: CheckboxPickerScreen<ClaimFlowLocationOptionModel>(
                items: {
                    let store: SubmitClaimStore = globalPresentableStoreContainer.get()
                    return store.state.locationStep?.options
                        .compactMap({ (object: $0, displayName: $0.displayName) }) ?? []
                }(),
                preSelectedItems: {
                    let store: SubmitClaimStore = globalPresentableStoreContainer.get()
                    if let value = store.state.locationStep?.getSelectedOption() {
                        return [value]
                    }
                    return []
                },
                onSelected: { selectedLocation in
                    let store: SubmitClaimStore = globalPresentableStoreContainer.get()
                    if let object = selectedLocation.first?.0 {
                        store.send(.setNewLocation(location: object))
                    }
                },
                onCancel: {
                    let store: SubmitClaimStore = globalPresentableStoreContainer.get()
                    store.send(.navigationAction(action: .dismissScreen))
                },
                singleSelect: true
            ),
            style: .detented(.scrollViewContentSize),
            options: [.largeNavigationBar, .blurredBackground]
        ) {
            action in
            if case .navigationAction(.dismissScreen) = action {
                PopJourney()
            } else if case .setNewLocation = action {
                PopJourney()
            } else {
                getScreen(for: action)
            }
        }
    }

    static func openBrandPickerScreenCheckbox() -> some JourneyPresentation {
        HostingJourney(
            SubmitClaimStore.self,
            rootView: CheckboxPickerScreen<ClaimFlowItemBrandOptionModel>(
                items: {
                    let store: SubmitClaimStore = globalPresentableStoreContainer.get()
                    return store.state.singleItemStep?.availableItemBrandOptions
                        .compactMap({ (object: $0, displayName: $0.displayName) }) ?? []
                }(),
                preSelectedItems: { [] },
                onSelected: { item in
                    let store: SubmitClaimStore = globalPresentableStoreContainer.get()
                    for i in item {
                        if let item = i.0 {
                            store.send(.setItemBrand(brand: item))
                        }
                    }
                },
                singleSelect: true
            ),
            style: .detented(.large),
            options: [.largeNavigationBar]
        ) {
            action in
            if case let .setItemBrand(brand) = action {
                let store: SubmitClaimStore = globalPresentableStoreContainer.get()
                if store.state.singleItemStep?.shouldShowListOfModels(for: brand) ?? false {
                    openModelPickerScreen().configureTitle(L10n.claimsChooseModelTitle)
                } else {
                    PopJourney()
                }
            } else if case .navigationAction(.dismissScreen) = action {
                PopJourney()
            } else {
                getScreen(for: action)
            }
        }
        .onAction(
            SubmitClaimStore.self,
            { action, pre in
                if case .setSingleItemModel(_) = action {
                    pre.bag.dispose()
                } else if case .navigationAction(.dismissScreen) = action {
                    pre.bag.dispose()
                }
            }
        )
    }

    static func openBrandPickerScreen() -> some JourneyPresentation {
        HostingJourney(
            SubmitClaimStore.self,
            rootView: ItemPickerScreen<ClaimFlowItemBrandOptionModel>(
                items: {
                    let store: SubmitClaimStore = globalPresentableStoreContainer.get()
                    return store.state.singleItemStep?.availableItemBrandOptions
                        .compactMap({ (object: $0, displayName: $0.displayName) }) ?? []
                }(),
                onSelected: { item in
                    let store: SubmitClaimStore = globalPresentableStoreContainer.get()
                    store.send(.setItemBrand(brand: item))
                },
                onCancel: {
                    let store: SubmitClaimStore = globalPresentableStoreContainer.get()
                    store.send(.navigationAction(action: .dismissScreen))
                }
            ),
            style: .detented(.large),
            options: [.largeNavigationBar]
        ) {
            action in
            if case let .setItemBrand(brand) = action {
                let store: SubmitClaimStore = globalPresentableStoreContainer.get()
                if store.state.singleItemStep?.shouldShowListOfModels(for: brand) ?? false {
                    openModelPickerScreen().configureTitle(L10n.claimsChooseModelTitle)
                } else {
                    PopJourney()
                }
            } else if case .navigationAction(.dismissScreen) = action {
                PopJourney()
            } else {
                getScreen(for: action)
            }
        }
        .onAction(
            SubmitClaimStore.self,
            { action, pre in
                if case .setSingleItemModel(_) = action {
                    pre.bag.dispose()
                } else if case .navigationAction(.dismissScreen) = action {
                    pre.bag.dispose()
                }
            }
        )
    }

    static func openModelPickerScreen() -> some JourneyPresentation {
        HostingJourney(
            rootView: CheckboxPickerScreen<ClaimFlowItemModelOptionModel>(
                items: {
                    let store: SubmitClaimStore = globalPresentableStoreContainer.get()
                    return store.state.singleItemStep?.getListOfModels()?.compactMap({ ($0, $0.displayName) }) ?? []

                }(),
                preSelectedItems: { return [] },
                onSelected: { item in
                    let store: SubmitClaimStore = globalPresentableStoreContainer.get()
                    if let object = item.first?.0 {
                        store.send(.setSingleItemModel(modelName: object))
                    } else {
                        let model = ClaimFlowItemModelOptionModel(customName: item.first?.1 ?? "")
                        store.send(.setSingleItemModel(modelName: model))
                    }
                },
                onCancel: {
                    let store: SubmitClaimStore = globalPresentableStoreContainer.get()
                    store.send(.navigationAction(action: .dismissScreen))
                },
                singleSelect: true,
                showDividers: true
            ),
            style: .detented(.large, modally: false),
            options: [.wantsGrabber]
        )
    }

    static func openDamagePickerScreen() -> some JourneyPresentation {
        HostingJourney(
            SubmitClaimStore.self,
            rootView: CheckboxPickerScreen<ClaimFlowItemProblemOptionModel>(
                items: {
                    let store: SubmitClaimStore = globalPresentableStoreContainer.get()
                    return store.state.singleItemStep?.availableItemProblems
                        .compactMap({ (object: $0, displayName: $0.displayName) }) ?? []
                }(),
                preSelectedItems: {
                    let store: SubmitClaimStore = globalPresentableStoreContainer.get()
                    if let singleItemStep = store.state.singleItemStep {
                        let preselected = singleItemStep.availableItemProblems
                            .filter { model in
                                singleItemStep.selectedItemProblems?
                                    .contains(where: { item in
                                        model.itemProblemId == item
                                    }) ?? false
                            }
                        return preselected
                    }
                    return []
                },
                onSelected: { selectedDamages in
                    let store: SubmitClaimStore = globalPresentableStoreContainer.get()
                    var damages: [String] = []

                    for damage in selectedDamages {
                        if let object = damage.0 {
                            damages.append(object.itemProblemId)
                        }
                    }
                    store.send(
                        .submitDamage(
                            damage: damages
                        )
                    )
                },
                onCancel: {
                    let store: SubmitClaimStore = globalPresentableStoreContainer.get()
                    store.send(.navigationAction(action: .dismissScreen))
                }
            ),
            style: .detented(.scrollViewContentSize),
            options: [.largeNavigationBar, .blurredBackground]
        ) {
            action in
            if case .navigationAction(.dismissScreen) = action {
                PopJourney()
            } else if case .setSingleItemDamage(_) = action {
                PopJourney()
            } else {
                getScreen(for: action)
            }
        }
    }

    static func openAudioRecordingSceen() -> some JourneyPresentation {
        let store: SubmitClaimStore = globalPresentableStoreContainer.get()
        let url = store.state.audioRecordingStep?.getUrl()
        return HostingJourney(
            SubmitClaimStore.self,
            rootView: SubmitClaimAudioRecordingScreen(url: url)
        ) { action in
            getScreen(for: action)
        }
        .resetProgressToPreviousValueOnDismiss
    }

    private static func openSuccessScreen() -> some JourneyPresentation {
        HostingJourney(
            rootView: SubmitClaimSuccessScreen()
        )
        .hidesBackButton
    }

    @JourneyBuilder
    private static func openSingleItemScreen() -> some JourneyPresentation {
        HostingJourney(
            SubmitClaimStore.self,
            rootView: SubmitClaimSingleItem()
        ) {
            action in
            if case .navigationAction(.openBrandPicker) = action {
                let store: SubmitClaimStore = globalPresentableStoreContainer.get()
                let singleItemStep = store.state.singleItemStep
                let brandsWithModels =
                    singleItemStep?.availableItemBrandOptions
                    .filter({
                        singleItemStep?.shouldShowListOfModels(for: $0) ?? false
                    }) ?? []

                if !brandsWithModels.isEmpty {
                    openBrandPickerScreen().configureTitle(L10n.claimsChooseBrandTitle)
                } else {
                    openBrandPickerScreenCheckbox().configureTitle(L10n.claimsChooseBrandTitle)
                }
            } else if case .navigationAction(.openPriceInput) = action {
                openPriceInputScreen()
            } else {
                getScreen(for: action)
            }
        }
        .resetProgressToPreviousValueOnDismiss
    }

    private static func openPriceInputScreen() -> some JourneyPresentation {
        HostingJourney(
            SubmitClaimStore.self,
            rootView:
                PriceInputScreen(onSave: { purchasePrice in
                    let store: SubmitClaimStore = globalPresentableStoreContainer.get()
                    store.send(.setPurchasePrice(priceOfPurchase: Double(purchasePrice)))
                    store.send(.navigationAction(action: .dismissScreen))
                }),
            style: .detented(.scrollViewContentSize),
            options: [
                .largeNavigationBar, .blurredBackground,
            ]
        ) {
            action in
            if case .navigationAction(.dismissScreen) = action {
                PopJourney()
            } else {
                getScreen(for: action)
            }
        }
        .configureTitle(L10n.submitClaimPurchasePriceTitle)
    }

    private static func openSummaryScreen() -> some JourneyPresentation {
        HostingJourney(
            SubmitClaimStore.self,
            rootView: SubmitClaimSummaryScreen()
        ) {
            action in
            if case .navigationAction(.dismissScreen) = action {
                PopJourney()
            } else {
                getScreen(for: action)
            }
        }
        .resetProgressToPreviousValueOnDismiss
    }

    private static func openCheckoutNoRepairScreen() -> some JourneyPresentation {
        HostingJourney(
            SubmitClaimStore.self,
            rootView: SubmitClaimCheckoutNoRepairScreen()
        ) {
            action in
            if case .navigationAction(.openCheckoutTransferringScreen) = action {
                openCheckoutTransferringScreen()
            } else if case .navigationAction(.dismissScreen) = action {
                PopJourney()
            } else if case .summaryRequest = action {
                openCheckoutTransferringScreen()
            } else {
                getScreenForAction(for: action)
            }
        }
        .resetProgressToPreviousValueOnDismiss
    }

    static func openCheckoutTransferringScreen() -> some JourneyPresentation {
        HostingJourney(
            rootView: SubmitClaimCheckoutTransferringScreen(),
            style: .modally(presentationStyle: .fullScreen, transitionStyle: .crossDissolve)
        )
    }

    private static func openSummaryEditScreen() -> some JourneyPresentation {

        HostingJourney(
            SubmitClaimStore.self,
            rootView: SubmitClaimEditSummaryScreen()
        ) {
            action in
            getScreen(for: action)
        }
        .resetProgressToPreviousValueOnDismiss
    }

    @JourneyBuilder
    public static func showClaimEntrypointGroup(
        origin: ClaimsOrigin
    ) -> some JourneyPresentation {
        HostingJourney(
            SubmitClaimStore.self,
            rootView: SelectClaimEntrypointGroup(
                selectedEntrypoints: { entrypoints in
                    let store: SubmitClaimStore = globalPresentableStoreContainer.get()
                    store.send(.setSelectedEntrypoints(entrypoints: entrypoints))
                }),
            style: .modally(presentationStyle: .overFullScreen),
            options: [.defaults, .withAdditionalSpaceForProgressBar]
        ) { action in
            getScreen(for: action).showsBackButton
        }
        .onPresent {
            let store: SubmitClaimStore = globalPresentableStoreContainer.get()
            store.send(.fetchEntrypointGroups)
        }
        .resetProgressToPreviousValueOnDismiss
        .hidesBackButton
        .addClaimsProgressBar
        .addDismissClaimsFlow()
    }

    @JourneyBuilder
    public static func showClaimEntrypointType() -> some JourneyPresentation {
        HostingJourney(
            SubmitClaimStore.self,
            rootView:
                SelectClaimEntrypointType(selectedEntrypointOptions: { options, selectedEntrypointId in
                    let store: SubmitClaimStore = globalPresentableStoreContainer.get()
                    store.send(.setSelectedEntrypointOptions(entrypoints: options, entrypointId: selectedEntrypointId))
                })
        ) { action in
            getScreen(for: action)
        }
        .resetProgressToPreviousValueOnDismiss
        .showsBackButton
    }

    @JourneyBuilder
    public static func showClaimEntrypointOption() -> some JourneyPresentation {
        HostingJourney(
            SubmitClaimStore.self,
            rootView:
                SelectClaimEntrypointOption(onButtonClick: { entrypointId, entrypointOptionId in
                    let store: SubmitClaimStore = globalPresentableStoreContainer.get()
                    store.send(
                        .startClaimRequest(
                            entrypointId: entrypointId,
                            entrypointOptionId: entrypointOptionId
                        )
                    )
                })
        ) { action in
            getScreen(for: action)
        }
        .resetProgressToPreviousValueOnDismiss
    }

    private static func showClaimFailureScreen() -> some JourneyPresentation {
        HostingJourney(
            rootView: GenericErrorView(
                buttons: .init(
                    actionButton: .init(
                        buttonTitle: L10n.generalCloseButton,
                        buttonAction: {
                            let store: SubmitClaimStore = globalPresentableStoreContainer.get()
                            store.send(.dissmissNewClaimFlow)
                        }
                    ),
                    dismissButton: .init(buttonAction: {
                        let store: SubmitClaimStore = globalPresentableStoreContainer.get()
                        store.send(.dissmissNewClaimFlow)
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                            store.send(.submitClaimOpenFreeTextChat)
                        }
                    })
                )
            )
        )
        .hidesBackButton
    }

    private static func openUpdateAppTerminationScreen() -> some JourneyPresentation {
        HostingJourney(
            SubmitClaimStore.self,
            rootView: UpdateAppScreen(
                onSelected: {
                    let store: SubmitClaimStore = globalPresentableStoreContainer.get()
                    store.send(.dissmissNewClaimFlow)
                }
            )
        ) {
            action in
            getScreen(for: action)
        }
        .hidesBackButton
    }
}

extension JourneyPresentation {
    func addDismissClaimsFlow() -> some JourneyPresentation {
        self.withJourneyDismissButtonWithConfirmation(
            withTitle: L10n.General.areYouSure,
            andBody: L10n.Claims.Alert.body,
            andCancelText: L10n.General.no,
            andConfirmText: L10n.General.yes
        )
    }
}

extension JourneyPresentation {
    var resetProgressToPreviousValueOnDismiss: some JourneyPresentation {
        let store: SubmitClaimStore = globalPresentableStoreContainer.get()
        let previousProgress = store.state.previousProgress
        return self.onDismiss {
            store.send(.setProgress(progress: previousProgress))
        }
    }
}
