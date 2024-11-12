import Combine
import PresentableStore
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

    @Published var selectClaimEntrypointVm = SelectClaimEntrypointViewModel()
    @Published var claimEntrypoints: [ClaimEntryPointResponseModel] = []
    @Published var entrypoints: EntrypointState = .init()

    @Published var currentClaimContext: String?

    @Published var progress: Float?
    @Published var previousProgress: Float?

    @Published var occurrencePlusLocationModel: SubmitClaimStep.DateOfOccurrencePlusLocationStepModels?
    @Published var singleItemModel: FlowClamSingleItemStepModel?
    @Published var summaryModel: SubmitClaimStep.SummaryStepModels?
    @Published var phoneNumberModel: FlowClaimPhoneNumberStepModel?
    @Published var singleItemCheckoutModel: FlowClaimSingleItemCheckoutStepModel?
    @Published var successModel: FlowClaimSuccessStepModel?
    @Published var failedModel: FlowClaimFailedStepModel?
    @Published var audioRecordingModel: FlowClaimAudioRecordingStepModel?
    @Published var contractSelectModel: FlowClaimContractSelectStepModel?
    @Published var fileUploadModel: FlowClaimFileUploadStepModel?
    @Published var deflectStepModel: FlowClaimDeflectStepModel?
    @Published var emergencyConfirmModel: FlowClaimConfirmEmergencyStepModel?

    @Published var submitClaimCheckoutVm = SubmitClaimCheckoutViewModel()

    @Published var currentClaimId: String? {
        didSet {
            do {
                var isDir: ObjCBool = true
                if FileManager.default.fileExists(
                    atPath: claimsAudioRecordingRootPath.relativePath,
                    isDirectory: &isDir
                ) {
                    let content = try FileManager.default
                        .contentsOfDirectory(atPath: claimsAudioRecordingRootPath.relativePath)
                        .filter({ URL(string: $0)?.pathExtension == AudioRecorder.audioFileExtension })
                    try content.forEach({
                        try FileManager.default.removeItem(
                            atPath: claimsAudioRecordingRootPath.appendingPathComponent($0).relativePath
                        )
                    })
                } else {
                    try FileManager.default.createDirectory(
                        at: claimsAudioRecordingRootPath,
                        withIntermediateDirectories: true
                    )
                }
            } catch _ {}
        }
    }

    var claimAudioRecordingPath: URL {
        let nameOfFile: String = {
            if let currentClaimId, currentClaimId.isEmpty {
                return "audio-file-recoding"
            }
            return currentClaimId ?? ""
        }()
        let audioPath =
            claimsAudioRecordingRootPath
            .appendingPathComponent(nameOfFile)
            .appendingPathExtension(AudioRecorder.audioFileExtension)
        return audioPath
    }

    private var claimsAudioRecordingRootPath: URL {
        let tempDirectory = FileManager.default.temporaryDirectory
        let claimsAudioRecoringPath =
            tempDirectory
            .appendingPathComponent("claims")
        return claimsAudioRecoringPath
    }

    var router = Router()

    @Inject private var submitClaimService: SubmitClaimClient

    func startClaimRequest(entrypointId: String?, entrypointOptionId: String?) async {
        await reset()
        Task { @MainActor in
            do {
                let data = try await submitClaimService.startClaim(
                    entrypointId: entrypointId,
                    entrypointOptionId: entrypointOptionId
                )
                navigate(data: data)
            }
        }
    }

    @MainActor
    func reset() {
        currentClaimContext = nil
        occurrencePlusLocationModel = nil
        singleItemModel = nil
        summaryModel = nil
        phoneNumberModel = nil
        singleItemCheckoutModel = nil
        successModel = nil
        failedModel = nil
        audioRecordingModel = nil
        contractSelectModel = nil
        fileUploadModel = nil
    }

    func navigate(data: SubmitClaimStepResponse) {
        currentClaimContext = data.context
        currentClaimId = data.claimId
        switch data.step {
        case let .setDateOfOccurrencePlusLocation(model):
            occurrencePlusLocationModel = model
            router.push(ClaimsRouterActions.dateOfOccurrancePlusLocation)
        case let .setDateOfOccurence(model):
            occurrencePlusLocationModel = .init(dateOfOccurencePlusLocationModel: nil, dateOfOccurrenceModel: model)
            router.push(ClaimsRouterActions.dateOfOccurrancePlusLocation)
        case let .setPhoneNumber(model):
            phoneNumberModel = model
            router.push(ClaimsRouterActions.phoneNumber(model: model))
        case let .setAudioStep(model):
            audioRecordingModel = model
            router.push(ClaimsRouterActions.audioRecording)
        case let .setSingleItem(model):
            singleItemModel = model
            router.push(ClaimsRouterActions.singleItem)
        case let .setLocation(model):
            occurrencePlusLocationModel = .init(dateOfOccurencePlusLocationModel: nil, locationModel: model)
            router.push(ClaimsRouterActions.dateOfOccurrancePlusLocation)
        case let .setSummaryStep(model):
            summaryModel = model
            router.push(ClaimsRouterActions.summary)
        case let .setSingleItemCheckoutStep(model):
            singleItemCheckoutModel = model
            router.push(ClaimsRouterActions.checkOutNoRepair)
            progress = nil
        case .setSuccessStep:
            router.push(ClaimsRouterActionsWithoutBackButton.success)
            progress = nil
        case .setFailedStep:
            router.push(ClaimsRouterActionsWithoutBackButton.failure)
            progress = nil
        case let .setContractSelectStep(model):
            contractSelectModel = model
            router.push(ClaimsRouterActions.selectContract)
        case let .setConfirmDeflectEmergencyStepModel(model):
            emergencyConfirmModel = model
            router.push(ClaimsRouterActions.emergencySelect(model: model))
        case let .setDeflectModel(model):
            deflectStepModel = model
            router.push(ClaimsRouterActions.deflect(type: model.id))
        case let .setFileUploadStep(model):
            fileUploadModel = model
            router.push(ClaimsRouterActions.uploadFiles)
        case .openUpdateAppScreen:
            router.push(ClaimsRouterActionsWithoutBackButton.updateApp)
        }
    }
}

