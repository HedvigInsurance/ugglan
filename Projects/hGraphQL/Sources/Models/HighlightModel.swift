import Foundation

public struct Highlight: Codable, Equatable, Hashable {
    public var title: String
    public var description: String

    init(
        _ data: GiraffeGraphQL.ActiveContractBundlesQuery.Data.ActiveContractBundle.PotentialCrossSell.Info.Highlight
    ) {
        self.title = data.title
        self.description = data.description
    }
}
