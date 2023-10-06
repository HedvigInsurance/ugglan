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
        } else if let step = self.fragments.flowClaimContractSelectStepFragment {
            return .stepModelAction(action: .setContractSelectStep(model: .init(with: step)))
        } else if let step = self.fragments.flowClaimDeflectEmergencyStepFragment {
            return .stepModelAction(action: .setDeflectModel(model: .init(with: step)))
        } else if let step = self.fragments.flowClaimConfirmEmergencyStepFragment {
            return .stepModelAction(action: .setConfirmDeflectEmergencyStepModel(model: .init(with: step)))
        } else if let step = self.fragments.flowClaimDeflectPestsStepFragment {
            return .stepModelAction(action: .setDeflectModel(model: .init(with: step)))
        } else if let step = self.fragments.flowClaimDeflectGlassDamageStepFragment {
            return .stepModelAction(action: .setDeflectModel(model: .init(with: step)))
        } else {
            return .navigationAction(action: .openUpdateAppScreen)
        }
    }
}

extension GraphQLMutation {
    func execute<ClaimStep: Into>(_ keyPath: KeyPath<Self.Data, ClaimStep>) -> FiniteSignal<SubmitClaimsAction>
    where
        ClaimStep.To == SubmitClaimsAction, Self: ClaimStepLoadingType, Self.Data: ClaimStepContext,
        Self.Data: ClaimStepProgress
    {
        let octopus: hOctopus = Dependencies.shared.resolve()
        return FiniteSignal { callback in
            let disposeBag = DisposeBag()
            let store: SubmitClaimStore = globalPresentableStoreContainer.get()
            store.setLoading(for: self.getLoadingType())
            disposeBag += octopus.client.perform(mutation: self)
                .map { data in
                    let ss = ""
                    if let data = data as? ClaimStepId {
                        callback(.value(.setNewClaimId(with: data.getStepId())))
                    }
                    callback(.value(.setNewClaimContext(context: data.getContext())))
                    if let clearedSteps = data.getProgress().clearedSteps,
                        let totalSteps = data.getProgress().totalSteps
                    {
                        if clearedSteps != 0 {
                            let progressValue = Float(Float(clearedSteps) / Float(totalSteps)) * 0.7 + 0.3
                            callback(.value(.setProgress(progress: progressValue)))
                        } else {
                            callback(.value(.setProgress(progress: 0.3)))
                        }
                    }
                    callback(.value(data[keyPath: keyPath].into()))
                    store.removeLoading(for: self.getLoadingType())
                }
                .onError({ error in
                    store.setError(L10n.General.errorBody, for: self.getLoadingType())
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

protocol ClaimStepProgress {
    func getProgress() -> (clearedSteps: Int?, totalSteps: Int?)
}

extension OctopusGraphQL.FlowClaimStartMutation.Data: ClaimStepContext, ClaimStepProgress, ClaimStepId {
    func getContext() -> String {
        return self.flowClaimStart.context
    }

    func getProgress() -> (clearedSteps: Int?, totalSteps: Int?) {
        return (
            clearedSteps: self.flowClaimStart.progress?.clearedSteps ?? 0,
            totalSteps: self.flowClaimStart.progress?.totalSteps ?? 0
        )
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

extension OctopusGraphQL.FlowClaimContractSelectNextMutation.Data: ClaimStepContext {
    func getContext() -> String {
        return self.flowClaimContractSelectNext.context
    }
}

extension OctopusGraphQL.FlowClaimConfirmEmergencyNextMutation.Data: ClaimStepContext {
    func getContext() -> String {
        return self.flowClaimConfirmEmergencyNext.context
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

extension OctopusGraphQL.FlowClaimDateOfOccurrencePlusLocationNextMutation.Data: ClaimStepProgress {
    func getProgress() -> (clearedSteps: Int?, totalSteps: Int?) {
        return (
            clearedSteps: self.flowClaimDateOfOccurrencePlusLocationNext.progress?.clearedSteps ?? 0,
            totalSteps: self.flowClaimDateOfOccurrencePlusLocationNext.progress?.totalSteps ?? 0
        )
    }
}

extension OctopusGraphQL.FlowClaimContractSelectNextMutation.Data: ClaimStepProgress {
    func getProgress() -> (clearedSteps: Int?, totalSteps: Int?) {
        return (
            clearedSteps: self.flowClaimContractSelectNext.progress?.clearedSteps ?? 0,
            totalSteps: self.flowClaimContractSelectNext.progress?.totalSteps ?? 0
        )
    }
}

extension OctopusGraphQL.FlowClaimConfirmEmergencyNextMutation.Data: ClaimStepProgress {
    func getProgress() -> (clearedSteps: Int?, totalSteps: Int?) {
        return (
            clearedSteps: self.flowClaimConfirmEmergencyNext.progress?.clearedSteps ?? 0,
            totalSteps: self.flowClaimConfirmEmergencyNext.progress?.totalSteps ?? 0
        )
    }
}

extension OctopusGraphQL.FlowClaimAudioRecordingNextMutation.Data: ClaimStepProgress {
    func getProgress() -> (clearedSteps: Int?, totalSteps: Int?) {
        return (
            clearedSteps: self.flowClaimAudioRecordingNext.progress?.clearedSteps ?? 0,
            totalSteps: self.flowClaimAudioRecordingNext.progress?.totalSteps ?? 0
        )
    }
}

extension OctopusGraphQL.FlowClaimPhoneNumberNextMutation.Data: ClaimStepProgress {
    func getProgress() -> (clearedSteps: Int?, totalSteps: Int?) {
        return (
            clearedSteps: self.flowClaimPhoneNumberNext.progress?.clearedSteps ?? 0,
            totalSteps: self.flowClaimPhoneNumberNext.progress?.totalSteps ?? 0
        )
    }
}

extension OctopusGraphQL.FlowClaimDateOfOccurrenceNextMutation.Data: ClaimStepProgress {
    func getProgress() -> (clearedSteps: Int?, totalSteps: Int?) {
        return (
            clearedSteps: self.flowClaimDateOfOccurrenceNext.progress?.clearedSteps ?? 0,
            totalSteps: self.flowClaimDateOfOccurrenceNext.progress?.totalSteps ?? 0
        )
    }
}

extension OctopusGraphQL.FlowClaimLocationNextMutation.Data: ClaimStepProgress {
    func getProgress() -> (clearedSteps: Int?, totalSteps: Int?) {
        return (
            clearedSteps: self.flowClaimLocationNext.progress?.clearedSteps ?? 0,
            totalSteps: self.flowClaimLocationNext.progress?.totalSteps ?? 0
        )
    }
}

extension OctopusGraphQL.FlowClaimSingleItemNextMutation.Data: ClaimStepProgress {
    func getProgress() -> (clearedSteps: Int?, totalSteps: Int?) {
        return (
            clearedSteps: self.flowClaimSingleItemNext.progress?.clearedSteps ?? 0,
            totalSteps: self.flowClaimSingleItemNext.progress?.totalSteps ?? 0
        )
    }
}

extension OctopusGraphQL.FlowClaimSummaryNextMutation.Data: ClaimStepProgress {
    func getProgress() -> (clearedSteps: Int?, totalSteps: Int?) {
        return (
            clearedSteps: self.flowClaimSummaryNext.progress?.clearedSteps ?? 0,
            totalSteps: self.flowClaimSummaryNext.progress?.totalSteps ?? 0
        )
    }
}

extension OctopusGraphQL.FlowClaimSingleItemCheckoutNextMutation.Data: ClaimStepProgress {
    func getProgress() -> (clearedSteps: Int?, totalSteps: Int?) {
        return (
            clearedSteps: self.flowClaimSingleItemCheckoutNext.progress?.clearedSteps ?? 0,
            totalSteps: self.flowClaimSingleItemCheckoutNext.progress?.totalSteps ?? 0
        )
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
        return .postDateOfOccurrenceAndLocation
    }
}

extension OctopusGraphQL.FlowClaimDateOfOccurrencePlusLocationNextMutation: ClaimStepLoadingType {
    func getLoadingType() -> ClaimsLoadingType {
        return .postDateOfOccurrenceAndLocation
    }
}

extension OctopusGraphQL.FlowClaimContractSelectNextMutation: ClaimStepLoadingType {
    func getLoadingType() -> ClaimsLoadingType {
        return .postContractSelect
    }
}

extension OctopusGraphQL.FlowClaimConfirmEmergencyNextMutation: ClaimStepLoadingType {
    func getLoadingType() -> ClaimsLoadingType {
        return .postConfirmEmergency
    }
}

extension OctopusGraphQL.FlowClaimLocationNextMutation: ClaimStepLoadingType {
    func getLoadingType() -> ClaimsLoadingType {
        return .postDateOfOccurrenceAndLocation
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
