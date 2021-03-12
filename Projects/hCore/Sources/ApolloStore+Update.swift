import Apollo
import Foundation

public extension ApolloStore {
    func update<Query: GraphQLQuery>(query: Query, updater: @escaping (inout Query.Data) -> Void) {
        withinReadWriteTransaction({ transaction in
            try transaction.update(query: query, updater)
        }, completion: nil)
    }
}
