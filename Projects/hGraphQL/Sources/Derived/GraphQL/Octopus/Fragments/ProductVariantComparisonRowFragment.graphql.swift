// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI
@_spi(Execution) @_spi(Unsafe) import ApolloAPI

public extension OctopusGraphQL {
  nonisolated struct ProductVariantComparisonRowFragment: OctopusGraphQL.SelectionSet, Fragment {
    public static var fragmentDefinition: StaticString {
      #"fragment ProductVariantComparisonRowFragment on ProductVariantComparisonRow { __typename title description cells { __typename isCovered coverageText } colorCode }"#
    }

    @_spi(Unsafe) public let __data: DataDict
    @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

    @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { OctopusGraphQL.Objects.ProductVariantComparisonRow }
    @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
      .field("__typename", String.self),
      .field("title", String.self),
      .field("description", String.self),
      .field("cells", [Cell].self),
      .field("colorCode", String?.self),
    ] }
    @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
      ProductVariantComparisonRowFragment.self
    ] }

    /// Peril title
    public var title: String { __data["title"] }
    /// Peril description
    public var description: String { __data["description"] }
    /// Coverage per tier
    public var cells: [Cell] { __data["cells"] }
    /// Color
    public var colorCode: String? { __data["colorCode"] }

    /// Cell
    ///
    /// Parent Type: `ProductVariantComparisonCell`
    nonisolated public struct Cell: OctopusGraphQL.SelectionSet {
      @_spi(Unsafe) public let __data: DataDict
      @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

      @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { OctopusGraphQL.Objects.ProductVariantComparisonCell }
      @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
        .field("__typename", String.self),
        .field("isCovered", Bool.self),
        .field("coverageText", String?.self),
      ] }
      @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
        ProductVariantComparisonRowFragment.Cell.self
      ] }

      /// If peril is covered
      public var isCovered: Bool { __data["isCovered"] }
      /// Coverage limit if known and configured, presented as formatted text
      public var coverageText: String? { __data["coverageText"] }
    }
  }

}