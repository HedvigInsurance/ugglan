// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI
@_spi(Execution) @_spi(Unsafe) import ApolloAPI

public extension OctopusGraphQL {
  nonisolated struct ClaimIntentOutcomeDeflectionSimplePartnerFragment: OctopusGraphQL.SelectionSet, Fragment {
    public static var fragmentDefinition: StaticString {
      #"fragment ClaimIntentOutcomeDeflectionSimplePartnerFragment on ClaimIntentStepContentDeflectionSimplePartner { __typename url urlButtonTitle }"#
    }

    @_spi(Unsafe) public let __data: DataDict
    @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

    @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { OctopusGraphQL.Objects.ClaimIntentStepContentDeflectionSimplePartner }
    @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
      .field("__typename", String.self),
      .field("url", OctopusGraphQL.Url.self),
      .field("urlButtonTitle", String.self),
    ] }
    @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
      ClaimIntentOutcomeDeflectionSimplePartnerFragment.self
    ] }

    public var url: OctopusGraphQL.Url { __data["url"] }
    public var urlButtonTitle: String { __data["urlButtonTitle"] }
  }

}