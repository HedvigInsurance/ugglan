import Flow
import hCore

public class TerminateContractsDemoService: TerminateContractsService {
    public func startTermination(contractId: String) -> Flow.FiniteSignal<TerminationContractAction> {
        return FiniteSignal()
    }

    public func sendTerminationDate(
        inputDateToString: String,
        terminationContext: String
    ) -> Flow.FiniteSignal<TerminationContractAction> {
        return FiniteSignal()
    }

    public func sendConfirmDelete(terminationContext: String) -> Flow.FiniteSignal<TerminationContractAction> {
        return FiniteSignal()
    }
}
