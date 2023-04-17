import Foundation
import hCore
import hGraphQL
import Apollo
import Flow
import Presentation

protocol Into {
    associatedtype To
    func into() -> To
}

extension OctopusGraphQL.FlowClaimFragment.CurrentStep: Into {
    func into() -> ClaimsAction {
        if let step = self.fragments.flowClaimPhoneNumberStepFragment {
            let model = FlowClaimPhoneNumberStepModel(with: step)
            return .stepModelAction(action: .setPhoneNumber(model: model))
//        }
//        else if let step = self.fragments.flowClaimAudioRecordingStepFragment {
//            actions.append(.stepModelAction(action: .setAudioStep(model: .init(with: step))))
//            actions.append(.navigationAction(action: .openAudioRecordingScreen))
//        } else if let step = self.fragments.flowClaimSingleItemStepFragment {
//            actions.append(.stepModelAction(action: .setSingleItem(model: FlowClamSingleItemStepModel(with: step))))
//            actions.append(.navigationAction(action: .openSingleItemScreen))
//        } else if let step = self.fragments.flowClaimSingleItemCheckoutStepFragment {
//            actions.append(.stepModelAction(action: .setSingleItemCheckoutStep(model: .init(with: step))))
//            actions.append(.navigationAction(action: .openCheckoutNoRepairScreen))
//        } else if let step = self.fragments.flowClaimLocationStepFragment {
//            actions.append(.stepModelAction(action: .setLocation(model: .init(with: step))))
//            actions.append(.navigationAction(action: .openLocationPicker(type: .submitLocation)))
//        } else if let step = self.fragments.flowClaimDateOfOccurrenceStepFragment {
//            actions.append(.stepModelAction(action: .setDateOfOccurence(model: .init(with: step))))
//            actions.append(.navigationAction(action: .openDatePicker(type: .submitDateOfOccurence)))
//        } else if let step = self.fragments.flowClaimSummaryStepFragment {
//            if let singleItemStep = step.singleItemStep?.fragments.flowClaimSingleItemStepFragment {
//                actions.append(.stepModelAction(action: .setSingleItem(model: .init(with: singleItemStep))))
//            }
//            let locationStep = step.locationStep.fragments.flowClaimLocationStepFragment
//            actions.append(.stepModelAction(action: .setLocation(model: .init(with: locationStep))))
//
//            let dateOfOccurrenceStep = step.dateOfOccurrenceStep.fragments.flowClaimDateOfOccurrenceStepFragment
//            actions.append(.stepModelAction(action: .setDateOfOccurence(model: .init(with: dateOfOccurrenceStep))))
//            actions.append(.stepModelAction(action: .setSummaryStep(model: .init(with: step))))
//            actions.append(.navigationAction(action: .openSummaryScreen))
        } else if let step = self.fragments.flowClaimDateOfOccurrencePlusLocationStepFragment {
            return .stepModelAction(action: .setDateOfOccurrencePlusLocation(model: .init(dateOfOccurencePlusLocationModel: .init(with: step),
                                                                                          dateOfOccurenceModel: .init(with: step.dateOfOccurrenceStep.fragments.flowClaimDateOfOccurrenceStepFragment),
                                                                                          locationModel: .init(with: step.locationStep.fragments.flowClaimLocationStepFragment))))
            //        } else if let step = self.fragments.flowClaimFailedStepFragment {
            //            actions.append(.stepModelAction(action: .setFailedStep(model: .init(with: step))))
            //            actions.append(.navigationAction(action: .openFailureSceen))
//        } else if let step = self.fragments.flowClaimSuccessStepFragment {
//            actions.append(.stepModelAction(action: .setSuccessStep(model: .init(with: step))))
            //            if case .claimNextSingleItemCheckout = action {
            //            } else {
            //                actions.append(.navigationAction(action: .openSuccessScreen))
            //            }
        } else {
            return .navigationAction(action: .openUpdateAppScreen)
        }
    }
}

extension GraphQLMutation {
    func execute<ClaimStep: Into>(_ keyPath: KeyPath<Self.Data, ClaimStep>) -> FiniteSignal<ClaimsAction>
    where ClaimStep.To == ClaimsAction, Self: ClaimStepLoadingType {
        let octopus: hOctopus = Dependencies.shared.resolve()
        return FiniteSignal { callback in
            let disposeBag = DisposeBag()
            callback(.value(.setLoadingState(action: self.getLoadingType(), state: .loading)))
            disposeBag += octopus.client.perform(mutation: self).map { data in
                if let data = data as? ClaimStepId  {
                    callback(.value(.setNewClaimId(with: data.getStepId())))
                }
                if let data = data as? ClaimStepContext  {
                    callback(.value(.setNewClaimContext(context: data.getContext())))
                }
                callback(.value(data[keyPath: keyPath].into()))
                callback(.value(.setLoadingState(action: self.getLoadingType(), state: nil)))
            }.onError({ error in
                callback(.value(.setLoadingState(action: self.getLoadingType() , state: .error(error: L10n.General.errorBody))))
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
