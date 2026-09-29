import AutomaticLog

@Loggable
public struct InsuranceEvidenceInitialData: Sendable {
    @Masked let email: String

    public init(email: String) {
        self.email = email
    }
}
