import Flow
import Foundation

public struct OfferBundle: Codable, Equatable {
    public var quoteBundle: QuoteBundle
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
        data: GraphQL.QuoteBundleQuery.Data,
        id: UUID = UUID()
    ) {
        quoteBundle = .init(bundle: data.quoteBundle)
        redeemedCampaigns = data.redeemedCampaigns.map { .init(displayValue: $0.displayValue) }
        signMethodForQuotes = .init(rawValue: data.signMethodForQuotes.rawValue) ?? .unknown
        self.id = id
    }
}

public struct QuoteBundle: Codable, Equatable {
    public let appConfiguration: AppConfiguration
    public let bundleCost: BundleCost
    public let frequentlyAskedQuestions: [FrequentlyAskedQuestion]
    public let quotes: [Quote]
    public var inception: Inception

    public init(
        bundle: GraphQL.QuoteBundleQuery.Data.QuoteBundle
    ) {
        appConfiguration = .init(config: bundle.appConfiguration)
        bundleCost = .init(cost: bundle.bundleCost)
        frequentlyAskedQuestions = bundle.frequentlyAskedQuestions.map { .init(question: $0) }
        quotes = bundle.quotes.map { .init(quote: $0) }
        inception = .init(fragment: bundle.inception.fragments.inceptionFragment)
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
            config: GraphQL.QuoteBundleQuery.Data.QuoteBundle.AppConfiguration
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
            cost: GraphQL.QuoteBundleQuery.Data.QuoteBundle.BundleCost
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
            question: GraphQL.QuoteBundleQuery.Data.QuoteBundle.FrequentlyAskedQuestion
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

        public init(
            quote: GraphQL.QuoteBundleQuery.Data.QuoteBundle.Quote
        ) {
            id = quote.id
            ssn = quote.ssn
            email = quote.email
            displayName = quote.displayName
            detailsTable = .init(fragment: quote.detailsTable.fragments.detailsTableFragment)
            perils = quote.contractPerils.map { .init(fragment: $0.fragments.perilFragment) }
            insurableLimits = quote.insurableLimits.map { .init(fragment: $0.fragments.insurableLimitFragment) }
            insuranceTerms = quote.insuranceTerms.map { .init(displayName: $0.displayName, url: $0.url) }
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
