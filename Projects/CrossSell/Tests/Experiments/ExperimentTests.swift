import XCTest

@testable import hCore

@MainActor
final class ExperimentTests: XCTestCase {
    func testTheAccidentDiscountFlagIsReportedUnderTheBackendsExperimentName() {
        let experiments = Experiment.active { flag in
            flag == "accident_discount_experiment" ? "NO_DISCOUNT" : nil
        }

        XCTAssertEqual(experiments, [Experiment(name: "ACCIDENT_DISCOUNT", variant: "NO_DISCOUNT")])
    }

    func testAFlagWithoutAVariantPutsTheMemberInNoExperiment() {
        XCTAssertEqual(Experiment.active { _ in nil }, [])
    }

    func testAVariantThatIsNotScreamingSnakeCaseIsDropped() {
        for variant in ["no-discount", "NoDiscount", "NO DISCOUNT", ""] {
            XCTAssertEqual(Experiment.active { _ in variant }, [], "variant '\(variant)'")
        }
    }

    func testOnlyTheDefinedFlagsAreReported() {
        let definitions = [
            ExperimentDefinition(name: "ONE", unleashFlag: "one"),
            ExperimentDefinition(name: "TWO", unleashFlag: "two"),
        ]

        let experiments = Experiment.active(in: definitions) { flag in flag == "two" ? "B" : nil }

        XCTAssertEqual(experiments, [Experiment(name: "TWO", variant: "B")])
    }
}
