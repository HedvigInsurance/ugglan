import XCTest
import hCore

@testable import TerminateContracts

final class DeflectScreenContentTests: XCTestCase {
    func testAutoCancelSold_returnsAutoCancelContent() {
        let content = DeflectScreenContent.from(suggestionType: .autoCancelSold)
        XCTAssertNotNil(content)
        XCTAssertEqual(content?.canContinueTermination, true)
        XCTAssertNotNil(content?.extraMessage)
        XCTAssertTrue(content?.explanations.isEmpty ?? false)
        XCTAssertNil(content?.info)
    }

    func testAutoCancelScrapped_returnsAutoCancelContent() {
        let content = DeflectScreenContent.from(suggestionType: .autoCancelScrapped)
        XCTAssertNotNil(content)
        XCTAssertEqual(content?.canContinueTermination, true)
        XCTAssertNotNil(content?.extraMessage)
        XCTAssertTrue(content?.explanations.isEmpty ?? false)
    }

    func testAutoCancelDecommission_returnsAutoCancelContent() {
        let content = DeflectScreenContent.from(suggestionType: .autoCancelDecommission)
        XCTAssertNotNil(content)
        XCTAssertEqual(content?.canContinueTermination, true)
        XCTAssertNotNil(content?.extraMessage)
    }

    func testAutoDecommission_returnsDecomContent() {
        let content = DeflectScreenContent.from(suggestionType: .autoDecommission)
        XCTAssertNotNil(content)
        XCTAssertEqual(content?.canContinueTermination, true)
        XCTAssertNil(content?.extraMessage)
        XCTAssertEqual(content?.explanations.count, 2)
        XCTAssertNotNil(content?.info)
    }

    func testCarAlreadyDecommission_returnsRecommissionContent() {
        let content = DeflectScreenContent.from(suggestionType: .carAlreadyDecommission)
        XCTAssertNotNil(content)
        XCTAssertEqual(content?.canContinueTermination, true)
        XCTAssertNil(content?.extraMessage)
        XCTAssertTrue(content?.explanations.isEmpty ?? false)
        XCTAssertNil(content?.info)
    }

    func testNonDeflectTypes_returnNil() {
        XCTAssertNil(DeflectScreenContent.from(suggestionType: .updateAddress))
        XCTAssertNil(DeflectScreenContent.from(suggestionType: .upgradeCoverage))
        XCTAssertNil(DeflectScreenContent.from(suggestionType: .downgradePrice))
        XCTAssertNil(DeflectScreenContent.from(suggestionType: .redirect))
        XCTAssertNil(DeflectScreenContent.from(suggestionType: .info))
        XCTAssertNil(DeflectScreenContent.from(suggestionType: .unknown))
    }

    func testAutoCancelTypes_shareSameTitle() {
        let sold = DeflectScreenContent.from(suggestionType: .autoCancelSold)
        let scrapped = DeflectScreenContent.from(suggestionType: .autoCancelScrapped)
        let decom = DeflectScreenContent.from(suggestionType: .autoCancelDecommission)
        XCTAssertEqual(sold?.title, scrapped?.title)
        XCTAssertEqual(sold?.title, decom?.title)
    }

    func testAutoCancelTypes_haveDifferentMessages() {
        let sold = DeflectScreenContent.from(suggestionType: .autoCancelSold)
        let scrapped = DeflectScreenContent.from(suggestionType: .autoCancelScrapped)
        let decom = DeflectScreenContent.from(suggestionType: .autoCancelDecommission)
        XCTAssertNotEqual(sold?.message, scrapped?.message)
        XCTAssertNotEqual(sold?.message, decom?.message)
        XCTAssertNotEqual(scrapped?.message, decom?.message)
    }
}
