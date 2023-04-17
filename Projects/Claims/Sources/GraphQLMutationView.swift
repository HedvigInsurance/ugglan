import Foundation
import SwiftUI
import Apollo

struct GraphQLMutationView<Mutation: GraphQLMutation>: View {
    var client: ApolloClient
    var mutation: Mutation
    
    var body: some View {
        EmptyView().onAppear {
            
        }
    }
}

