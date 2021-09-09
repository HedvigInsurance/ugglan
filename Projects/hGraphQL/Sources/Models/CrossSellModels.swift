import Foundation

public struct CrossSell: Codable, Equatable {
    public var title: String
    public var description: String
    public var imageURL: URL
    public var blurHash: String
    public var buttonText: String
    public var embarkStoryName: String?

    public init(
        title: String,
        description: String,
        imageURL: URL,
        blurHash: String,
        buttonText: String,
        embarkStoryName: String? = nil
    ) {
        self.title = title
        self.description = description
        self.imageURL = imageURL
        self.blurHash = blurHash
        self.buttonText = buttonText
        self.embarkStoryName = embarkStoryName
    }

    init?(
        _ data: GraphQL.ActiveContractBundlesQuery.Data.ActiveContractBundle.PotentialCrossSell
    ) {
        title = data.title
        description = data.description

        guard let parsedImageURL = URL(string: data.imageUrl) else {
            return nil
        }

        imageURL = parsedImageURL
        buttonText = data.callToAction
        embarkStoryName = data.action.asCrossSellEmbark?.embarkStory.name
        blurHash = data.blurHash
    }
}