enum ClaimsRouterActions: Hashable {
    case triagingEntrypoint
    case triagingOption
    case dateOfOccurrancePlusLocation
    case selectContract
    case phoneNumber(model: FlowClaimPhoneNumberStepModel)
    case audioRecording
    case singleItem
    case summary
    case deflect(type: FlowClaimDeflectStepType)
    case emergencySelect(model: FlowClaimConfirmEmergencyStepModel)
    case uploadFiles
    case checkOutNoRepair
}

extension ClaimsRouterActions: TrackingViewNameProtocol {
    var nameForTracking: String {
        switch self {
        case .triagingEntrypoint:
            return .init(describing: SelectClaimEntrypointType.self)
        case .triagingOption:
            return .init(describing: SelectClaimEntrypointOption.self)
        case .dateOfOccurrancePlusLocation:
            return .init(describing: SubmitClaimOccurrencePlusLocationScreen.self)
        case .selectContract:
            return .init(describing: SelectContractView.self)
        case .phoneNumber:
            return .init(describing: SubmitClaimContactScreen.self)
        case .audioRecording:
            return .init(describing: SubmitClaimAudioRecordingScreen.self)
        case .singleItem:
            return .init(describing: SubmitClaimSingleItem.self)
        case .summary:
            return .init(describing: SubmitClaimSummaryScreen.self)
        case let .deflect(type):
            if type == .FlowClaimDeflectEirStep {
                return .init(describing: SubmitClaimCarScreen.self)
            } else {
                return .init(describing: SubmitClaimDeflectScreen.self)
            }
        case .emergencySelect:
            return .init(describing: SumitClaimEmergencySelectView.self)
        case .uploadFiles:
            return .init(describing: SubmitClaimFilesUploadScreen.self)
        case .checkOutNoRepair:
            return .init(describing: SubmitClaimCheckoutView.self)
        }
    }

}

public enum ClaimsRouterActionsWithoutBackButton {
    case success
    case failure
    case updateApp
    case askForPushNotifications
}

extension ClaimsRouterActionsWithoutBackButton: TrackingViewNameProtocol {
    public var nameForTracking: String {
        switch self {
        case .success:
            return .init(describing: SubmitClaimSuccessScreen.self)
        case .failure:
            return "FailureScreen"
        case .updateApp:
            return .init(describing: UpdateAppScreen.self)
        case .askForPushNotifications:
            return "AskForPushNotifications"
        }
    }
}

public struct ClaimsNavigation: View {
    @StateObject var claimsNavigationVm = ClaimsNavigationViewModel()
    var origin: ClaimsOrigin
    @State var cancellable: AnyCancellable?

