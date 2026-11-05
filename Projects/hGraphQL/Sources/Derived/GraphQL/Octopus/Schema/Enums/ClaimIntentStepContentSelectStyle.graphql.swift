// @generated
// This file was automatically generated and should not be edited.

@_spi(Internal) import ApolloAPI

public extension OctopusGraphQL {
  /// Decides the rendering style of the select step.
  ///
  /// If this is `BINARY` - then clients can assume that `ClaimIntentStepContentSelect.options` have two values.
  nonisolated enum ClaimIntentStepContentSelectStyle: String, EnumType {
    case pill = "PILL"
    case binary = "BINARY"
  }

}