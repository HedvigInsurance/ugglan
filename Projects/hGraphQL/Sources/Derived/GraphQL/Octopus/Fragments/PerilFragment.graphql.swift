// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI
@_spi(Execution) @_spi(Unsafe) import ApolloAPI

public extension OctopusGraphQL {
  nonisolated struct PerilFragment: OctopusGraphQL.SelectionSet, Fragment {
    public static var fragmentDefinition: StaticString {
      #"fragment PerilFragment on Peril { __typename id title description covered colorCode }"#
    }

    @_spi(Unsafe) public let __data: DataDict
    @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

    @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { OctopusGraphQL.Objects.Peril }
    @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
      .field("__typename", String.self),
      .field("id", OctopusGraphQL.ID.self),
      .field("title", String.self),
      .field("description", String.self),
      .field("covered", [String].self),
      .field("colorCode", String?.self),
    ] }
    @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
      PerilFragment.self
    ] }

    public var id: OctopusGraphQL.ID { __data["id"] }
    public var title: String { __data["title"] }
    public var description: String { __data["description"] }
    public var covered: [String] { __data["covered"] }
    public var colorCode: String? { __data["colorCode"] }
  }

}