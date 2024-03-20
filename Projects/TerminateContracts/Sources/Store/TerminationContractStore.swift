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
    ) async {
        let terminationContext = state.currentTerminationContext ?? ""
        switch action {
        case let .startTermination(config):
            return await executeAsFiniteSignal(loadingType: .startTermination) { [weak self] in
                try await self?.terminateContractsService.startTermination(contractId: config.contractId)
            }
        case .sendTerminationDate:
            let inputDateToString = self.state.terminationDateStep?.date?.localDateString ?? ""
            return await executeAsFiniteSignal(loadingType: .sendTerminationDate) { [weak self] in
                return try await self?.terminateContractsService
                    .sendTerminationDate(
                        inputDateToString: inputDateToString,
                        terminationContext: terminationContext
                    )
            }
        case .sendConfirmDelete:
            return await executeAsFiniteSignal(loadingType: .sendTerminationDate) { [weak self] in
                try await self?.terminateContractsService.sendConfirmDelete(terminationContext: terminationContext)
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
                    self.send(.navigationAction(action: .openSetTerminationDateLandingScreen))
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

    typealias optionalResponse = (() async throws -> TerminateStepResponse?)?
    private func executeAsFiniteSignal(
        loadingType: TerminationContractLoadingAction,
        action: optionalResponse
    ) async {
        self.setLoading(for: loadingType)
        do {
            if let action = action {
                let data = try await action()
                if let data = data {
                    send(.setTerminationContext(context: data.context))
                    send(data.action)
                }
            }
            self.removeLoading(for: loadingType)
        } catch let error {
            send(.navigationAction(action: .openTerminationFailScreen))
            self.setError(error.localizedDescription, for: loadingType)
        }
    }
}
