import Foundation

public struct Experiment: Codable, Equatable, Hashable, Sendable {
    public let name: String
    public let variant: String

    public init(name: String, variant: String) {
        self.name = name
        self.variant = variant
    }
}

@MainActor
public protocol ExperimentProvider {
    /// The experiments this member is currently in, to attach to cross-sell queries so the backend can decide what
    /// to offer. When the member's own flag values aren't in hand yet, for example right after a login, it waits
    /// up to a few seconds for them and then answers from whatever is known, so a query is delayed a little at most
    /// and never blocked. Empty when the member is in no experiment.
    func activeExperiments() async -> [Experiment]
}
