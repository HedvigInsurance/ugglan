import Flow

public protocol TerminateContractsService {
    func startTermination(contractId: String) -> FiniteSignal<TerminationContractAction>
    func sendTerminationDate(
        inputDateToString: String,
        terminationContext: String
    ) -> FiniteSignal<TerminationContractAction>
    func sendConfirmDelete(terminationContext: String) -> FiniteSignal<TerminationContractAction>
}
