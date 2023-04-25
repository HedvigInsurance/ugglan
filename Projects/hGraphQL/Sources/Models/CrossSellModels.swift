import Foundation

public struct CrossSellInfo: Codable, Equatable, Hashable {
    public var headerImageURL: URL
    public var title: String
    public var about: String
    public var highlights: [Highlight]
    public var faqs: [FAQ]
    public var insurableLimits: [InsurableLimits]
    public var insuranceTerms: [InsuranceTerm]
    public var perils: [Perils]

    init?(
        headerImageURL: URL,
        about: String,
        _ data: OctopusGraphQL.CrossSellFragment.CrossSell.ProductVariant
    ) {

        self.title = data.displayName
        self.about = about
        self.headerImageURL = headerImageURL
        self.highlights = data.fragments.productVariantFragment.highlights.map({ Highlight($0) })
        self.faqs = data.fragments.productVariantFragment.faq.compactMap({ FAQ($0) })
        self.insurableLimits = data.fragments.productVariantFragment.insurableLimits.map({ InsurableLimits($0) })
        self.insuranceTerms = data.fragments.productVariantFragment.documents.compactMap({ InsuranceTerm($0) })
        self.perils = data.fragments.productVariantFragment.perils.compactMap({ Perils(fragment: $0) })
    }
}

public struct CrossSell: Codable, Equatable, Hashable {
    public var typeOfContract: String
    public var title: String
    public var description: String
    public var imageURL: URL
    public var blurHash: String
    public var buttonText: String
    public var embarkStoryName: String?
    public var notificationType: String
    public var webActionURL: String?
    public var infos: [CrossSellInfo]
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
        webActionURL: String? = nil,
        hasBeenSeen: Bool = false,
        typeOfContract: String,
        infos: [CrossSellInfo]
    ) {
        self.notificationType = ""
        self.title = title
        self.description = description
        self.imageURL = imageURL
        self.blurHash = blurHash
        self.buttonText = buttonText
        self.embarkStoryName = embarkStoryName
        self.webActionURL = webActionURL
        self.hasBeenSeen = hasBeenSeen
        self.typeOfContract = typeOfContract
        self.infos = infos
    }

    public init?(_ data: OctopusGraphQL.CrossSellFragment.CrossSell) {
        title = data.title
        description = data.description

        guard let parsedImageURL = URL(string: data.imageUrl) else {
            return nil
        }
        notificationType = data.id
        imageURL = parsedImageURL
        buttonText = data.title
        embarkStoryName = nil
        blurHash = data.blurHash
        hasBeenSeen = UserDefaults.standard.bool(
            forKey: Self.hasBeenSeenKey(typeOfContract: data.id)
        )
        webActionURL = data.storeUrl
        typeOfContract = data.id

        infos = data.productVariants.compactMap({ CrossSellInfo(headerImageURL: parsedImageURL, about: data.about, $0) }
        )
    }
}
