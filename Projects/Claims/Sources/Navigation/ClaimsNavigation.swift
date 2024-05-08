import Combine
import Presentation
import SwiftUI
import hCore
import hCoreUI

public class ClaimsNavigationViewModel: ObservableObject {
    @Published public var isLocationPickerPresented = false
    @Published public var isBrandPickerPresented = false
    @Published public var isPriceInputPresented = false
    @Published public var isDamagePickerPresented = false
    @Published public var isCheckoutTransferringPresented = false
    @Published public var isInfoViewPresented: InfoViewModel?
    @Published public var isClaimFilesPresented: ClaimsFileModel?
}

enum ClaimsRouterActions: Hashable {
    case triagingEntrypoint
    case triagingOption
    case dateOfOccurrancePlusLocation(option: SubmitClaimsNavigationAction.SubmitClaimOption)
    case selectContract
    case phoneNumber(model: FlowClaimPhoneNumberStepModel)
    case audioRecording
    case singleItem
    case summary
    case deflect
    case emergencySelect
    case uploadFiles
    case checkOutNoRepair
}

enum ClaimsRouterActionsWithoutBackButton {
    case success
    case failure
    case updateApp
}

public struct ClaimsNavigation: View {
    @StateObject var router = Router()
    @StateObject var claimsNavigationVm = ClaimsNavigationViewModel()
    var origin: ClaimsOrigin
    @State var cancellable: AnyCancellable?

    public init(
        origin: ClaimsOrigin
    ) {
        self.origin = origin
    }

    public var body: some View {
        RouterHost(router: router, options: [.navigationType(type: .withProgress)]) {
            showClaimEntrypointGroup(origin: origin)
                .routerDestination(for: ClaimsRouterActions.self) { routerAction in
                    switch routerAction {
                    case .triagingEntrypoint:
                        showClaimEntrypointType()
                    case .triagingOption:
                        showClaimEntrypointOption()
                    case let .dateOfOccurrancePlusLocation(option):
                        submitClaimOccurrancePlusLocationScreen(options: option)
                    case .selectContract:
                        openSelectContractScreen()
                    case let .phoneNumber(model):
                        submitClaimPhoneNumberScreen(model: model)
                    case .audioRecording:
                        openAudioRecordingSceen()
                    case .singleItem:
                        openSingleItemScreen()
                    case .summary:
                        openSummaryScreen()
                    case .deflect:
                        openDeflectStepScreen()
                    case .emergencySelect:
                        openEmergencySelectScreen()
                    case .uploadFiles:
                        openFileUploadScreen()
                    case .checkOutNoRepair:
                        openCheckoutNoRepairScreen()
                    }
                }
                .routerDestination(
                    for: ClaimsRouterActionsWithoutBackButton.self,
                    options: .hidesBackButton
                ) { routerAction in
                    switch routerAction {
                    case .failure:
                        showClaimFailureScreen()
                    case .success:
                        openSuccessScreen()
                    case .updateApp:
                        openUpdateAppScreen()
                    }
                }
        }
        .environmentObject(claimsNavigationVm)
        .onAppear {
            let store: SubmitClaimStore = globalPresentableStoreContainer.get()
            cancellable = store.actionSignal.publisher.sink { _ in
            } receiveValue: { action in
                switch action {
                case let .navigationAction(navigationAction):
                    switch navigationAction {
                    case .openTriagingEntrypointScreen:
                        router.push(ClaimsRouterActions.triagingEntrypoint)
                    case .openTriagingOptionScreen:
                        router.push(ClaimsRouterActions.triagingOption)
                    case let .openDateOfOccurrencePlusLocationScreen(option):
                        router.push(ClaimsRouterActions.dateOfOccurrancePlusLocation(option: option))
                    case .openSelectContractScreen:
                        router.push(ClaimsRouterActions.selectContract)
                    case let .openPhoneNumberScreen(model):
                        router.push(ClaimsRouterActions.phoneNumber(model: model))
                    case .openAudioRecordingScreen:
                        router.push(ClaimsRouterActions.audioRecording)
                    case .openSingleItemScreen:
                        router.push(ClaimsRouterActions.singleItem)
                    case .openSummaryScreen:
                        router.push(ClaimsRouterActions.summary)
                    case .openDeflectScreen:
                        router.push(ClaimsRouterActions.deflect)
                    case .openConfirmEmergencyScreen:
                        router.push(ClaimsRouterActions.emergencySelect)
                    case .openFileUploadScreen:
                        router.push(ClaimsRouterActions.uploadFiles)
                    case .openCheckoutNoRepairScreen:
                        router.push(ClaimsRouterActions.checkOutNoRepair)
                    case .openSuccessScreen:
                        router.push(ClaimsRouterActionsWithoutBackButton.success)
                    case .openFailureSceen:
                        router.push(ClaimsRouterActionsWithoutBackButton.failure)
                    case .openUpdateAppScreen:
                        router.push(ClaimsRouterActionsWithoutBackButton.updateApp)
                    default:
                        break
                    }
                default:
                    break
                }
            }
        }
        .detent(
            presented: $claimsNavigationVm.isLocationPickerPresented,
            style: .height
        ) {
            openLocationScreen()
                .embededInNavigation(options: .navigationType(type: .large))
        }
        .detent(
            presented: $claimsNavigationVm.isBrandPickerPresented,
            style: .height
        ) {
            openBrandPickerScreen()
                .routerDestination(
                    for: ClaimFlowItemBrandOptionModel.self
                ) { brandModel in
                    openModelPickerScreen(brand: brandModel)
                }
                .embededInNavigation(options: .navigationType(type: .large))
        }
        .detent(
            presented: $claimsNavigationVm.isPriceInputPresented,
            style: .height
        ) {
            openPriceInputScreen()
                .embededInNavigation(options: .navigationType(type: .large))
        }
        .detent(
            presented: $claimsNavigationVm.isDamagePickerPresented,
            style: .height
        ) {
            openDamagePickerScreen()
                .embededInNavigation(options: .navigationType(type: .large))
        }
        .detent(
            item: $claimsNavigationVm.isInfoViewPresented,
            style: .height
        ) { infoViewModel in
            openInfoView(model: infoViewModel)
        }
        .fullScreenCover(
            isPresented: $claimsNavigationVm.isCheckoutTransferringPresented
        ) {
            openCheckoutTransferringScreen()
        }
        .fullScreenCover(
            item: $claimsNavigationVm.isClaimFilesPresented
        ) { claimsFileModel in
            openFileScreen(model: claimsFileModel)
        }
    }

