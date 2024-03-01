import Apollo
import Foundation
import Presentation
import hCore
import hGraphQL

public final class TerminationContractStore: LoadingStateStore<
    TerminationContractState, TerminationContractAction, TerminationContractLoadingAction
>
{
    @Inject var terminateContractsService: TerminateContractsService

    public override func effects(
        _ getState: @escaping () -> TerminationContractState,
        _ action: TerminationContractAction
    ) async throws {
        let terminationContext = state.currentTerminationContext ?? ""
        switch action {
        case let .startTermination(config):
            return try await executeAsFiniteSignal(loadingType: .startTermination) { [unowned self] in
                try await terminateContractsService.startTermination(contractId: config.contractId)
            }
        case .sendTerminationDate:
            return try await executeAsFiniteSignal(loadingType: .sendTerminationDate) { [unowned self] in
                let inputDateToString = self.state.terminationDateStep?.date?.localDateString ?? ""
                return try await terminateContractsService.sendTerminationDate(
                    inputDateToString: inputDateToString,
                    terminationContext: terminationContext
                )
            }
        case .sendConfirmDelete:
            return try await executeAsFiniteSignal(loadingType: .sendTerminationDate) { [unowned self] in
                try await terminateContractsService.sendConfirmDelete(terminationContext: terminationContext)
            }
        default:
            break
        }
    }

    public override func reduce(
        _ state: TerminationContractState,
        _ action: TerminationContractAction
    ) -> TerminationContractState {
        var newState = state
        switch action {
        case let .startTermination(config):
            newState.currentTerminationContext = nil
            newState.terminationContractId = nil
            newState.terminationDateStep = nil
            newState.terminationDeleteStep = nil
            newState.successStep = nil
            newState.failedStep = nil
            newState.config = config
        case let .setTerminationContext(context):
            newState.currentTerminationContext = context
        case let .setTerminationContractId(id):
            newState.terminationContractId = id
        case let .stepModelAction(step):
            switch step {
            case let .setTerminationDateStep(model):
                newState.terminationDateStep = model
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    self.send(.navigationAction(action: .openSetTerminationDateScreen))
                }
            case let .setTerminationDeletion(model):
                newState.terminationDeleteStep = model
                send(.navigationAction(action: .openTerminationDeletionScreen))
            case let .setSuccessStep(model):
                newState.successStep = model
                log.info("termination success", attributes: ["contractId": newState.config?.contractId])
                send(.navigationAction(action: .openTerminationSuccessScreen))
            case let .setFailedStep(model):
                log.info("termination failed", attributes: ["contractId": newState.config?.contractId])
                newState.failedStep = model
                send(.navigationAction(action: .openTerminationFailScreen))
            }
        case let .setTerminationDate(terminationDate):
            newState.terminationDateStep?.date = terminationDate
        case .setTerminationisDeletion:
            newState.config?.isDeletion = true
        default:
            break
        }

        return newState
    }

    private func executeAsFiniteSignal(
        loadingType: TerminationContractLoadingAction,
        action: @escaping () async throws -> TerminateStepResponse
    ) async throws {
        Task {
            self.setLoading(for: loadingType)
            do {
                let data = try await action()
                send(.setTerminationContext(context: data.context))
                send(data.action)
                self.removeLoading(for: loadingType)
            } catch let error {
                send(.navigationAction(action: .openTerminationFailScreen))
                self.setError(error.localizedDescription, for: loadingType)
            }
        }
    }
}
