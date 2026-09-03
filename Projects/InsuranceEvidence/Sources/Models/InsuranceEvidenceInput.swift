import AutomaticLog

@Loggable
public struct InsuranceEvidenceInput: Sendable, Hashable {
    @Masked public internal(set) var email: String
}
