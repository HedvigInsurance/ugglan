import Flow
import Presentation

public protocol SubmitClaimService {
    func startClaim(entrypointId: String?, entrypointOptionId: String?) async
}
