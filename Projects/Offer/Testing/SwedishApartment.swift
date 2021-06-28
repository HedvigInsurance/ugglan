import Apollo
import Foundation
import Offer
import TestingUtil
import hCore
import hGraphQL

extension JSONObject {
	public static func makeSwedishApartment() -> JSONObject {
		GraphQL.QuoteBundleQuery.Data
			.init(
				quoteBundle: .init(
					quotes: [
						.init(
							id: "123",
							currentInsurer: nil,
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
						monthlyGross: .init(amount: "100", currency: "SEK"),
						monthlyDiscount: .init(amount: "100", currency: "SEK"),
						monthlyNet: .init(amount: "100", currency: "SEK")
					),
					frequentlyAskedQuestions: generateFrequentlyAskedQuestions()
				),
				redeemedCampaigns: []
			)
			.jsonObject
	}
}
