import Testing
import hCore

@testable import TerminateContracts

final class DeflectScreenContentTests {
    @Test(arguments: [
        TerminationSuggestionType.autoCancelSold,
        .autoCancelScrapped,
        .autoCancelDecommission,
    ])
    func autoCancelTypesReturnAutoCancelContent(suggestionType: TerminationSuggestionType) throws {
        let content = try #require(DeflectScreenContent.from(suggestionType: suggestionType))
        #expect(content.canContinueTermination == false)
        #expect(content.extraMessage != nil)
        #expect(content.explanations.isEmpty)
        #expect(content.info == nil)
        #expect(content.primaryAction == .dismiss)
    }

    @Test
    func autoDecommissionReturnsDecomContent() throws {
        let content = try #require(DeflectScreenContent.from(suggestionType: .autoDecommission))
        #expect(content.canContinueTermination == true)
        #expect(content.extraMessage == nil)
        #expect(content.explanations.count == 2)
        #expect(content.info != nil)
        #expect(content.primaryAction == .dismiss)
    }

    @Test
    func carAlreadyDecommissionReturnsRecommissionContent() throws {
        let content = try #require(DeflectScreenContent.from(suggestionType: .carAlreadyDecommission))
        #expect(content.canContinueTermination == true)
        #expect(content.extraMessage == nil)
        #expect(content.explanations.isEmpty)
        #expect(content.info == nil)
        #expect(content.primaryAction == .dismiss)
    }

    @Test(arguments: [
        TerminationSuggestionType.updateAddress,
        .upgradeCoverage,
        .downgradePrice,
        .redirect,
        .info,
        .unknown,
    ])
    func nonDeflectTypesReturnNil(suggestionType: TerminationSuggestionType) {
        #expect(DeflectScreenContent.from(suggestionType: suggestionType) == nil)
    }

    @Test
    func autoCancelTypesShareSameTitle() throws {
        let sold = try #require(DeflectScreenContent.from(suggestionType: .autoCancelSold))
        let scrapped = try #require(DeflectScreenContent.from(suggestionType: .autoCancelScrapped))
        let decom = try #require(DeflectScreenContent.from(suggestionType: .autoCancelDecommission))
        #expect(sold.title == scrapped.title)
        #expect(sold.title == decom.title)
    }

    @Test
    func autoCancelTypesHaveDifferentMessages() throws {
        let sold = try #require(DeflectScreenContent.from(suggestionType: .autoCancelSold))
        let scrapped = try #require(DeflectScreenContent.from(suggestionType: .autoCancelScrapped))
        let decom = try #require(DeflectScreenContent.from(suggestionType: .autoCancelDecommission))
        #expect(sold.message != scrapped.message)
        #expect(sold.message != decom.message)
        #expect(scrapped.message != decom.message)
    }
}
