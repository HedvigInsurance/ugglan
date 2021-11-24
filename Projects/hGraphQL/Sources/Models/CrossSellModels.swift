import Foundation

public struct CrossSellInfo: Codable, Equatable {
    public var headerImageURL: URL
    public var title: String
    public var about: String
    public var highlights: [Highlight]
    public var faqs: [FAQ]
    public var insurableLimits: [InsurableLimits]
    public var insuranceTerms: [InsuranceTerm]
    public var perils: [Perils]

    init(
        headerImageURL: URL,
        _ data: GraphQL.ActiveContractBundlesQuery.Data.ActiveContractBundle.PotentialCrossSell.Info
    ) {
        self.title = data.displayName
        self.about = data.aboutSection
        self.headerImageURL = headerImageURL
        self.highlights = data.highlights.map { highlight in Highlight(highlight) }
        self.faqs = data.faq.map { faq in FAQ(faq) }
        self.insurableLimits = data.insurableLimits.map { insurableLimit in
            InsurableLimits(fragment: insurableLimit.fragments.insurableLimitFragment)
        }
        self.insuranceTerms = data.insuranceTerms.compactMap { insuranceTerm in InsuranceTerm(insuranceTerm) }
        self.perils = data.contractPerils.map { peril in Perils(fragment: peril.fragments.perilFragment) }
    }
}

public struct CrossSell: Codable, Equatable {
    public var typeOfContract: String
    public var title: String
    public var description: String
    public var imageURL: URL
    public var blurHash: String
    public var buttonText: String
    public var embarkStoryName: String?
    public var notificationType: String
    public var info: CrossSellInfo?
    public var hasBeenSeen: Bool {
        didSet {
            UserDefaults.standard.set(hasBeenSeen, forKey: Self.hasBeenSeenKey(typeOfContract: typeOfContract))
            UserDefaults.standard.synchronize()
        }
    }

    fileprivate static func hasBeenSeenKey(typeOfContract: String) -> String {
        "CrossSell-hasBeenSeen-\(typeOfContract)"
    }

    public static func == (lhs: CrossSell, rhs: CrossSell) -> Bool {
        return lhs.typeOfContract == rhs.typeOfContract
    }

    public init(
        title: String,
        description: String,
        imageURL: URL,
        blurHash: String,
        buttonText: String,
        embarkStoryName: String? = nil,
        hasBeenSeen: Bool = false,
        typeOfContract: String,
        info: CrossSellInfo?
    ) {
        self.notificationType = ""
        self.title = title
        self.description = description
        self.imageURL = imageURL
        self.blurHash = blurHash
        self.buttonText = buttonText
        self.embarkStoryName = embarkStoryName
        self.hasBeenSeen = hasBeenSeen
        self.typeOfContract = typeOfContract
        self.info = info
    }

    init?(
        _ data: GraphQL.ActiveContractBundlesQuery.Data.ActiveContractBundle.PotentialCrossSell
    ) {
        title = data.title
        description = data.description

        guard let parsedImageURL = URL(string: data.imageUrl) else {
            return nil
        }

        notificationType = data.type.rawValue
        imageURL = parsedImageURL
        buttonText = data.callToAction
        embarkStoryName = data.action.asCrossSellEmbark?.embarkStory.name
        blurHash = data.blurHash
        hasBeenSeen = UserDefaults.standard.bool(
            forKey: Self.hasBeenSeenKey(typeOfContract: data.contractType.rawValue)
        )
        typeOfContract = data.contractType.rawValue
        info = CrossSellInfo(headerImageURL: parsedImageURL, data.info)
    }
}
