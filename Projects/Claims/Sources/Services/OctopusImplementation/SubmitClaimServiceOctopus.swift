import Combine
import Flow
import Foundation
import Presentation
import hCore
import hGraphQL

public class SubmitClaimServiceOctopus: SubmitClaimService {

    public init() {}
    public func startClaim(entrypointId: String?, entrypointOptionId: String?) async {
        let startInput = OctopusGraphQL.FlowClaimStartInput(
            entrypointId: GraphQLNullable(optionalValue: entrypointId),
            entrypointOptionId: GraphQLNullable(optionalValue: entrypointOptionId)
        )
        let mutation = OctopusGraphQL.FlowClaimStartMutation(input: startInput, context: GraphQLNullable.none)
        await mutation.execute(\.flowClaimStart.fragments.flowClaimFragment.currentStep)
    }
}

extension GraphQLMutation {
    func execute<ClaimStep: Into>(_ keyPath: KeyPath<Self.Data, ClaimStep>) async
    where
        ClaimStep.To == SubmitClaimsAction, Self: ClaimStepLoadingType, Self.Data: ClaimStepContext,
        Self.Data: ClaimStepProgress, Self.Data: ClaimStepId
    {
        let octopus: hOctopus = Dependencies.shared.resolve()
        let loadingType = self.getLoadingType()
        let store: SubmitClaimStore = globalPresentableStoreContainer.get()
        store.setLoading(for: loadingType)
        do {
            let data = try await octopus.client.perform(mutation: self)
            store.send(.setNewClaimId(with: data.getStepId()))
            store.send(.setNewClaimContext(context: data.getContext()))
            if let clearedSteps = data.getProgress().clearedSteps,
                let totalSteps = data.getProgress().totalSteps
            {
                if clearedSteps != 0 {
                    let progressValue = Float(Float(clearedSteps) / Float(totalSteps)) * 0.7 + 0.3
                    store.send(.setProgress(progress: progressValue))
                } else {
                    store.send(.setProgress(progress: 0.3))
                }
            }
            let action = data[keyPath: keyPath].into()
            store.send(action)
            store.removeLoading(for: loadingType)
        } catch _ {
            store.setError(L10n.General.errorBody, for: loadingType)
        }
    }
}