    private func showClaimEntrypointGroup(origin: ClaimsOrigin) -> some View {
        SelectClaimEntrypointGroup(
            selectedEntrypoints: { entrypoints in
                let store: SubmitClaimStore = globalPresentableStoreContainer.get()
                store.send(.setSelectedEntrypoints(entrypoints: entrypoints))
            })
            .onAppear {
                let store: SubmitClaimStore = globalPresentableStoreContainer.get()
                store.send(.fetchEntrypointGroups)
            }
            .resetProgressToPreviousValueOnDismiss
            .addClaimsProgressBar
            .addDismissClaimsFlow()
    }

    private func showClaimEntrypointType() -> some View {
        SelectClaimEntrypointType(selectedEntrypointOptions: { options, selectedEntrypointId in
            let store: SubmitClaimStore = globalPresentableStoreContainer.get()
            store.send(.setSelectedEntrypointOptions(entrypoints: options, entrypointId: selectedEntrypointId))
        })
        .resetProgressToPreviousValueOnDismiss
        .addDismissClaimsFlow()
    }

    private func showClaimEntrypointOption() -> some View {
        SelectClaimEntrypointOption(
            onButtonClick: { entrypointId, entrypointOptionId in
                let store: SubmitClaimStore = globalPresentableStoreContainer.get()
                store.send(
                    .startClaimRequest(
                        entrypointId: entrypointId,
                        entrypointOptionId: entrypointOptionId
                    )
                )
            })
            .resetProgressToPreviousValueOnDismiss
            .addDismissClaimsFlow()
    }

    private func submitClaimOccurrancePlusLocationScreen(
        options: SubmitClaimsNavigationAction.SubmitClaimOption
    ) -> some View {
        SubmitClaimOccurrencePlusLocationScreen(options: options)
            .resetProgressToPreviousValueOnDismiss
            .withDismissButton()
    }

