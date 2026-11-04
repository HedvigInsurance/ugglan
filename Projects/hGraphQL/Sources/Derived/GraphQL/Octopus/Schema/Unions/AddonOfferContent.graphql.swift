// @generated
// This file was automatically generated and should not be edited.

import ApolloAPI

public extension OctopusGraphQL.Unions {
  /// AddonOfferSelectable is used when we have multiple variants for the same quote
  /// AddonOfferToggleable is used when we have only one variant
  nonisolated static let AddonOfferContent = Union(
    name: "AddonOfferContent",
    possibleTypes: [
      OctopusGraphQL.Objects.AddonOfferSelectable.self,
      OctopusGraphQL.Objects.AddonOfferToggleable.self
    ]
  )
}