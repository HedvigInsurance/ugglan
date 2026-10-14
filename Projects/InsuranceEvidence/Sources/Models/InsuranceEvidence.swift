import AutomaticLog

@Loggable
public struct InsuranceEvidence {
    @Masked let url: String

    public init(url: String) {
        self.url = url
    }
}