    private func openSelectContractScreen() -> some View {
        SelectContractScreen()
            .resetProgressToPreviousValueOnDismiss
            .addDismissClaimsFlow()
    }

    private func submitClaimPhoneNumberScreen(model: FlowClaimPhoneNumberStepModel) -> some View {
        SubmitClaimContactScreen(model: model)
            .resetProgressToPreviousValueOnDismiss
            .withDismissButton()
    }

    private func openAudioRecordingSceen() -> some View {
        let store: SubmitClaimStore = globalPresentableStoreContainer.get()
        let url = store.state.audioRecordingStep?.getUrl()
        return SubmitClaimAudioRecordingScreen(url: url)
            .resetProgressToPreviousValueOnDismiss
            .withDismissButton()
    }

    private func openSuccessScreen() -> some View {
        SubmitClaimSuccessScreen()
    }

    private func openSingleItemScreen() -> some View {
        SubmitClaimSingleItem()
            .resetProgressToPreviousValueOnDismiss
            .withDismissButton()
    }

    private func openSummaryScreen() -> some View {
        SubmitClaimSummaryScreen()
            .configureTitle(L10n.Claims.Summary.Screen.title)
            .resetProgressToPreviousValueOnDismiss
            .withDismissButton()
    }

    @ViewBuilder
    private func openDeflectStepScreen() -> some View {
        let store: SubmitClaimStore = globalPresentableStoreContainer.get()
        let model = store.state.deflectStepModel

        Group {
            if model?.id == .FlowClaimDeflectEirStep {
                SubmitClaimCarScreen(model: model)
            } else {
                SubmitClaimDeflectScreen(
                    model: model,
                    openChat: {
                        NotificationCenter.default.post(name: .openChat, object: nil)
                    }
                )
            }
        }
        .resetProgressToPreviousValueOnDismiss
        .addDismissClaimsFlow()
        .configureTitle(model?.id.title ?? "")
    }

    private func openUpdateAppScreen() -> some View {
        UpdateAppScreen(
            onSelected: {
                router.dismiss()
            }
        )
    }

    private func openEmergencySelectScreen() -> some View {
        SumitClaimEmergencySelectScreen(title: {
            let store: SubmitClaimStore = globalPresentableStoreContainer.get()
            return store.state.emergencyConfirm?.text ?? ""
        })
        .resetProgressToPreviousValueOnDismiss
        .addDismissClaimsFlow()
    }

    private func openFileUploadScreen() -> some View {
        let store: SubmitClaimStore = globalPresentableStoreContainer.get()
        return SubmitClaimFilesUploadScreen(model: store.state.fileUploadStep!)
            .addDismissClaimsFlow()
    }

    private func openCheckoutNoRepairScreen() -> some View {
        SubmitClaimCheckoutNoRepairScreen()
            .resetProgressToPreviousValueOnDismiss
            .addDismissClaimsFlow()
            .configureTitle(L10n.Claims.Payout.Summary.title)
    }

