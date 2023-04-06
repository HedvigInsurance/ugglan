import Flow
import Foundation

public typealias OfferData = GiraffeGraphQL.QuoteBundleQuery.Data

public enum CheckoutStatus: String, Codable {
    case pending = "PENDING"
    case signed = "SIGNED"
    case completed = "COMPLETED"
    case failed = "FAILED"

    init?(
        status: GiraffeGraphQL.CheckoutStatus?
    ) {
        guard let status = status else {
            return nil
        }

        self.init(rawValue: status.rawValue)
    }
}

public struct QuoteCart: Codable, Equatable {
    public let offerBundle: OfferBundle?
    public let id: String
    public let checkoutStatus: CheckoutStatus?
    public let checkoutStatusText: String?
    public let paymentConnection: PaymentConnection?

    public init(
        quoteCart: GiraffeGraphQL.QuoteCartFragment
    ) {
        self.offerBundle = .init(quoteCart: quoteCart)
        self.id = quoteCart.id
        self.checkoutStatus = .init(rawValue: quoteCart.checkout?.status.rawValue ?? "")
        self.paymentConnection = .init(id: quoteCart.paymentConnection?.id)
        self.checkoutStatusText = quoteCart.checkout?.statusText
    }
}

public struct PaymentConnection: Codable, Equatable {
    public let id: String?
}

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
        possibleVariations: [QuoteVariant],
        redeemedCampaigns: [RedeemedCampaign],
        signMethodForQuotes: OfferBundle.SignMethodForQuotes,
        id: UUID = UUID()
    ) {
        self.possibleVariations = possibleVariations
        self.redeemedCampaigns = redeemedCampaigns
        self.signMethodForQuotes = signMethodForQuotes
        self.id = id
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

    public init?(
        quoteCart: GiraffeGraphQL.QuoteCartFragment
    ) {
        guard
            let bundle = quoteCart.bundle?.fragments.quoteBundleFragment
        else { return nil }

        possibleVariations = bundle.possibleVariations.map { .init(variant: $0) }
        redeemedCampaigns =
            quoteCart.campaign?.displayValue == nil
            ? [] : [RedeemedCampaign(displayValue: quoteCart.campaign?.displayValue)]
        signMethodForQuotes =
            (.init(rawValue: quoteCart.checkoutMethods.first?.rawValue ?? "")
                ?? .unknown)
        self.id = UUID()
    }
}

public struct QuoteVariant: Codable, Equatable {
    public init(
        bundle: QuoteBundle,
        tag: String?,
        description: String?,
        id: String
    ) {
        self.bundle = bundle
        self.tag = tag
        self.description = description
        self.id = id
    }

    public var bundle: QuoteBundle
    public let tag: String?
    public let description: String?

    public let id: String

    public init(
        variant: GiraffeGraphQL.QuoteBundleFragment.PossibleVariation
    ) {
        self.bundle = .init(bundle: variant.bundle)
        self.tag = variant.tag
        self.description = variant.description
        self.id = variant.id
    }

    public init(
        variant: GiraffeGraphQL.QuoteBundleQuery.Data.QuoteBundle.PossibleVariation
    ) {
        self.bundle = .init(
            bundle: GiraffeGraphQL.QuoteBundleFragment.PossibleVariation.Bundle(
                unsafeResultMap: variant.bundle.resultMap
            )
        )
        self.tag = variant.tag
        self.description = nil
        self.id = variant.id
    }
}

public struct QuoteBundle: Codable, Equatable {
    init(
        bundle: GiraffeGraphQL.QuoteBundleFragment.PossibleVariation.Bundle
    ) {
        appConfiguration = .init(config: bundle.appConfiguration)
        bundleCost = .init(cost: bundle.bundleCost.fragments.costFragment)
        frequentlyAskedQuestions = bundle.frequentlyAskedQuestions.map { .init(question: $0) }
        quotes = bundle.quotes.map { .init(quote: $0) }
        inception = .init(fragment: bundle.inception)
        displayName = bundle.displayName
    }

