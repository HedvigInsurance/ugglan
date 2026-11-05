// @generated
// This file was automatically generated and should not be edited.

import ApolloAPI

public extension OctopusGraphQL.Objects {
  /// A task step is one that eventually completes itself.
  ///
  /// This is meant to be polled until `isCompleted` is true, and then concluded using `Mutation.claimIntentSubmitTask`.
  nonisolated static let ClaimIntentStepContentTask = ApolloAPI.Object(
    typename: "ClaimIntentStepContentTask",
    implementedInterfaces: [],
    keyFields: nil
  )
}