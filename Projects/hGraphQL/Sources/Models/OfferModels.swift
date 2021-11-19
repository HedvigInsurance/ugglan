import Flow
import Foundation

public typealias OfferData = GraphQL.QuoteBundleQuery.Data

public struct OfferBundle: Codable, Equatable {
    public var possibleVariations: [QuoteVariant]
    public let redeemedCampaigns: [RedeemedCampaign]
    public let signMethodForQuotes: SignMethodForQuotes
    public let id: UUID

    public enum SignMethodForQuotes: String, Codable {
        case swedishBankId = "SWEDISH_BANK_ID"
        case norwegianBankId = "NORWEGIAN_BANK_ID"
        case danishBankId = "DANISH_BANK_ID"
        case simpleSign = "SIMPLE_SIGN"
        case approveOnly = "APPROVE_ONLY"
        case unknown
    }

    public init(
        data: OfferData,
        id: UUID = UUID()
    ) {
        possibleVariations = data.quoteBundle.possibleVariations.map { .init(variant: $0) }
        redeemedCampaigns = data.redeemedCampaigns.map { .init(displayValue: $0.displayValue) }
        signMethodForQuotes = .init(rawValue: data.signMethodForQuotes.rawValue) ?? .unknown
        self.id = id
    }
}

public struct QuoteVariant: Codable, Equatable {
    public var bundle: QuoteBundle
    public let tag: String?
    public let id: String

    public init(
        variant: OfferData.QuoteBundle.PossibleVariation
    ) {
        self.bundle = QuoteBundle(bundle: variant.bundle)
        self.tag = variant.tag
        self.id = variant.id
    }
}

public struct QuoteBundle: Codable, Equatable {
    public let appConfiguration: AppConfiguration
    public let bundleCost: BundleCost
    public let frequentlyAskedQuestions: [FrequentlyAskedQuestion]
    public let quotes: [Quote]
    public var inception: Inception
    public var displayName: String

    public init(
        bundle: OfferData.QuoteBundle.PossibleVariation.Bundle
    ) {
        appConfiguration = .init(config: bundle.appConfiguration)
        bundleCost = .init(cost: bundle.bundleCost)
        frequentlyAskedQuestions = bundle.frequentlyAskedQuestions.map { .init(question: $0) }
        quotes = bundle.quotes.map { .init(quote: $0) }
        inception = .init(fragment: bundle.inception.fragments.inceptionFragment)
        displayName = bundle.displayName
    }

    public struct AppConfiguration: Codable, Equatable {
        public let showCampaignManagement: Bool
        public let showFaq: Bool
        public let ignoreCampaigns: Bool
        public let approveButtonTerminology: ApproveButtonTerminology
        public let startDateTerminology: StartDateTerminology
        public let gradientOption: Contract.GradientOption
        public let title: AppConfigTitle

        public init(
            config: OfferData.QuoteBundle.PossibleVariation.Bundle.AppConfiguration
        ) {
            showCampaignManagement = config.showCampaignManagement
            showFaq = config.showFaq
            ignoreCampaigns = config.ignoreCampaigns
            approveButtonTerminology = .init(rawValue: config.approveButtonTerminology.rawValue) ?? .unknown
            startDateTerminology = .init(rawValue: config.startDateTerminology.rawValue) ?? .unknown
            title = (.init(rawValue: config.title.rawValue) ?? .unknown)
            gradientOption = .init(rawValue: config.gradientOption.rawValue) ?? .one
        }

        public enum ApproveButtonTerminology: String, Codable {
            case approveChanges = "APPROVE_CHANGES"
            case confirmPurchase = "CONFIRM_PURCHASE"
            case unknown
        }

        public enum AppConfigTitle: String, Codable {
            case logo = "LOGO"
            case updateSummary = "UPDATE_SUMMARY"
            case unknown
        }

        public enum StartDateTerminology: String, Codable {
            case startDate = "START_DATE"
            case accessDate = "ACCESS_DATE"
            case unknown
        }
    }

    public struct BundleCost: Codable, Equatable {
        public let freeUntil: String?
        public let monthlyDiscount: MonetaryAmount
        public let monthlyGross: MonetaryAmount
        public let monthlyNet: MonetaryAmount

