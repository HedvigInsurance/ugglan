@preconcurrency import XCTest

@testable import hCore

@MainActor
final class ExperimentTests: XCTestCase {
    private let definitions = [(name: "ONE", unleashFlag: "one")]

    func testActiveReportsTheFlagsVariantUnderTheExperimentName() {
        let experiments = Experiment.active(in: definitions) { flag in flag == "one" ? "VARIANT_A" : nil }

        XCTAssertEqual(experiments, [Experiment(name: "ONE", variant: "VARIANT_A")])
    }

    func testActiveWithAFlagWithoutAVariantReportsNoExperiment() {
        XCTAssertEqual(Experiment.active(in: definitions) { _ in nil }, [])
    }

    func testActiveDropsAVariantThatIsNotScreamingSnakeCase() {
        for variant in ["no-discount", "NoDiscount", "NO DISCOUNT", ""] {
            XCTAssertEqual(Experiment.active(in: definitions) { _ in variant }, [], "variant '\(variant)'")
        }
    }

    func testActiveReportsOnlyTheDefinedFlags() {
        let definitions = [
            (name: "ONE", unleashFlag: "one"),
            (name: "TWO", unleashFlag: "two"),
        ]

        let experiments = Experiment.active(in: definitions) { flag in flag == "two" ? "B" : nil }

        XCTAssertEqual(experiments, [Experiment(name: "TWO", variant: "B")])
    }
}
