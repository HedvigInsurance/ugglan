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

extension OctopusGraphQL.FlowTerminationFragment.CurrentStep: Into {
    func into() -> TerminationContractAction {
        if let step = self.fragments.flowTerminationDateStepFragment {
            return .stepModelAction(action: .setTerminationDateStep(model: .init(with: step)))
        } else if let step = self.fragments.flowTerminationDeletionFragment {
            return .stepModelAction(action: .setTerminationDeletion(model: .init(with: step)))
        } else if let step = self.fragments.flowTerminationFailedFragment {
            return .stepModelAction(action: .setFailedStep(model: .init(with: step)))
        } else if let step = self.fragments.flowTerminationSuccessFragment {
            return .stepModelAction(action: .setSuccessStep(model: .init(with: step)))
        } else {
            return .navigationAction(action: .openTerminationUpdateAppScreen)
        }
    }
}

extension GraphQLMutation {
    func execute<TerminationStep: Into>(
        _ keyPath: KeyPath<Self.Data, TerminationStep>
    ) -> FiniteSignal<TerminationContractAction>
    where
        TerminationStep.To == TerminationContractAction, Self: TerminationStepLoadingType,
        Self.Data: TerminationStepContext
    {
        let octopus: hOctopus = Dependencies.shared.resolve()
        let loadingType = self.getLoadingType()
        return FiniteSignal { callback in
            let disposeBag = DisposeBag()
            let store: TerminationContractStore = globalPresentableStoreContainer.get()
            store.setLoading(for: loadingType)
            disposeBag += octopus.client.perform(mutation: self)
                .map { data in
                    callback(.value(.setTerminationContext(context: data.getContext())))
                    callback(.value(data[keyPath: keyPath].into()))
                    store.removeLoading(for: loadingType)
                    callback(.end)
                }
                .onError({ error in
                    switch loadingType {
                    case .startTermination:
                        store.send(.navigationAction(action: .openTerminationFailScreen))
                    default:
                       break
                    }
                    store.setError(L10n.General.errorBody, for: loadingType)
                    callback(.end)
                })
            return disposeBag
        }
    }
}

protocol TerminationStepContext {
    func getContext() -> String
}

extension OctopusGraphQL.FlowTerminationStartMutation.Data: TerminationStepContext {
    func getContext() -> String {
        return self.flowTerminationStart.context
    }
}

extension OctopusGraphQL.FlowTerminationDateNextMutation.Data: TerminationStepContext {
    func getContext() -> String {
        return self.flowTerminationDateNext.context
    }
}

extension OctopusGraphQL.FlowTerminationDeletionNextMutation.Data: TerminationStepContext {
    func getContext() -> String {
        return self.flowTerminationDeletionNext.context
    }
}

protocol TerminationStepLoadingType {
    func getLoadingType() -> TerminationContractLoadingAction
}

extension OctopusGraphQL.FlowTerminationStartMutation: TerminationStepLoadingType {
    func getLoadingType() -> TerminationContractLoadingAction {
        return .startTermination
    }
}

extension OctopusGraphQL.FlowTerminationDateNextMutation: TerminationStepLoadingType {
    func getLoadingType() -> TerminationContractLoadingAction {
        return .sendTerminationDate
    }
}

extension OctopusGraphQL.FlowTerminationDeletionNextMutation: TerminationStepLoadingType {
    func getLoadingType() -> TerminationContractLoadingAction {
        return .deleteTermination
    }
}
