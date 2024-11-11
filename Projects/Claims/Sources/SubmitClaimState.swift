import Foundation
import PresentableStore
import hCore

public struct SubmitClaimsState: StateProtocol {
    @OptionalTransient var progress: Float?
    @OptionalTransient var previousProgress: Float?

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
