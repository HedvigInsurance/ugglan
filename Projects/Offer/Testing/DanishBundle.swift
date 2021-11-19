import Apollo
import Foundation
import Offer
import TestingUtil
import hCore
import hGraphQL

func generateDanishTravelRows() -> [GraphQL.QuoteBundleQuery.Data.QuoteBundle.Quote.DetailsTable.Section.Row] {
    [
        .init(title: "Co-insured", subtitle: nil, value: "You + 2")
    ]
}

func generateDanishHomeRows() -> [GraphQL.QuoteBundleQuery.Data.QuoteBundle.Quote.DetailsTable.Section.Row] {
    [
        .init(title: "Street", subtitle: nil, value: "An address"),
        .init(title: "Postal code", subtitle: nil, value: "111 44"),
        .init(title: "Co-insured", subtitle: nil, value: "You + 2"),
    ]
}

func generateDanishAccidentRows() -> [GraphQL.QuoteBundleQuery.Data.QuoteBundle.Quote.DetailsTable.Section.Row] {
    [
        .init(title: "Co-insured", subtitle: nil, value: "You + 2")
    ]
}

func generateDanishDetailsTable(
    title: String,
    rows: [GraphQL.QuoteBundleQuery.Data.QuoteBundle.Quote.DetailsTable.Section.Row]
) -> GraphQL.QuoteBundleQuery.Data.QuoteBundle.Quote.DetailsTable {
    return .init(
        title: title,
        sections: [
            .init(
                title: "Details",
                rows: rows
            )
        ]
    )
}

extension GraphQL.QuoteBundleQuery.Data {
    public static func makeDanishBundle() -> GraphQL.QuoteBundleQuery.Data {
        GraphQL.QuoteBundleQuery.Data(
            quoteBundle: .init(
                quotes: [
                    .init(
                        id: "123",
                        displayName: "Indbo",
                        detailsTable: generateDetailsTable(
                            title: "Indbo",
                            rows: generateDanishHomeRows()
                        ),
                        contractPerils: generatePerils(),
                        insurableLimits: generateInsurableLimits(),
                        insuranceTerms: [
                            .init(
                                displayName: "Terms and pre-sale information",
                                url:
                                    "https://www.hedvig.com/da-en/terms/terms/travel.pdf",
                                type: .termsAndConditions
                            ),
                            .init(
                                displayName: "General terms",
                                url: "https://www.hedvig.com/da-en/terms",
                                type: .generalTerms
                            ),
                            .init(
                                displayName: "EU standard pre-sale information",
                                url: "https://www.hedvig.com/da-en/terms",
                                type: .preSaleInfoEuStandard
                            ),
                        ]
                    ),
                    .init(
                        id: "1234",
                        displayName: "Ulykke",
                        detailsTable: generateDetailsTable(
                            title: "Ulykke",
                            rows: generateDanishAccidentRows()
                        ),
                        contractPerils: generatePerils(),
                        insurableLimits: generateInsurableLimits(),
                        insuranceTerms: [
                            .init(
                                displayName: "Terms and pre-sale information",
                                url:
                                    "https://www.hedvig.com/da-en/terms/terms/accident.pdf",
                                type: .termsAndConditions
                            )
                        ]
                    ),
                    .init(
                        id: "12345",
                        displayName: "Rejse",
                        detailsTable: generateDetailsTable(
                            title: "Rejse",
                            rows: generateDanishTravelRows()
                        ),
                        contractPerils: generatePerils(),
                        insurableLimits: generateInsurableLimits(),
                        insuranceTerms: [
                            .init(
                                displayName: "Terms and pre-sale information",
                                url:
                                    "https://www.hedvig.com/da-en/terms/terms/travel.pdf",
                                type: .termsAndConditions
                            )
                        ]
                    ),
                ],
                bundleCost: .init(
                    monthlyDiscount: .init(amount: "100", currency: "DKK"),
                    monthlyGross: .init(amount: "100", currency: "DKK"),
                    monthlyNet: .init(amount: "100", currency: "DKK")
                ),
                frequentlyAskedQuestions: generateFrequentlyAskedQuestions(),
                inception: .makeConcurrentInception(
                    correspondingQuotes: [
                        .makeCompleteQuote(id: "123"),
                        .makeCompleteQuote(id: "1234"),
                        .makeCompleteQuote(id: "12345"),
                    ],
                    startDate: Date().localDateString,
                    currentInsurer: .init(id: "Hedvig", displayName: "Hedvig", switchable: true)
                ),
                appConfiguration: .init(
                    showCampaignManagement: true,
                    showFaq: true,
                    ignoreCampaigns: false,
                    approveButtonTerminology: .confirmPurchase,
                    startDateTerminology: .startDate,
                    title: .logo,
                    gradientOption: .gradientThree
                )
            ),
            signMethodForQuotes: GraphQL.SignMethod.simpleSign,
            redeemedCampaigns: []
        )
    }
}
