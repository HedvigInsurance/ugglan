import Odyssey
import Presentation

public struct SubmitClaimsState: StateProtocol {
    var currentClaimId: String = ""
    var currentClaimContext: String?
    var loadingStates: [ClaimsLoadingType: LoadingState<String>] = [:]
    var entryPointCommonClaims: [ClaimEntryPointResponseModel] = []

    var summaryStep: FlowClaimSummaryStepModel?
    var dateOfOccurenceStep: FlowClaimDateOfOccurenceStepModel?
    var locationStep: FlowClaimLocationStepModel?
    var singleItemStep: FlowClamSingleItemStepModel?
    var phoneNumberStep: FlowClaimPhoneNumberStepModel?
    var dateOfOccurrencePlusLocationStep: FlowClaimDateOfOccurrencePlusLocationStepModel?
    var singleItemCheckoutStep: FlowClaimSingleItemCheckoutStepModel?
    var successStep: FlowClaimSuccessStepModel?
    var failedStep: FlowClaimFailedStepModel?
    var audioRecordingStep: FlowClaimAudioRecordingStepModel?

    enum CodingKeys: CodingKey {}

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
