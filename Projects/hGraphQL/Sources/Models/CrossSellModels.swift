import Foundation

public struct CrossSell: Codable, Equatable, Hashable {
    public var title: String
    public var description: String
    public var imageURL: URL
    public var blurHash: String
    public var buttonText: String
    public var embarkStoryName: String?
    public var hasBeenSeen: Bool {
        didSet {
            UserDefaults.standard.set(hasBeenSeen, forKey: Self.hasBeenSeenKey(title: title))
            UserDefaults.standard.synchronize()
        }
    }

    fileprivate static func hasBeenSeenKey(title: String) -> String {
        "CrossSell-hasBeenSeen-\(title)"
    }

    public static func == (lhs: CrossSell, rhs: CrossSell) -> Bool {
        return lhs.hashValue == rhs.hashValue
    }

    public init(
        title: String,
        description: String,
        imageURL: URL,
        blurHash: String,
        buttonText: String,
        embarkStoryName: String? = nil,
        hasBeenSeen: Bool = false
    ) {
        self.title = title
        self.description = description
        self.imageURL = imageURL
        self.blurHash = blurHash
        self.buttonText = buttonText
        self.embarkStoryName = embarkStoryName
        self.hasBeenSeen = hasBeenSeen
    }

    init?(
        _ data: GraphQL.ActiveContractBundlesQuery.Data.ActiveContractBundle.PotentialCrossSell
    ) {
        title = "Accident insurance" // data.title
        description = "From 75 SEK / month" // data.description

        guard let parsedImageURL = URL(string: data.imageUrl) else {
            return nil
        }

        imageURL = parsedImageURL
        buttonText = "Calculate price" // data.callToAction
        embarkStoryName = data.action.asCrossSellEmbark?.embarkStory.name
        blurHash = data.blurHash
        hasBeenSeen = UserDefaults.standard.bool(forKey: Self.hasBeenSeenKey(title: title))
    }
}
