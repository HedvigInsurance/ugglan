// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI
@_spi(Execution) @_spi(Unsafe) import ApolloAPI

public extension OctopusGraphQL {
  nonisolated struct InsuranceDocumentFragment: OctopusGraphQL.SelectionSet, Fragment {
    public static var fragmentDefinition: StaticString {
      #"fragment InsuranceDocumentFragment on InsuranceDocument { __typename displayName type url }"#
    }

    @_spi(Unsafe) public let __data: DataDict
    @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

    @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { OctopusGraphQL.Objects.InsuranceDocument }
    @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
      .field("__typename", String.self),
      .field("displayName", String.self),
      .field("type", GraphQLEnum<OctopusGraphQL.InsuranceDocumentType>.self),
      .field("url", String.self),
    ] }
    @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
      InsuranceDocumentFragment.self
    ] }

    public var displayName: String { __data["displayName"] }
    public var type: GraphQLEnum<OctopusGraphQL.InsuranceDocumentType> { __data["type"] }
    public var url: String { __data["url"] }
  }

}