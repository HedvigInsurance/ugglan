import Claims
import Combine
import SwiftUI
import hCore
import hCoreUI

@MainActor
public class SubmitClaimNavigationViewModel: ObservableObject {
    @Published public var isLocationPickerPresented = false
    @Published public var isBrandPickerPresented = false
    @Published public var isPriceInputPresented = false
    @Published public var isDamagePickerPresented = false
    @Published public var isCheckoutTransferringPresented = false
    @Published public var isInfoViewPresented: InfoViewDataModel?
    @Published public var isClaimFilesPresented: ClaimsFileModel?

    @Published var entrypoints: EntrypointState = .init()
    @Published var currentClaimContext: String?
    @Published var progress: Float? = 0
    var previousProgress: Float?
    @Published var claimEntrypoints: [ClaimEntryPointResponseModel] = []
    @Published var occurrencePlusLocationModel: SubmitClaimStep.DateOfOccurrencePlusLocationStepModels?
    @Published var singleItemModel: FlowClaimSingleItemStepModel?
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
    @Published var selectClaimEntrypointVm = SelectClaimEntrypointViewModel()
    @Published var startClaimState = ProcessingState.success
    var router = Router()
    private let submitClaimService = SubmitClaimService()

    @Published var currentClaimId: String? {
        didSet {
            do {
                if oldValue != currentClaimId {
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

    func startClaimRequest(entrypointId: String?, entrypointOptionId: String?) async {
        withAnimation {
            startClaimState = .loading
        }
        do {
            let data = try await submitClaimService.startClaim(
                entrypointId: entrypointId,
                entrypointOptionId: entrypointOptionId
            )
            withAnimation {
                startClaimState = .success
            }
            navigate(data: data)
        } catch let exception {
            withAnimation {
                startClaimState = .error(errorMessage: exception.localizedDescription)
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
        previousProgress = progress
        progress = data.progress
        switch data.step {
        case let .setDateOfOccurrencePlusLocation(model):
            occurrencePlusLocationModel = model
            router.push(SubmitClaimRouterActions.dateOfOccurrancePlusLocation)
        case let .setDateOfOccurence(model):
            occurrencePlusLocationModel = .init(dateOfOccurencePlusLocationModel: nil, dateOfOccurrenceModel: model)
            router.push(SubmitClaimRouterActions.dateOfOccurrancePlusLocation)
        case let .setPhoneNumber(model):
            phoneNumberModel = model
            router.push(SubmitClaimRouterActions.phoneNumber(model: model))
        case let .setAudioStep(model):
            audioRecordingModel = model
            router.push(SubmitClaimRouterActions.audioRecording)
        case let .setSingleItem(model):
            singleItemModel = model
            router.push(SubmitClaimRouterActions.singleItem)
        case let .setLocation(model):
            occurrencePlusLocationModel = .init(dateOfOccurencePlusLocationModel: nil, locationModel: model)
            router.push(SubmitClaimRouterActions.dateOfOccurrancePlusLocation)
        case let .setSummaryStep(model):
            summaryModel = model
            router.push(SubmitClaimRouterActions.summary)
        case let .setSingleItemCheckoutStep(model):
            singleItemCheckoutModel = model
            router.push(SubmitClaimRouterActions.checkOutNoRepair)
            progress = nil
        case .setSuccessStep:
            router.push(SubmitClaimRouterActionsWithoutBackButton.success)
            progress = nil
        case .setFailedStep:
            router.push(SubmitClaimRouterActionsWithoutBackButton.failure)
            progress = nil
        case let .setContractSelectStep(model):
            contractSelectModel = model
            router.push(SubmitClaimRouterActions.selectContract)
        case let .setConfirmDeflectEmergencyStepModel(model):
            emergencyConfirmModel = model
            router.push(SubmitClaimRouterActions.emergencySelect(model: model))
        case let .setDeflectModel(model):
            deflectStepModel = model
            router.push(SubmitClaimRouterActions.deflect(type: model.id))
        case let .setFileUploadStep(model):
            fileUploadModel = model
            router.push(SubmitClaimRouterActions.uploadFiles)
        case .openUpdateAppScreen:
            router.push(SubmitClaimRouterActionsWithoutBackButton.updateApp)
        }
    }
}

enum SubmitClaimRouterActions: Hashable {
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

extension SubmitClaimRouterActions: TrackingViewNameProtocol {
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
            return .init(describing: SubmitClaimSingleItemScreen.self)
        case .summary:
            return .init(describing: SubmitClaimSummaryScreen.self)
        case let .deflect(type):
            if type == .FlowClaimDeflectEirStep {
                return .init(describing: SubmitClaimCarView.self)
            } else {
                return .init(describing: SubmitClaimDeflectScreen.self)
            }
        case .emergencySelect:
            return .init(describing: SumitClaimEmergencySelectView.self)
        case .uploadFiles:
            return .init(describing: SubmitClaimFilesUploadScreen.self)
        case .checkOutNoRepair:
            return .init(describing: SubmitClaimCheckoutScreen.self)
        }
    }

}

public enum SubmitClaimRouterActionsWithoutBackButton {
    case success
    case failure
    case updateApp
    case askForPushNotifications
}

extension SubmitClaimRouterActionsWithoutBackButton: TrackingViewNameProtocol {
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

public struct SubmitClaimNavigation: View {
    @StateObject var claimsNavigationVm = SubmitClaimNavigationViewModel()
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
            SelectClaimEntrypointGroup(vm: claimsNavigationVm.selectClaimEntrypointVm)
                .resetProgressOnDismiss(to: claimsNavigationVm.previousProgress, for: $claimsNavigationVm.progress)
                .addDismissClaimsFlow()
                .routerDestination(for: SubmitClaimRouterActions.self) { routerAction in
                    Group {
                        switch routerAction {
                        case .triagingEntrypoint:
                            SelectClaimEntrypointType()
                        case .triagingOption:
                            SelectClaimEntrypointOption()
                        case .dateOfOccurrancePlusLocation:
                            SubmitClaimOccurrencePlusLocationScreen(claimsNavigationVm: claimsNavigationVm)
                        case .selectContract:
                            SelectContractView(claimsNavigationVm: claimsNavigationVm)
                        case let .phoneNumber(model):
                            SubmitClaimContactScreen(model: model)
                        case .audioRecording:
                            let url = claimsNavigationVm.audioRecordingModel?.getUrl()
                            SubmitClaimAudioRecordingScreen(url: url, claimsNavigationVm: claimsNavigationVm)
                        case .singleItem:
                            SubmitClaimSingleItemScreen()
                        case .summary:
                            SubmitClaimSummaryScreen(claimsNavigationVm: claimsNavigationVm)
                                .configureTitle(L10n.Claims.Summary.Screen.title)
                        case .deflect:
                            openDeflectStepScreen()
                        case .emergencySelect:
                            SumitClaimEmergencySelectView(
                                title: claimsNavigationVm.emergencyConfirmModel?.text ?? ""
                            )
                        case .uploadFiles:
                            SubmitClaimFilesUploadScreen(claimsNavigationVm: claimsNavigationVm)
                        case .checkOutNoRepair:
                            SubmitClaimCheckoutScreen(vm: claimsNavigationVm.submitClaimCheckoutVm)
                                .configureTitle(L10n.Claims.Payout.Summary.title)
                        }
                    }
                    .addDismissClaimsFlow()
                    .resetProgressOnDismiss(to: claimsNavigationVm.previousProgress, for: $claimsNavigationVm.progress)
                }
                .routerDestination(
                    for: SubmitClaimRouterActionsWithoutBackButton.self,
                    options: .hidesBackButton
                ) { routerAction in
                    switch routerAction {
                    case .failure:
                        showClaimFailureScreen()
                    case .success:
                        SubmitClaimSuccessScreen()
                    case .updateApp:
                        UpdateAppScreen(
                            onSelected: {
                                claimsNavigationVm.router.dismiss()
                            }
                        )
                    default:
                        EmptyView()
                    }
                }
        }
        .modifier(ProgressBarView(progress: $claimsNavigationVm.progress))
        .environmentObject(claimsNavigationVm)
        .detent(
            presented: $claimsNavigationVm.isLocationPickerPresented,
            transitionType: .detent(style: [.height])
        ) {
            LocationView(claimsNavigationVm: claimsNavigationVm, router: claimsNavigationVm.router)
                .environmentObject(claimsNavigationVm)
                .navigationTitle(L10n.Claims.Incident.Screen.location)
                .embededInNavigation(options: .navigationType(type: .large), tracking: ClaimsDetentType.locationPicker)
        }
        .detent(
            presented: $claimsNavigationVm.isBrandPickerPresented,
            transitionType: .detent(style: [.large])
        ) {
            BrandPickerView()
                .environmentObject(claimsNavigationVm)
                .navigationTitle(L10n.claimsChooseBrandTitle)
                .routerDestination(
                    for: ClaimFlowItemBrandOptionModel.self
                ) { brandModel in
                    ModelPickerView(
                        router: claimsNavigationVm.router,
                        claimsNavigationVm: claimsNavigationVm,
                        brand: brandModel
                    )
                    .navigationTitle(L10n.claimsChooseModelTitle)
                }
                .embededInNavigation(options: .navigationType(type: .large), tracking: ClaimsDetentType.brandPicker)
        }
        .detent(
            presented: $claimsNavigationVm.isPriceInputPresented,
            transitionType: .detent(style: [.height])
        ) {
            PriceInputScreen(claimsNavigationVm: claimsNavigationVm)
                .configureTitle(L10n.submitClaimPurchasePriceTitle)
                .embededInNavigation(options: .navigationType(type: .large), tracking: ClaimsDetentType.priceInput)
        }
        .detent(
            presented: $claimsNavigationVm.isDamagePickerPresented,
            transitionType: .detent(style: [.height])
        ) {
            openDamagePickerScreen()
                .embededInNavigation(options: .navigationType(type: .large), tracking: ClaimsDetentType.damagePicker)
        }
        .detent(
            item: $claimsNavigationVm.isInfoViewPresented,
            transitionType: .detent(style: [.height])
        ) { infoViewModel in
            InfoView(
                title: infoViewModel.title ?? "",
                description: infoViewModel.description ?? ""
            )
        }
        .modally(
            presented: $claimsNavigationVm.isCheckoutTransferringPresented
        ) {
            SubmitClaimCheckoutTransferringScreen(vm: claimsNavigationVm.submitClaimCheckoutVm)
                .environmentObject(claimsNavigationVm)
        }
        .modally(
            item: $claimsNavigationVm.isClaimFilesPresented
        ) { claimsFileModel in
            openFileScreen(model: claimsFileModel)
        }
    }

    @ViewBuilder
    private func openDeflectStepScreen() -> some View {
        let model = claimsNavigationVm.deflectStepModel

        Group {
            if model?.id == .FlowClaimDeflectEirStep {
                SubmitClaimCarView(model: model)
            } else {
                SubmitClaimDeflectScreen(
                    model: model!,
                    openChat: {
                        NotificationCenter.default.post(name: .openChat, object: ChatType.newConversation)
                    }
                )
            }
        }
        .configureTitle(model?.id.title ?? "")
    }

    private func showClaimFailureScreen() -> some View {
        GenericErrorView(
            formPosition: .center
        )
        .hStateViewButtonConfig(
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
                        NotificationCenter.default.post(name: .openChat, object: ChatType.newConversation)
                    }
                )
            )
        )
        .withDismissButton()
    }

    private func openDamagePickerScreen() -> some View {
        DamagePickerView(claimsNavigationVm: claimsNavigationVm)
    }

    private func openFileScreen(model: ClaimsFileModel) -> some View {
        ClaimFilesView(endPoint: model.endpoint, files: model.files) { uploadedFiles in
            claimsNavigationVm.router.dismiss()
        }
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
}

public struct SubmitClaimOption: OptionSet, Hashable, Sendable {
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

public enum ClaimsOrigin: Codable, Equatable, Hashable, Sendable {
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
    Dependencies.shared.add(module: Module { () -> hFetchEntrypointsClient in FetchEntrypointsClientDemo() })
    return SubmitClaimNavigation(origin: .generic)
}
