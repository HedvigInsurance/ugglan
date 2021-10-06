import Foundation

public struct Highlight: Codable, Equatable {
    public var title: String
    public var description: String

    init(
        _ data: GraphQL.ActiveContractBundlesQuery.Data.ActiveContractBundle.PotentialCrossSell.Info.Highlight
    ) {
        self.title = data.title
        self.description = data.description
    }
}