    public init(
        origin: ClaimsOrigin
    ) {
        self.origin = origin
    }

    public var body: some View {
        RouterHost(
            router: claimsNavigationVm.router,
            options: [.navigationType(type: .withProgress)],
            tracking: ClaimsDetentType.entryPoints
        ) {
            showClaimEntrypointGroup(origin: origin)
                .routerDestination(for: ClaimsRouterActions.self) { routerAction in
                    switch routerAction {
                    case .triagingEntrypoint:
                        showClaimEntrypointType()
                    case .triagingOption:
                        showClaimEntrypointOption()
                    case .dateOfOccurrancePlusLocation:
                        submitClaimOccurrancePlusLocationScreen()
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
                        openCheckoutScreen()
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
                    default:
                        EmptyView()
                    }
                }
        }
        .environmentObject(claimsNavigationVm)
        .detent(
            presented: $claimsNavigationVm.isLocationPickerPresented,
            style: [.height]
        ) {
            openLocationScreen()
                .embededInNavigation(options: .navigationType(type: .large), tracking: ClaimsDetentType.locationPicker)
        }
        .detent(
            presented: $claimsNavigationVm.isBrandPickerPresented,
            style: [.large]
        ) {
            openBrandPickerScreen()
                .routerDestination(
                    for: ClaimFlowItemBrandOptionModel.self
                ) { brandModel in
                    openModelPickerScreen(brand: brandModel)
                }
                .embededInNavigation(options: .navigationType(type: .large), tracking: ClaimsDetentType.brandPicker)
        }
        .detent(
            presented: $claimsNavigationVm.isPriceInputPresented,
            style: [.height]
        ) {
            openPriceInputScreen()
                .embededInNavigation(options: .navigationType(type: .large), tracking: ClaimsDetentType.priceInput)
        }
        .detent(
            presented: $claimsNavigationVm.isDamagePickerPresented,
            style: [.height]
        ) {
            openDamagePickerScreen()
                .embededInNavigation(options: .navigationType(type: .large), tracking: ClaimsDetentType.damagePicker)
        }
        .detent(
            item: $claimsNavigationVm.isInfoViewPresented,
            style: [.height]
        ) { infoViewModel in
            openInfoView(model: infoViewModel)
        }
        .modally(
            presented: $claimsNavigationVm.isCheckoutTransferringPresented
        ) {
            openCheckoutTransferringScreen()
        }
        .modally(
            item: $claimsNavigationVm.isClaimFilesPresented
        ) { claimsFileModel in
            openFileScreen(model: claimsFileModel)
        }
    }

    private func showClaimEntrypointGroup(origin: ClaimsOrigin) -> some View {
        SelectClaimEntrypointGroup(vm: claimsNavigationVm.selectClaimEntrypointVm)
            .resetProgressToPreviousValueOnDismiss(vm: claimsNavigationVm)
            //            .addClaimsProgressBar
            .addClaimsProgressBar(vm: claimsNavigationVm)
            .addDismissClaimsFlow()
    }

    private func showClaimEntrypointType() -> some View {
        SelectClaimEntrypointType()
            .resetProgressToPreviousValueOnDismiss(vm: claimsNavigationVm)
            .addDismissClaimsFlow()
    }

    private func showClaimEntrypointOption() -> some View {
        SelectClaimEntrypointOption()
            .resetProgressToPreviousValueOnDismiss(vm: claimsNavigationVm)
            .addDismissClaimsFlow()
    }

    private func submitClaimOccurrancePlusLocationScreen() -> some View {
        SubmitClaimOccurrencePlusLocationScreen(claimsNavigationVm: claimsNavigationVm)
            .resetProgressToPreviousValueOnDismiss(vm: claimsNavigationVm)
            .addDismissClaimsFlow()
    }

    private func openSelectContractScreen() -> some View {
        SelectContractView()
            .resetProgressToPreviousValueOnDismiss(vm: claimsNavigationVm)
            .addDismissClaimsFlow()
    }

    private func submitClaimPhoneNumberScreen(model: FlowClaimPhoneNumberStepModel) -> some View {
        SubmitClaimContactScreen(model: model)
            .resetProgressToPreviousValueOnDismiss(vm: claimsNavigationVm)
            .addDismissClaimsFlow()
    }

