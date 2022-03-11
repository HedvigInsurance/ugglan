import Foundation

public struct InsuranceTerm: Codable, Equatable {
    public var displayName: String
    public var url: URL

    init?(
        _ data: GraphQL.ActiveContractBundlesQuery.Data.ActiveContractBundle.PotentialCrossSell.Info.InsuranceTerm
    ) {
        guard let url = URL(string: data.url) else {

            return nil
        }

        self.displayName = data.displayName
        self.url = url
    }
}
