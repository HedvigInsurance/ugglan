import Presentation
import hCore

public struct SubmitClaimsState: StateProtocol {
    @Transient(defaultValue: "") var currentClaimId: String
    @OptionalTransient var currentClaimContext: String?
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
    @OptionalTransient var contractStep: FlowClaimContractSelectStepModel?
    @OptionalTransient var emergencyConfirm: FlowClaimConfirmEmergencyStepModel?
    @OptionalTransient var emergencyStep: FlowClaimDeflectStepModel?
    @OptionalTransient var pestsStep: FlowClaimDeflectStepModel?
    @OptionalTransient var glassDamageStep: FlowClaimDeflectStepModel?
    @OptionalTransient var progress: Float?
    @OptionalTransient var previousProgress: Float?

    @Transient(defaultValue: EntrypointState()) var entrypoints: EntrypointState

    public init() {}
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