    public let appConfiguration: AppConfiguration
    public let bundleCost: BundleCost
    public let frequentlyAskedQuestions: [FrequentlyAskedQuestion]
    public let quotes: [Quote]
    public var inception: Inception
    public var displayName: String
    public var gradientOption: Contract.GradientOption? {
        Contract.TypeOfContract(
            rawValue: self.quotes.first?.typeOfContract ?? ""
        )?.gradientOption
    }

    public struct AppConfiguration: Codable, Equatable {
        public let showCampaignManagement: Bool
        public let showFaq: Bool
        public let ignoreCampaigns: Bool
        public let approveButtonTerminology: ApproveButtonTerminology
        public let startDateTerminology: StartDateTerminology
        public let title: AppConfigTitle

        public init(
            config: GiraffeGraphQL.QuoteBundleFragment.PossibleVariation.Bundle.AppConfiguration
        ) {
            showCampaignManagement = config.showCampaignManagement
            showFaq = config.showFaq
            ignoreCampaigns = config.ignoreCampaigns
            approveButtonTerminology = .init(rawValue: config.approveButtonTerminology.rawValue) ?? .unknown
            startDateTerminology = .init(rawValue: config.startDateTerminology.rawValue) ?? .unknown
            title = (.init(rawValue: config.title.rawValue) ?? .unknown)
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
            cost: GiraffeGraphQL.CostFragment
        ) {
            freeUntil = cost.freeUntil
            monthlyDiscount = .init(fragment: cost.monthlyDiscount.fragments.monetaryAmountFragment)
            monthlyGross = .init(fragment: cost.monthlyGross.fragments.monetaryAmountFragment)
            monthlyNet = .init(fragment: cost.monthlyNet.fragments.monetaryAmountFragment)
        }
    }

    public struct FrequentlyAskedQuestion: Identifiable, Codable, Equatable {
        public let body: String?
        public let headline: String?
        public let id: String

        public init(
            question: GiraffeGraphQL.QuoteBundleFragment.PossibleVariation.Bundle.FrequentlyAskedQuestion
        ) {
            id = question.id
            body = question.body
            headline = question.headline
        }
    }

    public struct Quote: Codable, Equatable, Identifiable {
        public let id: String
        public let ssn: String?
        public let email: String?
        public let displayName: String
        public let detailsTable: DetailAgreementsTable
        public let perils: [Perils]
        public let insurableLimits: [InsurableLimits]
        public let insuranceTerms: [TermsAndConditions]
        public var dataCollectionID: String?
        public let typeOfContract: String
        public let insuranceType: String?

        public init(
            quote: GiraffeGraphQL.QuoteBundleFragment.PossibleVariation.Bundle.Quote
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
            typeOfContract = quote.typeOfContract.rawValue
            insuranceType = quote.insuranceType
        }
    }

    public enum Inception: Codable, Equatable {
        case concurrent(inception: ConcurrentInception)
        case independent(inceptions: [IndependentInception])
        case unknown

        init(
            fragment: GiraffeGraphQL.QuoteBundleFragment.PossibleVariation.Bundle.Inception
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
                inception: GiraffeGraphQL.QuoteBundleFragment.PossibleVariation.Bundle.Inception.AsConcurrentInception
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
                insurer: GiraffeGraphQL.QuoteBundleFragment.PossibleVariation.Bundle.Inception.AsConcurrentInception
                    .CurrentInsurer?
            ) {
                guard let insurer = insurer else { return nil }
                displayName = insurer.displayName
                switchable = insurer.switchable
            }

            public init?(
                insurer: GiraffeGraphQL.QuoteBundleFragment.PossibleVariation.Bundle.Inception.AsIndependentInceptions
                    .Inception.CurrentInsurer?
            ) {
                guard let insurer = insurer else { return nil }
                displayName = insurer.displayName
                switchable = insurer.switchable
            }
        }

        public struct IndependentInception: Identifiable, Codable, Equatable {
            public var startDate: String?
            public let correspondingQuoteId: String
            public let currentInsurer: CurrentInsurer?

            public var id: String {
                correspondingQuoteId + (currentInsurer?.displayName ?? "")
            }

            public init(
                inception: GiraffeGraphQL.QuoteBundleFragment.PossibleVariation.Bundle.Inception.AsIndependentInceptions
                    .Inception
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
