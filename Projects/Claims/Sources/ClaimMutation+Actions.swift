import Apollo
import Flow
import Foundation
import Presentation
import hCore
import hGraphQL

protocol Into {
    associatedtype To
    func into() -> To
}

extension OctopusGraphQL.FlowClaimFragment.CurrentStep: Into {
    func into() -> SubmitClaimsAction {
        if let step = self.fragments.flowClaimPhoneNumberStepFragment {
            return .stepModelAction(action: .setPhoneNumber(model: .init(with: step)))
        } else if let step = self.fragments.flowClaimAudioRecordingStepFragment {
            return .stepModelAction(action: .setAudioStep(model: .init(with: step)))
        } else if let step = self.fragments.flowClaimSingleItemStepFragment {
            return .stepModelAction(action: .setSingleItem(model: .init(with: step)))
        } else if let step = self.fragments.flowClaimSingleItemCheckoutStepFragment {
            return .stepModelAction(action: .setSingleItemCheckoutStep(model: .init(with: step)))
        } else if let step = self.fragments.flowClaimLocationStepFragment {
            return .stepModelAction(action: .setLocation(model: .init(with: step)))
        } else if let step = self.fragments.flowClaimDateOfOccurrenceStepFragment {
            return .stepModelAction(action: .setDateOfOccurence(model: .init(with: step)))
        } else if let step = self.fragments.flowClaimSummaryStepFragment {
            let summaryStep = FlowClaimSummaryStepModel(with: step)
            let singleItemStepModel: FlowClamSingleItemStepModel? = {
                if let singleItemStep = step.singleItemStep?.fragments.flowClaimSingleItemStepFragment {
                    return .init(with: singleItemStep)
                }
                return nil
            }()
            return .stepModelAction(
                action: .setSummaryStep(
                    model: .init(
                        summaryStep: summaryStep,
                        singleItemStepModel: singleItemStepModel,
                        dateOfOccurenceModel: .init(
                            with: step.dateOfOccurrenceStep.fragments.flowClaimDateOfOccurrenceStepFragment
                        ),
                        locationModel: .init(with: step.locationStep.fragments.flowClaimLocationStepFragment)
                    )
                )
            )
        } else if let step = self.fragments.flowClaimDateOfOccurrencePlusLocationStepFragment {
            return .stepModelAction(
                action: .setDateOfOccurrencePlusLocation(
                    model: .init(
                        dateOfOccurencePlusLocationModel: .init(with: step),
                        dateOfOccurenceModel: .init(
                            with: step.dateOfOccurrenceStep.fragments.flowClaimDateOfOccurrenceStepFragment
                        ),
                        locationModel: .init(with: step.locationStep.fragments.flowClaimLocationStepFragment)
                    )
                )
            )
        } else if let step = self.fragments.flowClaimFailedStepFragment {
            return .stepModelAction(action: .setFailedStep(model: .init(with: step)))
        } else if let step = self.fragments.flowClaimSuccessStepFragment {
            return .stepModelAction(action: .setSuccessStep(model: .init(with: step)))
        } else {
            return .navigationAction(action: .openUpdateAppScreen)
        }
    }
}

extension GraphQLMutation {
    func execute<ClaimStep: Into>(_ keyPath: KeyPath<Self.Data, ClaimStep>) -> FiniteSignal<SubmitClaimsAction>
    where ClaimStep.To == SubmitClaimsAction, Self: ClaimStepLoadingType, Self.Data: ClaimStepContext {
        let octopus: hOctopus = Dependencies.shared.resolve()
        return FiniteSignal { callback in
            let disposeBag = DisposeBag()
            callback(.value(.setLoadingState(action: self.getLoadingType(), state: .loading)))
            disposeBag += octopus.client.perform(mutation: self)
                .map { data in
                    if let data = data as? ClaimStepId {
                        callback(.value(.setNewClaimId(with: data.getStepId())))
                    }
                    callback(.value(.setNewClaimContext(context: data.getContext())))
                    callback(.value(data[keyPath: keyPath].into()))
                    callback(.value(.setLoadingState(action: self.getLoadingType(), state: nil)))
                }
                .onError({ error in
                    callback(
                        .value(
                            .setLoadingState(
                                action: self.getLoadingType(),
                                state: .error(error: L10n.General.errorBody)
                            )
                        )
                    )
                })
            return disposeBag
        }
    }
}