    private func showClaimFailureScreen() -> some View {
        GenericErrorView(
            buttons: .init(
                actionButton: .init(
                    buttonAction: {
                        let store: SubmitClaimStore = globalPresentableStoreContainer.get()
                        store.send(.popClaimFlow)
                    }
                ),
                dismissButton: .init(
                    buttonTitle: L10n.openChat,
                    buttonAction: {
                        let store: SubmitClaimStore = globalPresentableStoreContainer.get()
                        store.send(.dissmissNewClaimFlow)
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                            store.send(.submitClaimOpenFreeTextChat)
                        }
                    }
                )
            )
        )
        .withDismissButton()
    }

    private func openLocationScreen() -> some View {
        CheckboxPickerScreen<ClaimFlowLocationOptionModel>(
            items: {
                let store: SubmitClaimStore = globalPresentableStoreContainer.get()
                return store.state.locationStep?.options
                    .compactMap({ (object: $0, displayName: .init(title: $0.displayName)) }) ?? []
            }(),
            preSelectedItems: {
                let store: SubmitClaimStore = globalPresentableStoreContainer.get()
                if let value = store.state.locationStep?.getSelectedOption() {
                    return [value]
                }
                return []
            },
            onSelected: { selectedLocation in
                if let object = selectedLocation.first?.0 {
                    claimsNavigationVm.isLocationPickerPresented = false
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                        let store: SubmitClaimStore = globalPresentableStoreContainer.get()
                        store.send(.setNewLocation(location: object))
                    }
                }
            },
            onCancel: {
                router.dismiss()
            },
            singleSelect: true
        )
        .configureTitle(L10n.Claims.Incident.Screen.location)
    }

    private func openBrandPickerScreen() -> some View {
        BrandPickerView()
            .navigationTitle(L10n.claimsChooseBrandTitle)
    }

    private func openModelPickerScreen(brand: ClaimFlowItemBrandOptionModel) -> some View {
        ModelPickerView(brand: brand)
            .navigationTitle(L10n.claimsChooseModelTitle)
    }

    private func openPriceInputScreen() -> some View {
        PriceInputScreen(onSave: { purchasePrice in
            let store: SubmitClaimStore = globalPresentableStoreContainer.get()
            store.send(.setPurchasePrice(priceOfPurchase: Double(purchasePrice)))
            claimsNavigationVm.isPriceInputPresented = false
        })
        .configureTitle(L10n.submitClaimPurchasePriceTitle)
    }

    private func openDamagePickerScreen() -> some View {
        CheckboxPickerScreen<ClaimFlowItemProblemOptionModel>(
            items: {
                let store: SubmitClaimStore = globalPresentableStoreContainer.get()
                return store.state.singleItemStep?.availableItemProblems
                    .compactMap({ (object: $0, displayName: .init(title: $0.displayName)) }) ?? []
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
                var damages: [String] = []

                for damage in selectedDamages {
                    if let object = damage.0 {
                        damages.append(object.itemProblemId)
                    }
                }
                claimsNavigationVm.isDamagePickerPresented = false
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                    let store: SubmitClaimStore = globalPresentableStoreContainer.get()
                    store.send(
                        .submitDamage(
                            damage: damages
                        )
                    )
                }
            },
            onCancel: {
                router.dismiss()
            }
        )
        .configureTitle(L10n.Claims.Item.Screen.Damage.button)
    }

    private func openCheckoutTransferringScreen() -> some View {
        SubmitClaimCheckoutTransferringScreen()
    }

    private func openInfoView(model: InfoViewModel) -> some View {
        InfoView(
            title: model.title ?? "",
            description: model.description ?? ""
        )
        .resetProgressToPreviousValueOnDismiss
    }

    private func openFileScreen(model: ClaimsFileModel) -> some View {
        ClaimFilesView(endPoint: model.endpoint, files: model.files) { uploadedFiles in
            router.dismiss()
        }
        .withDismissButton()
        .configureTitle(L10n.ClaimStatusDetail.addedFiles)
    }
}

public struct InfoViewModel: Equatable, Identifiable {
    public var id: String?
    let title: String?
    let description: String?
}

public struct ClaimsFileModel: Equatable, Identifiable {
    public var id: String?
    let endpoint: String
    let files: [File]
}

extension View {
    func addDismissClaimsFlow() -> some View {
        self.withDismissButton(
            title: L10n.General.areYouSure,
            message: L10n.Claims.Alert.body,
            confirmButton: L10n.General.yes,
            cancelButton: L10n.General.no
        )
    }

    var resetProgressToPreviousValueOnDismiss: some View {
        let store: SubmitClaimStore = globalPresentableStoreContainer.get()
        let previousProgress = store.state.previousProgress
        return self.onDeinit {
            let store: SubmitClaimStore = globalPresentableStoreContainer.get()
            store.send(.setProgress(progress: previousProgress))
        }
    }
}

#Preview{
    ClaimsNavigation(origin: .generic)
}

extension View {
    func onDeinit(_ execute: @escaping () -> Void) -> some View {
        modifier(OnDeinit(execute: execute))
    }
}

struct OnDeinit: ViewModifier {
    @StateObject var vm = OnDeinitViewModel()
    let execute: () -> Void
    func body(content: Content) -> some View {
        content.onAppear { [weak vm] in
            vm?.execute = execute
        }
    }
}

class OnDeinitViewModel: ObservableObject {
    var execute: (() -> Void)?

    deinit {
        execute?()
    }
}