    private func openAudioRecordingSceen() -> some View {
        let url = claimsNavigationVm.audioRecordingModel?.getUrl()
        return SubmitClaimAudioRecordingScreen(url: url, claimsNavigationVm: claimsNavigationVm)
            .resetProgressToPreviousValueOnDismiss(vm: claimsNavigationVm)
            .addDismissClaimsFlow()
    }

    private func openSuccessScreen() -> some View {
        SubmitClaimSuccessScreen()
    }

    private func openSingleItemScreen() -> some View {
        SubmitClaimSingleItem()
            .resetProgressToPreviousValueOnDismiss(vm: claimsNavigationVm)
            .addDismissClaimsFlow()
    }

    private func openSummaryScreen() -> some View {
        SubmitClaimSummaryScreen(claimsNavigationVm: claimsNavigationVm)
            .configureTitle(L10n.Claims.Summary.Screen.title)
            .resetProgressToPreviousValueOnDismiss(vm: claimsNavigationVm)
            .addDismissClaimsFlow()
    }

    @ViewBuilder
    private func openDeflectStepScreen() -> some View {
        let model = claimsNavigationVm.deflectStepModel

        Group {
            if model?.id == .FlowClaimDeflectEirStep {
                SubmitClaimCarScreen(model: model)
            } else {
                SubmitClaimDeflectScreen(
                    model: model,
                    openChat: {
                        NotificationCenter.default.post(name: .openChat, object: ChatType.newConversation)
                    }
                )
            }
        }
        .resetProgressToPreviousValueOnDismiss(vm: claimsNavigationVm)
        .addDismissClaimsFlow()
        .configureTitle(model?.id.title ?? "")
    }

    private func openUpdateAppScreen() -> some View {
        UpdateAppScreen(
            onSelected: {
                claimsNavigationVm.router.dismiss()
            }
        )
    }

    private func openEmergencySelectScreen() -> some View {
        SumitClaimEmergencySelectView(title: {
            return claimsNavigationVm.emergencyConfirmModel?.text ?? ""
        })
        .resetProgressToPreviousValueOnDismiss(vm: claimsNavigationVm)
        .addDismissClaimsFlow()
    }

    private func openFileUploadScreen() -> some View {
        return SubmitClaimFilesUploadScreen(claimsNavigationVm: claimsNavigationVm)
            .resetProgressToPreviousValueOnDismiss(vm: claimsNavigationVm)
            .addDismissClaimsFlow()
    }

    private func openCheckoutScreen() -> some View {
        SubmitClaimCheckoutView()
            .resetProgressToPreviousValueOnDismiss(vm: claimsNavigationVm)
            .addDismissClaimsFlow()
            .configureTitle(L10n.Claims.Payout.Summary.title)
    }

    private func showClaimFailureScreen() -> some View {
        GenericErrorView()
            .hErrorViewButtonConfig(
                .init(
                    actionButton: .init(
                        buttonAction: {
                            claimsNavigationVm.router.pop()
                        }
                    ),
                    dismissButton: .init(
                        buttonTitle: L10n.openChat,
                        buttonAction: {
                            claimsNavigationVm.router.dismiss()
                            /** TODO: Is delay needed? **/
                            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                NotificationCenter.default.post(name: .openChat, object: ChatType.newConversation)
                            }
                        }
                    )
                )
            )
            .withDismissButton()
    }

    private func openLocationScreen() -> some View {
        LocationView()
            .environmentObject(claimsNavigationVm)
            .navigationTitle(L10n.Claims.Incident.Screen.location)

    }

    private func openBrandPickerScreen() -> some View {
        BrandPickerView()
            .environmentObject(claimsNavigationVm)
            .navigationTitle(L10n.claimsChooseBrandTitle)
    }

    private func openModelPickerScreen(brand: ClaimFlowItemBrandOptionModel) -> some View {
        ModelPickerView(brand: brand)
            .environmentObject(claimsNavigationVm)
            .navigationTitle(L10n.claimsChooseModelTitle)
    }

    private func openPriceInputScreen() -> some View {
        PriceInputScreen(claimsNavigationVm: claimsNavigationVm)
            .configureTitle(L10n.submitClaimPurchasePriceTitle)
    }

    private func openDamagePickerScreen() -> some View {
        ItemPickerScreen<ClaimFlowItemProblemOptionModel>(
            config: .init(
                items: {
                    return claimsNavigationVm.singleItemModel?.availableItemProblems
                        .compactMap({ (object: $0, displayName: .init(title: $0.displayName)) }) ?? []
                }(),
                preSelectedItems: {
                    if let singleItemStep = claimsNavigationVm.singleItemModel {
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
                    claimsNavigationVm.singleItemModel?.selectedItemProblems = damages
                },
                onCancel: {
                    claimsNavigationVm.router.dismiss()
                }
            )
        )
        .configureTitle(L10n.Claims.Item.Screen.Damage.button)
    }

    private func openCheckoutTransferringScreen() -> some View {
        SubmitClaimCheckoutTransferringView()
    }

    private func openInfoView(model: InfoViewModel) -> some View {
        InfoView(
            title: model.title ?? "",
            description: model.description ?? ""
        )
        .resetProgressToPreviousValueOnDismiss(vm: claimsNavigationVm)
    }

    private func openFileScreen(model: ClaimsFileModel) -> some View {
        ClaimFilesView(endPoint: model.endpoint, files: model.files) { uploadedFiles in
            claimsNavigationVm.router.dismiss()
        }
        .addDismissClaimsFlow()
        .configureTitle(L10n.ClaimStatusDetail.addedFiles)
    }
}

