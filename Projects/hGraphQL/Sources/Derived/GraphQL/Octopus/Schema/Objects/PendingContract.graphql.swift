// @generated
// This file was automatically generated and should not be edited.

import ApolloAPI

public extension OctopusGraphQL.Objects {
  /// A pending contract is a proto-contract that has yet to become a fully fledged insurance. It usually means it is meant
  /// to be activated when an existing external insurance has been cancelled (switching).
  ///
  /// It is split into its own type, because they are not "real" insurances until they become active ones.
  nonisolated static let PendingContract = ApolloAPI.Object(
    typename: "PendingContract",
    implementedInterfaces: [],
    keyFields: nil
  )
}