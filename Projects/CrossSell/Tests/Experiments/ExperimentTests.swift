@preconcurrency import XCTest

@testable import hCore

@MainActor
final class ExperimentTests: XCTestCase {
    func testActiveReportsTheAccidentDiscountFlagUnderTheBackendsExperimentName() {
        let experiments = Experiment.active { flag in
            flag == "accident_discount_experiment" ? "NO_DISCOUNT" : nil
        }

        XCTAssertEqual(experiments, [Experiment(name: "ACCIDENT_DISCOUNT", variant: "NO_DISCOUNT")])
    }

    func testActiveWithAFlagWithoutAVariantReportsNoExperiment() {
        XCTAssertEqual(Experiment.active { _ in nil }, [])
    }

    func testActiveDropsAVariantThatIsNotScreamingSnakeCase() {
        for variant in ["no-discount", "NoDiscount", "NO DISCOUNT", ""] {
            XCTAssertEqual(Experiment.active { _ in variant }, [], "variant '\(variant)'")
        }
    }

    func testActiveReportsOnlyTheDefinedFlags() {
        let definitions = [
            ExperimentDefinition(name: "ONE", unleashFlag: "one"),
            ExperimentDefinition(name: "TWO", unleashFlag: "two"),
        ]

        let experiments = Experiment.active(in: definitions) { flag in flag == "two" ? "B" : nil }

        XCTAssertEqual(experiments, [Experiment(name: "TWO", variant: "B")])
    }
}
