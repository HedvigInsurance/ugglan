import Foundation

public struct CrossSell: Codable, Equatable, Hashable {
    public var typeOfContract: String
    public var title: String
    public var description: String
    public var imageURL: URL
    public var blurHash: String
    public var buttonText: String
    public var embarkStoryName: String?
    public var webActionURL: String?
    public var type: CrossSellType
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
        type: CrossSellType
    ) {
        self.title = title
        self.description = description
        self.imageURL = imageURL
        self.blurHash = blurHash
        self.buttonText = buttonText
        self.embarkStoryName = embarkStoryName
        self.webActionURL = webActionURL
        self.hasBeenSeen = hasBeenSeen
        self.typeOfContract = typeOfContract
        self.type = type
    }

    public init?(_ data: OctopusGraphQL.CrossSellFragment.CrossSell) {
        title = data.title
        description = data.description

        guard let parsedImageURL = URL(string: data.imageUrl) else {
            return nil
        }
        imageURL = parsedImageURL
        buttonText = data.title
        embarkStoryName = nil
        blurHash = data.blurHash
        hasBeenSeen = UserDefaults.standard.bool(
            forKey: Self.hasBeenSeenKey(typeOfContract: data.id)
        )
        webActionURL = data.storeUrl
        typeOfContract = data.id
        type = data.type?.crossSellType ?? .unknown
    }
}

extension OctopusGraphQL.CrossSellType {
    var crossSellType: CrossSellType {
        switch self {
        case .car:
            return .car
        case .home:
            return .home
        case .accident:
            return .accident
        case .pet:
            return .pet
        case .__unknown:
            return .unknown
        }
    }
}

public enum CrossSellType: Codable, Hashable {
    case car
    case home
    case accident
    case pet
    case unknown
}
