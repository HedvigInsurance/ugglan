// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI
@_spi(Execution) @_spi(Unsafe) import ApolloAPI

public extension OctopusGraphQL {
  nonisolated struct ChatMessageDisclaimerFragment: OctopusGraphQL.SelectionSet, Fragment {
    public static var fragmentDefinition: StaticString {
      #"fragment ChatMessageDisclaimerFragment on ChatMessageDisclaimer { __typename description detailsDescription detailsTitle title type }"#
    }

    @_spi(Unsafe) public let __data: DataDict
    @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

    @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { OctopusGraphQL.Objects.ChatMessageDisclaimer }
    @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
      .field("__typename", String.self),
      .field("description", String?.self),
      .field("detailsDescription", String?.self),
      .field("detailsTitle", String?.self),
      .field("title", String?.self),
      .field("type", GraphQLEnum<OctopusGraphQL.ChatMessageDisclaimerType>.self),
    ] }
    @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
      ChatMessageDisclaimerFragment.self
    ] }

    public var description: String? { __data["description"] }
    /// The longer form of the description that's typically hidden behind a 'Read more' button.
    public var detailsDescription: String? { __data["detailsDescription"] }
    /// The title that goes with `detailsDescription`.
    public var detailsTitle: String? { __data["detailsTitle"] }
    public var title: String? { __data["title"] }
    public var type: GraphQLEnum<OctopusGraphQL.ChatMessageDisclaimerType> { __data["type"] }
  }

}