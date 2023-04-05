import Foundation

public struct FAQ: Codable, Equatable, Hashable {
    public var title: String
    public var description: String

    init(
        _ data: GiraffeGraphQL.ActiveContractBundlesQuery.Data.ActiveContractBundle.PotentialCrossSell.Info.Faq
    ) {
        self.title = data.headline
        self.description = data.body
    }
}
