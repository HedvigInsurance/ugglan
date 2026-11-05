// @generated
// This file was automatically generated and should not be edited.

import ApolloAPI

public extension OctopusGraphQL.Unions {
  /// Output type for AddonOffer mutation.
  /// Returns offer with quote and addons with prices etc to show in the offer page.
  nonisolated static let AddonOfferOutput = Union(
    name: "AddonOfferOutput",
    possibleTypes: [
      OctopusGraphQL.Objects.UserError.self,
      OctopusGraphQL.Objects.AddonOffer.self,
      OctopusGraphQL.Objects.AddonOfferDeflect.self
    ]
  )
}