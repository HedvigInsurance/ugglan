import Presentation
import hCore

public struct SubmitClaimsState: StateProtocol {
    @Transient(defaultValue: "") var currentClaimId: String
    @OptionalTransient var currentClaimContext: String?
    @Transient(defaultValue: [:]) var loadingStates: [ClaimsLoadingType: LoadingState<String>]
    @Transient(defaultValue: []) var claimEntrypoints: [ClaimEntryPointResponseModel]
    @Transient(defaultValue: []) var claimEntrypointGroups: [ClaimEntryPointGroupResponseModel]
    @OptionalTransient var summaryStep: FlowClaimSummaryStepModel?
    @OptionalTransient var dateOfOccurenceStep: FlowClaimDateOfOccurenceStepModel?
    @OptionalTransient var locationStep: FlowClaimLocationStepModel?
    @OptionalTransient var singleItemStep: FlowClamSingleItemStepModel?
    @OptionalTransient var phoneNumberStep: FlowClaimPhoneNumberStepModel?
    @OptionalTransient var dateOfOccurrencePlusLocationStep: FlowClaimDateOfOccurrencePlusLocationStepModel?
    @OptionalTransient var singleItemCheckoutStep: FlowClaimSingleItemCheckoutStepModel?
    @OptionalTransient var successStep: FlowClaimSuccessStepModel?
    @OptionalTransient var failedStep: FlowClaimFailedStepModel?
    @OptionalTransient var audioRecordingStep: FlowClaimAudioRecordingStepModel?
    @Transient(defaultValue: 0) var progress: Float
    @Transient(defaultValue: EntrypointState()) var entrypoints: EntrypointState

    public init() {}
}

public enum LoadingState<T>: Codable & Equatable & Hashable where T: Codable & Equatable & Hashable {
    case loading
    case error(error: T)
}

public enum ClaimsOrigin: Codable, Equatable, Hashable {
    case generic
    case commonClaims(id: String)
    case commonClaimsWithOption(id: String, optionId: String)

    public var id: commonClaimId {
        switch self {
        case .generic:
            return commonClaimId()
        case let .commonClaims(id):
            return commonClaimId(id: id)
        case let .commonClaimsWithOption(id, optionId):
            return commonClaimId(id: id, entrypointOptionId: optionId)
        }
    }
}

public struct commonClaimId {
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

    init() {}
}
