import Foundation

struct ExperimentDefinition: Equatable, Sendable {
    /// Also the Firebase user property holding the variant, so it must be a valid property name: at most 24
    /// characters, and a letter first. Firebase drops variant values longer than 36 characters.
    let name: String
    let unleashFlag: String
}

let knownExperiments: [ExperimentDefinition] = [
    // Variants DISCOUNT_50 (today's behaviour) and NO_DISCOUNT. The backend withholds the discount for NO_DISCOUNT.
    ExperimentDefinition(name: "ACCIDENT_DISCOUNT", unleashFlag: "accident_discount_experiment")
]

extension Experiment {
    /// The experiments a member is in, given the variant each Unleash flag assigns them: nil for a flag that is off
    /// for them or assigns them no variant.
    @MainActor
    static func active(
        in definitions: [ExperimentDefinition] = knownExperiments,
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
