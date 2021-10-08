import Apollo
import Flow
import Foundation

extension ApolloClient {
    public func fetchInsuranceProviders(locale: String) -> Future<[InsuranceProvider]> {
        Future<[InsuranceProvider]> { completion in
            let cancellable = self.fetch(
                query:
                    GraphQL.InsuranceProvidersQuery(locale: GraphQL.Locale(rawValue: locale) ?? .enSe),
                cachePolicy: .returnCacheDataElseFetch,
                contextIdentifier: nil,
                queue: .main
            ) { result in
                switch result {
                case let .success(result):
                    if let providerData = result.data {
                        completion(.success(providerData.insuranceProviders.map { $0.fragments.insuranceProviderFragment }.map { InsuranceProvider.init(insuranceProviderFragment: $0) }))
                    } else if let errors = result.errors {
                        completion(.failure(GraphQLError(errors: errors)))
                    } else {
                        fatalError("Invalid GraphQL state")
                    }
                case let .failure(error):
                    completion(.failure(error))
                }
            }
            
            return Disposer { cancellable.cancel() }
        }
    }
}

public struct InsuranceProvider: Codable {
    public let name: String
    init(insuranceProviderFragment: GraphQL.InsuranceProviderFragment) {
        name = insuranceProviderFragment.name
    }
}