private enum ClaimsDetentType: TrackingViewNameProtocol {
    var nameForTracking: String {
        switch self {
        case .entryPoints:
            return .init(describing: SelectClaimEntrypointGroup.self)
        case .brandPicker:
            return .init(describing: BrandPickerView.self)
        case .priceInput:
            return .init(describing: PriceInputScreen.self)
        case .damagePicker:
            return .init(describing: ItemPickerScreen<ClaimFlowItemProblemOptionModel>.self)
        case .locationPicker:
            return .init(describing: LocationView.self)
        }

    }

    case entryPoints
    case brandPicker
    case priceInput
    case damagePicker
    case locationPicker
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

    //    var resetProgressToPreviousValueOnDismiss: some View {
    func resetProgressToPreviousValueOnDismiss(vm: ClaimsNavigationViewModel) -> some View {
        //    var resetProgressToPreviousValueOnDismiss: some View {
        /* TODO: IMPLEMENT */
        //        let store: SubmitClaimStore = globalPresentableStoreContainer.get()
        //        let previousProgress = store.state.previousProgress
        //        let previousProgress = vm.previousProgress

        return self.onDeinit {
            //            let store: SubmitClaimStore = globalPresentableStoreContainer.get()
            //            store.send(.setProgress(progress: previousProgress))
            //            vm.previousProgress = vm.progress
            //            vm.progress = previousProgress
        }
    }
}

public struct SubmitClaimOption: OptionSet, ActionProtocol, Hashable {
    public let rawValue: UInt

    public init(rawValue: UInt) {
        self.rawValue = rawValue
    }

    static let location = SubmitClaimOption(rawValue: 1 << 0)
    static let date = SubmitClaimOption(rawValue: 1 << 1)

    var title: String {
        let hasLocation = self.contains(.location)
        let hasDate = self.contains(.date)
        if hasLocation && hasDate {
            return L10n.claimsLocatonOccuranceTitle
        } else if hasDate {
            return L10n.Claims.Incident.Screen.Date.Of.incident
        } else if hasLocation {
            return L10n.Claims.Incident.Screen.location
        }
        return ""
    }
}

public enum ClaimsOrigin: Codable, Equatable, Hashable {
    case generic
    case commonClaims(id: String)
    case commonClaimsWithOption(id: String, optionId: String)

    public var id: CommonClaimId {
        switch self {
        case .generic:
            return CommonClaimId()
        case let .commonClaims(id):
            return CommonClaimId(id: id)
        case let .commonClaimsWithOption(id, optionId):
            return CommonClaimId(
                id: id,
                entrypointOptionId: optionId
            )
        }
    }
}

public struct CommonClaimId {
    public let id: String
    public let entrypointOptionId: String?

    init(
        id: String = "",
        entrypointOptionId: String? = nil
    ) {
        self.id = id
        self.entrypointOptionId = entrypointOptionId
    }
}

struct EntrypointState: Codable, Equatable, Hashable {
    var selectedEntrypoints: [ClaimEntryPointResponseModel]?
    var selectedEntrypointId: String?
    var selectedEntrypointOptions: [ClaimEntryPointOptionResponseModel]?
}

#Preview {
    ClaimsNavigation(origin: .generic)
}
