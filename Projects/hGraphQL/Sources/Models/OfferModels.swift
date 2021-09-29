import Foundation
import Flow

public typealias OfferData = GraphQL.QuoteBundleQuery.Data

public struct OfferBundle: Codable, Equatable {
    public static func == (lhs: OfferBundle, rhs: OfferBundle) -> Bool {
        return lhs.id == rhs.id
    }
    
    public let quoteBundle: QuoteBundle
    public let redeemedCampaigns: [RedeemedCampaign]
    public let id = UUID()
    
    public init(data: OfferData) {
        quoteBundle = .init(bundle: data.quoteBundle)
        redeemedCampaigns = data.redeemedCampaigns.map { .init(campaign: $0) }
    }
}

public struct QuoteBundle: Codable {
    public let appConfiguration: AppConfiguration
    public let bundleCost: BundleCost
    public let frequentlyAskedQuestions: [FrequentlyAskedQuestion]
    public let quotes: [Quote]
    public let inception: Inception?
    
    public init(bundle: OfferData.QuoteBundle) {
        appConfiguration = .init(config: bundle.appConfiguration)
        bundleCost = .init(cost: bundle.bundleCost)
        frequentlyAskedQuestions = bundle.frequentlyAskedQuestions.map { .init(question: $0) }
        quotes = bundle.quotes.map { .init(quote: $0) }
        inception = .init(fragment: bundle.inception.fragments.inceptionFragment)
    }
    
    public struct AppConfiguration: Codable {
        public let showCampaignManagement: Bool
        public let showFaq: Bool
        public let ignoreCampaigns: Bool
        public let approveButtonTerminology: ApproveButtonTerminology
        public let startDateTerminology: StartDateTerminology
        public let gradientOption: Contract.GradientOption
        public let title: AppConfigTitle
        
        public init(config: OfferData.QuoteBundle.AppConfiguration) {
            showCampaignManagement = config.showCampaignManagement
            showFaq = config.showFaq
            ignoreCampaigns = config.ignoreCampaigns
            approveButtonTerminology = .init(rawValue: config.approveButtonTerminology.rawValue) ?? .unknown
            startDateTerminology = .init(rawValue: config.startDateTerminology.rawValue) ?? .unknown
            title = (.init(rawValue: config.title.rawValue) ?? .unknown)
            #warning("add none here")
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
    
    public struct BundleCost: Codable {
        public let freeUntil: String?
        public let monthlyDiscount: MonetaryAmount
        public let monthlyGross: MonetaryAmount
        public let monthlyNet: MonetaryAmount
        
        public init(cost: OfferData.QuoteBundle.BundleCost) {
            freeUntil = cost.freeUntil
            monthlyDiscount = .init(fragment: cost.monthlyDiscount.fragments.monetaryAmountFragment)
            monthlyGross = .init(fragment: cost.monthlyGross.fragments.monetaryAmountFragment)
            monthlyNet = .init(fragment: cost.monthlyNet.fragments.monetaryAmountFragment)
        }
    }
    
    public struct FrequentlyAskedQuestion: Codable {
        public let body: String?
        public let headline: String?
        public let id: String
        public init(question: OfferData.QuoteBundle.FrequentlyAskedQuestion) {
            id = question.id
            body = question.body
            headline = question.headline
        }
    }
    
    public struct Quote: Codable {
        public let id: String
        public let firstName: String
        public let lastName: String
        public let ssn: String?
        public let email: String?
        public let displayName: String
        public let detailsTable: DetailAgreementsTable
        public let perils: [Perils]
        public  let insurableLimits: [InsurableLimits]
        public let insuranceTerms: [TermsAndConditions]
        
        public init(quote: OfferData.QuoteBundle.Quote) {
            id = quote.id
            firstName = quote.firstName
            lastName = quote.lastName
            ssn = quote.ssn
            email = quote.email
            displayName = quote.displayName
            detailsTable = .init(fragment: quote.detailsTable.fragments.detailsTableFragment)
            perils = quote.contractPerils.map { .init(fragment: $0.fragments.perilFragment) }
            insurableLimits = quote.insurableLimits.map { .init(fragment: $0.fragments.insurableLimitFragment) }
            insuranceTerms = quote.insuranceTerms.map { .init(displayName: $0.displayName, url: $0.url) }
        }
    }
    
    public struct Inception: Codable {
        public let inception: Either<ConcurrentInception, [IndependentInception]>?
        
        public init?(fragment: GraphQL.InceptionFragment) {
            if let concurrent = fragment.asConcurrentInception {
                inception = .left( .init(inception: concurrent))
            } else if let independentInception = fragment.asIndependentInceptions {
                inception = .right(independentInception.inceptions.map { .init(inception: $0) })
            } else { return nil }
        }
        
        public struct ConcurrentInception: Codable {
            public let startDate: String?
            public  let correspondingQuotes: [CorrespondingQuote]
            public  let currentInsurer: CurrentInsurer
            
            public init(inception: GraphQL.InceptionFragment.AsConcurrentInception) {
                startDate = inception.startDate
                correspondingQuotes = inception.correspondingQuotes.map { .init(quote: $0) }
                currentInsurer = .init(insurer: inception.currentInsurer)
            }
        }
        
        public struct CurrentInsurer: Codable {
            public let displayName: String?
            public  init(insurer: GraphQL.InceptionFragment.AsConcurrentInception.CurrentInsurer?) {
                displayName = insurer?.displayName
            }
            
            public   init(insurer: GraphQL.InceptionFragment.AsIndependentInceptions.Inception.CurrentInsurer?) {
                displayName = insurer?.displayName
            }
        }
        
        public  struct IndependentInception: Codable {
            public   let startDate: String?
            public   let correspondingQuotes: CorrespondingQuote
            public   let currentInsurer: CurrentInsurer
            
            public   init(inception: GraphQL.InceptionFragment.AsIndependentInceptions.Inception) {
                startDate = inception.startDate
                correspondingQuotes = .init(quote: inception.correspondingQuote)
                currentInsurer = .init(insurer: inception.currentInsurer)
            }
        }
        
        public struct CorrespondingQuote: Codable {
            public init(quote: GraphQL.InceptionFragment.AsConcurrentInception.CorrespondingQuote) {
                
            }
            public init(quote: GraphQL.InceptionFragment.AsIndependentInceptions.Inception.CorrespondingQuote) {
                
            }
        }
    }
    
    
    
    
}

public struct RedeemedCampaign: Codable {
    public init(campaign: GraphQL.QuoteBundleQuery.Data.RedeemedCampaign) {
        
    }
}
