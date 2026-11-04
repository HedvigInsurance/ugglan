// @generated
// This file was automatically generated and should not be edited.

import ApolloAPI

public extension OctopusGraphQL.Objects {
  /// A 'Member' is the central user-like concept of our platform, referring to someone who has bought insurance
  /// with Hedvig and is now as we call is a "member".
  ///
  /// The Member type in our schema must always refer to the member based on the current authentication, i.e. the
  /// subject in the bearer token of the Authorization header.
  ///
  /// This type must never be used in an unauthenticated context, and it must always refer to the member in the
  /// authorization header. This is usually done either by:
  /// - Returning it from `Query.currentMember`
  /// - or from a mutation with return type `MemberMutationOutput`, which will refer to the authenticated member.
  ///
  /// This is federated across multiple subgraphs, which enables us to attach data to it that "belongs to the
  /// currently authenticated member", such as your "active contracts" etc. These could have just as easily been placed
  /// at the top level like `Query.activeContracts`, respecting the current authentication, but placing them under
  /// `Member` gives a more intuitive model when interacting with it from the outside perspective.
  nonisolated static let Member = ApolloAPI.Object(
    typename: "Member",
    implementedInterfaces: [],
    keyFields: nil
  )
}