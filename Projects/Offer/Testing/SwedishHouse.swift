import Apollo
import Foundation
import Offer
import TestingUtil
import hCore
import hGraphQL

extension GraphQL.QuoteBundleQuery.Data {
	public static func makeSwedishHouse(
		bundleCost: GraphQL.QuoteBundleQuery.Data.QuoteBundle.BundleCost,
		redeemedCampaigns: [GraphQL.QuoteBundleQuery.Data.RedeemedCampaign]
	) -> GraphQL.QuoteBundleQuery.Data {
		GraphQL.QuoteBundleQuery.Data(
			quoteBundle: .init(
				quotes: [
					.init(
						id: "123",
						firstName: "Hedvig",
						lastName: "Hedvigsen",
						displayName: "House insurance",
						detailsTable: .init(
							title: "House insurance",
							sections: [
								.init(title: "Details", rows: generateHomeRows()),
								.init(
									title: "Extra buildings",
									rows: [
										.init(
											title: "Sauna",
											subtitle: "Has water connected",
											value: "40 m2"
										),
										.init(
											title: "Garage",
											subtitle: nil,
											value: "22 m2"
										),
									]
								),
							]
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
				bundleCost: bundleCost,
				frequentlyAskedQuestions: generateFrequentlyAskedQuestions(),
				inception: .makeIndependentInceptions(inceptions: [
					.init(
						startDate: "2020-05-10",
						correspondingQuote: .makeCompleteQuote(id: "123")
					)
                ]),
                appConfiguration: .init(
                    showCampaignManagement: true,
                    title: .logo
                )
			),
			signMethodForQuotes: GraphQL.SignMethod.swedishBankId,
			redeemedCampaigns: redeemedCampaigns
		)
	}
}
