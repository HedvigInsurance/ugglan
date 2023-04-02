import Apollo
import Flow
import Odyssey
import Presentation
import SwiftUI
import hCore
import hGraphQL

public struct ClaimsState: StateProtocol {
    var claims: [Claim]? = nil
    var commonClaims: [CommonClaim]? = nil
    var currentClaimId: String = ""
    var currentClaimContext: String?
    var loadingStates: [ClaimsAction: LoadingState<String>] = [:]
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
    public init() {}

    private enum CodingKeys: String, CodingKey {
        case claims, commonClaims
    }

    public var hasActiveClaims: Bool {
        if let claims = claims {
            return
                !claims.filter {
                    $0.claimDetailData.status == .beingHandled || $0.claimDetailData.status == .reopened
                        || $0.claimDetailData.status == .submitted
                }
                .isEmpty
        }
        return false
    }
}

public enum LoadingState<T>: Codable & Equatable where T: Codable & Equatable {
    case loading
    case error(error: T)
}

public enum ClaimsOrigin: Codable, Equatable {
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
