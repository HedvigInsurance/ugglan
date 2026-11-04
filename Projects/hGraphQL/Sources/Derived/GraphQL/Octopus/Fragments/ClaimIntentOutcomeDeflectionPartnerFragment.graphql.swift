// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI
@_spi(Execution) @_spi(Unsafe) import ApolloAPI

public extension OctopusGraphQL {
  nonisolated struct ClaimIntentOutcomeDeflectionPartnerFragment: OctopusGraphQL.SelectionSet, Fragment {
    public static var fragmentDefinition: StaticString {
      #"fragment ClaimIntentOutcomeDeflectionPartnerFragment on ClaimIntentStepContentDeflectionPartner { __typename id imageUrl phoneNumber title description info url urlButtonTitle }"#
    }

    @_spi(Unsafe) public let __data: DataDict
    @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

    @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { OctopusGraphQL.Objects.ClaimIntentStepContentDeflectionPartner }
    @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
      .field("__typename", String.self),
      .field("id", OctopusGraphQL.ID.self),
      .field("imageUrl", OctopusGraphQL.Url?.self),
      .field("phoneNumber", String?.self),
      .field("title", String?.self),
      .field("description", String?.self),
      .field("info", String?.self),
      .field("url", OctopusGraphQL.Url?.self),
      .field("urlButtonTitle", String?.self),
    ] }
    @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
      ClaimIntentOutcomeDeflectionPartnerFragment.self
    ] }

    public var id: OctopusGraphQL.ID { __data["id"] }
    public var imageUrl: OctopusGraphQL.Url? { __data["imageUrl"] }
    public var phoneNumber: String? { __data["phoneNumber"] }
    public var title: String? { __data["title"] }
    public var description: String? { __data["description"] }
    public var info: String? { __data["info"] }
    public var url: OctopusGraphQL.Url? { __data["url"] }
    public var urlButtonTitle: String? { __data["urlButtonTitle"] }
  }

}