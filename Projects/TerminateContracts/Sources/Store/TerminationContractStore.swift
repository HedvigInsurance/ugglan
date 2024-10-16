import Apollo
import Foundation
import PresentableStore
import hCore
import hGraphQL

public final class TerminationContractStore: LoadingStateStore<
    TerminationContractState, TerminationContractAction, TerminationContractLoadingAction
>
{
    @Inject var terminateContractsService: TerminateContractsClient

    public override func effects(
        _ getState: @escaping () -> TerminationContractState,
        _ action: TerminationContractAction
    ) async {
        let terminationContext = state.currentTerminationContext ?? ""
        switch action {
        case let .startTermination(config):
            return await executeAsFiniteSignal(loadingType: .getInitialStep) { [weak self] in
                try await self?.terminateContractsService.startTermination(contractId: config.contractId)
            }
        case .sendTerminationDate:
            let inputDateToString = self.state.terminationDateStep?.date?.localDateString ?? ""
            return await executeAsFiniteSignal(loadingType: .sendTerminationDate) {
                async let minimumTime: () = try Task.sleep(nanoseconds: 3_000_000_000)
                async let request = try self.terminateContractsService
                    .sendTerminationDate(
                        inputDateToString: inputDateToString,
                        terminationContext: terminationContext
                    )
                let data = try await [minimumTime, request] as [Any]

                let terminateStepResponse = data[1] as! TerminateStepResponse
                return terminateStepResponse
            }
        case .sendConfirmDelete:
            return await executeAsFiniteSignal(loadingType: .sendTerminationDate) {
                async let minimumTime: () = try Task.sleep(nanoseconds: 3_000_000_000)
                async let request = try self.terminateContractsService.sendConfirmDelete(
                    terminationContext: terminationContext
                )
                let data = try await [minimumTime, request] as [Any]
                let terminateStepResponse = data[1] as! TerminateStepResponse
                return terminateStepResponse
            }
        case let .submitSurvey(option, feedback):
            return await executeAsFiniteSignal(loadingType: .sendSurvey) { [weak self] in
                try await self?.terminateContractsService
                    .sendSurvey(
                        terminationContext: terminationContext,
                        option: option,
                        inputData: feedback
                    )
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
            newState.terminationDateStep = nil
            newState.terminationDeleteStep = nil
            newState.terminationSurveyStep = nil
            newState.successStep = nil
            newState.failedStep = nil
            newState.config = config
        case let .setTerminationContext(context):
            newState.currentTerminationContext = context
        case let .stepModelAction(step):
            switch step {
            case let .setTerminationDateStep(model):
                newState.terminationDateStep = model
                if let config = newState.config {
                    send(.navigationAction(action: .openSetTerminationDateLandingScreen(with: config)))
                }
            case let .setTerminationDeletion(model):
                newState.terminationDeleteStep = model
                if let config = newState.config {
                    send(.navigationAction(action: .openSetTerminationDateLandingScreen(with: config)))
                }
            case let .setSuccessStep(model):
                newState.successStep = model
                log.info("termination success", attributes: ["contractId": newState.config?.contractId])
                send(.navigationAction(action: .openTerminationSuccessScreen))
            case let .setFailedStep(model):
                log.info("termination failed", attributes: ["contractId": newState.config?.contractId])
                newState.failedStep = model
                send(.navigationAction(action: .openTerminationFailScreen))
            case let .setTerminationSurveyStep(model):
                newState.terminationSurveyStep = model
                send(
                    .navigationAction(
                        action: .openTerminationSurveyStep(options: model.options, subtitleType: .default)
                    )
                )
            }
        case let .setTerminationDate(terminationDate):
            newState.terminationDateStep?.date = terminationDate
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
                    await sendAsync(.setTerminationContext(context: data.context))
                    await sendAsync(data.action)
                }
            }
            self.removeLoading(for: loadingType)
        } catch let error {
            await sendAsync(.navigationAction(action: .openTerminationFailScreen))
            self.setError(error.localizedDescription, for: loadingType)
        }
    }
}