        public init(
            cost: OfferData.QuoteBundle.PossibleVariation.Bundle.BundleCost
        ) {
            freeUntil = cost.freeUntil
            monthlyDiscount = .init(fragment: cost.monthlyDiscount.fragments.monetaryAmountFragment)
            monthlyGross = .init(fragment: cost.monthlyGross.fragments.monetaryAmountFragment)
            monthlyNet = .init(fragment: cost.monthlyNet.fragments.monetaryAmountFragment)
        }
    }

    public struct FrequentlyAskedQuestion: Codable, Equatable {
        public let body: String?
        public let headline: String?
        public let id: String
        public init(
            question: OfferData.QuoteBundle.PossibleVariation.Bundle.FrequentlyAskedQuestion
        ) {
            id = question.id
            body = question.body
            headline = question.headline
        }
    }

    public struct Quote: Codable, Equatable {
        public let id: String
        public let ssn: String?
        public let email: String?
        public let displayName: String
        public let detailsTable: DetailAgreementsTable
        public let perils: [Perils]
        public let insurableLimits: [InsurableLimits]
        public let insuranceTerms: [TermsAndConditions]
        public var dataCollectionID: String?

        public init(
            quote: OfferData.QuoteBundle.PossibleVariation.Bundle.Quote
        ) {
            id = quote.id
            ssn = quote.ssn
            email = quote.email
            displayName = quote.displayName
            detailsTable = .init(fragment: quote.detailsTable.fragments.detailsTableFragment)
            perils = quote.contractPerils.map { .init(fragment: $0.fragments.perilFragment) }
            insurableLimits = quote.insurableLimits.map { .init(fragment: $0.fragments.insurableLimitFragment) }
            insuranceTerms = quote.insuranceTerms.map { .init(displayName: $0.displayName, url: $0.url) }
            dataCollectionID = quote.dataCollectionId
        }
    }

    public enum Inception: Codable, Equatable {
        case concurrent(inception: ConcurrentInception)
        case independent(inceptions: [IndependentInception])
        case unknown

        init(
            fragment: GraphQL.InceptionFragment
        ) {
            if let concurrent = fragment.asConcurrentInception {
                self = .concurrent(inception: .init(inception: concurrent))
            } else if let independentInception = fragment.asIndependentInceptions {
                self = .independent(inceptions: independentInception.inceptions.map { .init(inception: $0) })
            } else {
                self = .unknown
            }
        }

        public struct ConcurrentInception: Codable, Equatable {
            public var startDate: String?
            public let correspondingQuotes: [CorrespondingQuote]
            public let currentInsurer: CurrentInsurer?

            public init(
                inception: GraphQL.InceptionFragment.AsConcurrentInception
            ) {
                startDate = inception.startDate
                correspondingQuotes = inception.correspondingQuotes.map { .init(quote: $0) }
                currentInsurer = .init(insurer: inception.currentInsurer)
            }
        }

        public struct CurrentInsurer: Codable, Equatable {
            public let displayName: String?
            public let switchable: Bool?
            public init?(
                insurer: GraphQL.InceptionFragment.AsConcurrentInception.CurrentInsurer?
            ) {
                guard let insurer = insurer else { return nil }
                displayName = insurer.displayName
                switchable = insurer.switchable
            }

            public init?(
                insurer: GraphQL.InceptionFragment.AsIndependentInceptions.Inception.CurrentInsurer?
            ) {
                guard let insurer = insurer else { return nil }
                displayName = insurer.displayName
                switchable = insurer.switchable
            }
        }

        public struct IndependentInception: Codable, Equatable {
            public var startDate: String?
            public let correspondingQuote: CorrespondingQuote
            public let currentInsurer: CurrentInsurer?

            public init(
                inception: GraphQL.InceptionFragment.AsIndependentInceptions.Inception
            ) {
                startDate = inception.startDate
                correspondingQuote = .init(quote: inception.correspondingQuote)
                currentInsurer = .init(insurer: inception.currentInsurer)
            }
        }

        public struct CorrespondingQuote: Codable, Equatable {
            public let id: String?

            public init(
                quote: GraphQL.InceptionFragment.AsConcurrentInception.CorrespondingQuote
            ) {
                id = quote.asCompleteQuote?.id
            }
            public init(
                quote: GraphQL.InceptionFragment.AsIndependentInceptions.Inception.CorrespondingQuote
            ) {
                id = quote.asCompleteQuote?.id
            }
        }
    }
}

public struct RedeemedCampaign: Codable, Equatable {
    public let displayValue: String?
    public init(
        displayValue: String?
    ) {
        self.displayValue = displayValue
    }
}