protocol ClaimStepId {
    func getStepId() -> String
}

protocol ClaimStepContext {
    func getContext() -> String
}

extension OctopusGraphQL.FlowClaimStartMutation.Data: ClaimStepContext, ClaimStepId {
    func getContext() -> String {
        return self.flowClaimStart.context
    }

    func getStepId() -> String {
        return self.flowClaimStart.id
    }
}

extension OctopusGraphQL.FlowClaimDateOfOccurrencePlusLocationNextMutation.Data: ClaimStepContext {
    func getContext() -> String {
        return self.flowClaimDateOfOccurrencePlusLocationNext.context
    }
}

extension OctopusGraphQL.FlowClaimAudioRecordingNextMutation.Data: ClaimStepContext {
    func getContext() -> String {
        return self.flowClaimAudioRecordingNext.context
    }
}

extension OctopusGraphQL.FlowClaimPhoneNumberNextMutation.Data: ClaimStepContext {
    func getContext() -> String {
        return self.flowClaimPhoneNumberNext.context
    }
}

extension OctopusGraphQL.FlowClaimDateOfOccurrenceNextMutation.Data: ClaimStepContext {
    func getContext() -> String {
        return self.flowClaimDateOfOccurrenceNext.context
    }
}

extension OctopusGraphQL.FlowClaimLocationNextMutation.Data: ClaimStepContext {
    func getContext() -> String {
        return self.flowClaimLocationNext.context
    }
}

extension OctopusGraphQL.FlowClaimSingleItemNextMutation.Data: ClaimStepContext {
    func getContext() -> String {
        return self.flowClaimSingleItemNext.context
    }
}

extension OctopusGraphQL.FlowClaimSummaryNextMutation.Data: ClaimStepContext {
    func getContext() -> String {
        return self.flowClaimSummaryNext.context
    }
}

extension OctopusGraphQL.FlowClaimSingleItemCheckoutNextMutation.Data: ClaimStepContext {
    func getContext() -> String {
        return self.flowClaimSingleItemCheckoutNext.context
    }
}

//MARK: loading type
protocol ClaimStepLoadingType {
    func getLoadingType() -> ClaimsLoadingType
}

extension OctopusGraphQL.FlowClaimStartMutation: ClaimStepLoadingType {
    func getLoadingType() -> ClaimsLoadingType {
        return .startClaim
    }
}

extension OctopusGraphQL.FlowClaimPhoneNumberNextMutation: ClaimStepLoadingType {
    func getLoadingType() -> ClaimsLoadingType {
        return .postPhoneNumber
    }
}

extension OctopusGraphQL.FlowClaimDateOfOccurrenceNextMutation: ClaimStepLoadingType {
    func getLoadingType() -> ClaimsLoadingType {
        return .postDateOfOccurrence
    }
}

extension OctopusGraphQL.FlowClaimDateOfOccurrencePlusLocationNextMutation: ClaimStepLoadingType {
    func getLoadingType() -> ClaimsLoadingType {
        return .postDateOfOccurrenceAndLocation
    }
}

extension OctopusGraphQL.FlowClaimLocationNextMutation: ClaimStepLoadingType {
    func getLoadingType() -> ClaimsLoadingType {
        return .postLocation
    }
}

extension OctopusGraphQL.FlowClaimAudioRecordingNextMutation: ClaimStepLoadingType {
    func getLoadingType() -> ClaimsLoadingType {
        return .postAudioRecording
    }
}

extension OctopusGraphQL.FlowClaimSingleItemNextMutation: ClaimStepLoadingType {
    func getLoadingType() -> ClaimsLoadingType {
        return .postSingleItem
    }
}

extension OctopusGraphQL.FlowClaimSingleItemCheckoutNextMutation: ClaimStepLoadingType {
    func getLoadingType() -> ClaimsLoadingType {
        return .postSingleItemCheckout
    }
}

extension OctopusGraphQL.FlowClaimSummaryNextMutation: ClaimStepLoadingType {
    func getLoadingType() -> ClaimsLoadingType {
        return .postSummary
    }
}
