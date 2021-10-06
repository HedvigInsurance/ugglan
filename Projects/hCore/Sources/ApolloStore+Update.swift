import Apollo
import Foundation

extension ApolloStore {
    public func update<Query: GraphQLQuery>(query: Query, updater: @escaping (inout Query.Data) -> Void) {
        withinReadWriteTransaction(
            { transaction in try transaction.update(query: query, updater) },
            completion: nil
        )
    }
}
