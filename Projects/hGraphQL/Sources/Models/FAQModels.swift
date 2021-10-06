import Foundation

public struct FAQ: Codable, Equatable {
    public var title: String
    public var description: String

    init(
        _ data: GraphQL.ActiveContractBundlesQuery.Data.ActiveContractBundle.PotentialCrossSell.Info.Faq
    ) {
        self.title = data.headline
        self.description = data.body
    }
}
