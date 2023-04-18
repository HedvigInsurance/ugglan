import Apollo
import Foundation
import SwiftUI

struct GraphQLMutationView<Mutation: GraphQLMutation>: View {
    var client: ApolloClient
    var mutation: Mutation

    var body: some View {
        EmptyView()
            .onAppear {

            }
    }
}
