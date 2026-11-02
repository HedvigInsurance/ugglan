import Testing

@testable import hCore

@MainActor
struct ExperimentTests {
    private let definitions = [(name: "ONE", unleashFlag: "one")]

    @Test
    func activeReportsTheFlagsVariantUnderTheExperimentName() {
        let experiments = Experiment.active(in: definitions) { flag in flag == "one" ? "VARIANT_A" : nil }

        #expect(experiments == [Experiment(name: "ONE", variant: "VARIANT_A")])
    }

    @Test
    func activeWithAFlagWithoutAVariantReportsNoExperiment() {
        #expect(Experiment.active(in: definitions) { _ in nil } == [])
    }

    @Test(arguments: ["no-discount", "NoDiscount", "NO DISCOUNT", ""])
    func activeDropsAVariantThatIsNotScreamingSnakeCase(variant: String) {
        #expect(Experiment.active(in: definitions) { _ in variant } == [])
    }

    @Test
    func activeReportsOnlyTheDefinedFlags() {
        let definitions = [
            (name: "ONE", unleashFlag: "one"),
            (name: "TWO", unleashFlag: "two"),
        ]

        let experiments = Experiment.active(in: definitions) { flag in flag == "two" ? "B" : nil }

        #expect(experiments == [Experiment(name: "TWO", variant: "B")])
    }
}
