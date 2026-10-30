import Foundation

public struct Experiment: Codable, Equatable, Hashable, Sendable {
    public let name: String
    public let variant: String

    public init(name: String, variant: String) {
        self.name = name
        self.variant = variant
    }
}

extension Experiment {
    /// The experiments a member is in, given the variant each Unleash flag assigns them: nil for a flag that is off
    /// for them or assigns them no variant.
    @MainActor
    static func active(
        in definitions: [(name: String, unleashFlag: String)],
        variantOf: (String) -> String?
    ) -> [Experiment] {
        definitions.compactMap { definition in
            guard let variant = variantOf(definition.unleashFlag) else { return nil }
            guard variant.range(of: "^[A-Z0-9_]+$", options: .regularExpression) != nil else {
                // The backend expects this shape, and a mistyped variant in the Unleash admin must not reach it.
                log.warn("Ignoring \(definition.name) variant '\(variant)': not SCREAMING_SNAKE_CASE")
                return nil
            }
            return Experiment(name: definition.name, variant: variant)
        }
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
