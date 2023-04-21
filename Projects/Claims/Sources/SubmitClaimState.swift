import Odyssey
import Presentation
import hCore
public struct SubmitClaimsState: StateProtocol {
    @Transient(defaultValue: "") var currentClaimId:String
    @OptionalTransient var currentClaimContext: String?
    @Transient(defaultValue: [:]) var loadingStates:[ClaimsLoadingType: LoadingState<String>]
    @Transient(defaultValue: []) var entryPointCommonClaims: [ClaimEntryPointResponseModel]
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

    public init() {}
}

public enum LoadingState<T>: Codable & Equatable & Hashable where T: Codable & Equatable & Hashable {
    case loading
    case error(error: T)
}

public enum ClaimsOrigin: Codable, Equatable, Hashable {
    case generic
    case commonClaims(id: String)

    public var initialScopeValues: ScopeValues {
        let scopeValues = ScopeValues()
        switch self {
        case let .commonClaims(id):
            scopeValues.setValue(
                key: CommonClaimIdScopeValueKey.shared,
                value: id
            )
        default:
            break
        }
        return scopeValues
    }

    public var id: String {
        switch self {
        case .generic:
            return ""
        case .commonClaims(let id):
            return id
        }
    }
}
