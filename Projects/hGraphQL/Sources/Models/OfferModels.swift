import Flow
import Foundation

public typealias OfferData = GraphQL.QuoteBundleQuery.Data

public enum CheckoutStatus: String, Codable {
    case pending = "PENDING"
    case signing = "SIGNED"
    case completed = "COMPLETED"
    case failed = "FAILED"

    init?(
        status: GraphQL.CheckoutStatus?
    ) {
        guard let status = status else {
            return nil
        }

        self.init(rawValue: status.rawValue)
    }
}

public struct QuoteCart: Codable, Equatable {
    public let offerBundle: OfferBundle
    public let id: String
    public let checkoutStatus: CheckoutStatus?

    public init(
        quoteCart: GraphQL.QuoteCartFragment
    ) {
        self.offerBundle = .init(quoteCart: quoteCart)
        self.id = quoteCart.id
        self.checkoutStatus = .init(rawValue: quoteCart.checkout?.status.rawValue ?? "")
    }
}

public struct OfferBundle: Codable, Equatable {
    public var possibleVariations: [QuoteVariant]
    public let redeemedCampaigns: [RedeemedCampaign]
    public let signMethodForQuotes: SignMethodForQuotes
    public let quotes: [QuoteBundle.Quote]
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
        possibleVariations: [QuoteVariant],
        redeemedCampaigns: [RedeemedCampaign],
        signMethodForQuotes: OfferBundle.SignMethodForQuotes,
        id: UUID = UUID()
    ) {
        self.possibleVariations = possibleVariations
        self.redeemedCampaigns = redeemedCampaigns
        self.signMethodForQuotes = signMethodForQuotes
        self.quotes = []
        self.id = id
    }

    public init(
        data: OfferData,
        id: UUID = UUID()
    ) {
        possibleVariations = data.quoteBundle.possibleVariations.map { .init(variant: $0) }
        redeemedCampaigns = data.redeemedCampaigns.map { .init(displayValue: $0.displayValue) }
        signMethodForQuotes = .init(rawValue: data.signMethodForQuotes.rawValue) ?? .unknown
        self.quotes = []
        self.id = id
    }

    public init(
        quoteCart: GraphQL.QuoteCartFragment
    ) {
        let bundle = quoteCart.bundle!.fragments.quoteBundleFragment
        let id = quoteCart.bundle!.possibleVariations.first!.id

        possibleVariations = [.init(bundle: bundle, tag: nil, id: id)]
        redeemedCampaigns = []
        signMethodForQuotes =
            (.init(rawValue: quoteCart.checkoutMethods.first?.rawValue ?? "")
                ?? .unknown)
        quotes = bundle.quotes.map { QuoteBundle.Quote(quote: $0) } ?? []
        self.id = UUID()
    }
}

public struct QuoteVariant: Codable, Equatable {
    public init(
        bundle: QuoteBundle,
        tag: String?,
        id: String
    ) {
        self.bundle = bundle
        self.tag = tag
        self.id = id
    }

    public var bundle: QuoteBundle
    public let tag: String?
    public let id: String

    public init(
        variant: OfferData.QuoteBundle.PossibleVariation
    ) {
        self.bundle = QuoteBundle(bundle: variant.bundle.fragments.quoteBundleFragment)
        self.tag = variant.tag
        self.id = variant.id
    }

    public init(
        bundle: GraphQL.QuoteBundleFragment,
        tag: String?,
        id: String
    ) {
        self.bundle = QuoteBundle(bundle: bundle)
        self.tag = tag
        self.id = id
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
        bundle: GraphQL.QuoteBundleFragment
    ) {
        appConfiguration = .init(config: bundle.appConfiguration)
        bundleCost = .init(cost: bundle.bundleCost)
        frequentlyAskedQuestions = bundle.frequentlyAskedQuestions.map { .init(question: $0) }
        quotes = bundle.quotes.map { .init(quote: $0) }
        inception = .init(fragment: bundle.inception)
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
            config: GraphQL.QuoteBundleFragment.AppConfiguration
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
            cost: GraphQL.QuoteBundleFragment.BundleCost
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
            question: GraphQL.QuoteBundleFragment.FrequentlyAskedQuestion
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
            quote: GraphQL.QuoteBundleFragment.Quote
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
            fragment: GraphQL.QuoteBundleFragment.Inception
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
            public let correspondingQuotes: [String]
            public let currentInsurer: CurrentInsurer?

            public init(
                inception: GraphQL.QuoteBundleFragment.Inception.AsConcurrentInception
            ) {
                startDate = inception.startDate
                correspondingQuotes = inception.correspondingQuoteIds
                currentInsurer = .init(insurer: inception.currentInsurer)
            }
        }

        public struct CurrentInsurer: Codable, Equatable {
            public let displayName: String?
            public let switchable: Bool?
            public init?(
                insurer: GraphQL.QuoteBundleFragment.Inception.AsConcurrentInception.CurrentInsurer?
            ) {
                guard let insurer = insurer else { return nil }
                displayName = insurer.displayName
                switchable = insurer.switchable
            }

            public init?(
                insurer: GraphQL.QuoteBundleFragment.Inception.AsIndependentInceptions.Inception.CurrentInsurer?
            ) {
                guard let insurer = insurer else { return nil }
                displayName = insurer.displayName
                switchable = insurer.switchable
            }
        }

        public struct IndependentInception: Codable, Equatable {
            public var startDate: String?
            public let correspondingQuoteId: String
            public let currentInsurer: CurrentInsurer?

            public init(
                inception: GraphQL.QuoteBundleFragment.Inception.AsIndependentInceptions.Inception
            ) {
                startDate = inception.startDate
                correspondingQuoteId = inception.correspondingQuoteId
                currentInsurer = .init(insurer: inception.currentInsurer)
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
