import Apollo
import Foundation
import Offer
import TestingUtil
import hCore
import hGraphQL

extension GraphQL.QuoteBundleQuery.Data {
	public static func makeSwedishApartmentMovingFlow() -> GraphQL.QuoteBundleQuery.Data {
		GraphQL.QuoteBundleQuery.Data(
			quoteBundle: .init(
				quotes: [
					.init(
						id: "123",
						firstName: "Hedvig",
						lastName: "Hedvigsen",
						displayName: "Home insurance rental",
						detailsTable: generateDetailsTable(
							title: "Home insurance rental",
							rows: generateHomeRows()
						),
						perils: generatePerils(),
						insurableLimits: generateInsurableLimits(),
						insuranceTerms: [
							.init(
								displayName: "Terms and pre-sale information",
								url:
									"https://www.hedvig.com/no-en/terms/terms/travel.pdf",
								type: .termsAndConditions
							)
						]
					)
				],
				bundleCost: .init(
					monthlyDiscount: .init(amount: "100", currency: "SEK"),
					monthlyGross: .init(amount: "100", currency: "SEK"),
					monthlyNet: .init(amount: "100", currency: "SEK")
				),
				frequentlyAskedQuestions: generateFrequentlyAskedQuestions(),
				inception: .makeIndependentInceptions(inceptions: [
					.init(
						startDate: "2020-05-10",
						currentInsurer: nil,
						correspondingQuote: .makeCompleteQuote(id: "123")
					)
				]),
				appConfiguration: .init(
					showCampaignManagement: false,
					title: .updateSummary,
					gradientOption: .gradientOne
				)
			),
			signMethodForQuotes: GraphQL.SignMethod.approveOnly,
			redeemedCampaigns: []
		)
	}
}
