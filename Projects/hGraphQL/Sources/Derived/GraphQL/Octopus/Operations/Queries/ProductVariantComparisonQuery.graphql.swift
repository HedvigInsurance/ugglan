// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI
@_spi(Execution) @_spi(Unsafe) import ApolloAPI

public extension OctopusGraphQL {
  nonisolated struct ProductVariantComparisonQuery: GraphQLQuery {
    public static let operationName: String = "ProductVariantComparison"
    public static let operationDocument: ApolloAPI.OperationDocument = .init(
      definition: .init(
        #"query ProductVariantComparison($termsVersions: [ID!]!) { productVariantComparison(termsVersions: $termsVersions) { __typename rows { __typename ...ProductVariantComparisonRowFragment } variantColumns { __typename ...ProductVariantFragment } } }"#,
        fragments: [InsuranceDocumentFragment.self, PerilFragment.self, ProductVariantComparisonRowFragment.self, ProductVariantFragment.self]
      ))

    public var termsVersions: [ID]

    public init(termsVersions: [ID]) {
      self.termsVersions = termsVersions
    }

    @_spi(Unsafe) public var __variables: Variables? { ["termsVersions": termsVersions] }

    nonisolated public struct Data: OctopusGraphQL.SelectionSet {
      @_spi(Unsafe) public let __data: DataDict
      @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

      @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { OctopusGraphQL.Objects.Query }
      @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
        .field("productVariantComparison", ProductVariantComparison.self, arguments: ["termsVersions": .variable("termsVersions")]),
      ] }
      @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
        ProductVariantComparisonQuery.Data.self
      ] }

      /// Compare perils and peril-specific coverage limits across tiers of a product, identified by termsVersions
      public var productVariantComparison: ProductVariantComparison { __data["productVariantComparison"] }

      /// ProductVariantComparison
      ///
      /// Parent Type: `ProductVariantComparison`
      nonisolated public struct ProductVariantComparison: OctopusGraphQL.SelectionSet {
        @_spi(Unsafe) public let __data: DataDict
        @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

        @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { OctopusGraphQL.Objects.ProductVariantComparison }
        @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
          .field("__typename", String.self),
          .field("rows", [Row].self),
          .field("variantColumns", [VariantColumn].self),
        ] }
        @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
          ProductVariantComparisonQuery.Data.ProductVariantComparison.self
        ] }

        /// Rows represent Peril-specific coverage
        public var rows: [Row] { __data["rows"] }
        /// Every column is represented by matching ProductVariant
        public var variantColumns: [VariantColumn] { __data["variantColumns"] }

        /// ProductVariantComparison.Row
        ///
        /// Parent Type: `ProductVariantComparisonRow`
        nonisolated public struct Row: OctopusGraphQL.SelectionSet {
          @_spi(Unsafe) public let __data: DataDict
          @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

          @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { OctopusGraphQL.Objects.ProductVariantComparisonRow }
          @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
            .field("__typename", String.self),
            .fragment(ProductVariantComparisonRowFragment.self),
          ] }
          @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
            ProductVariantComparisonQuery.Data.ProductVariantComparison.Row.self,
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

          public struct Fragments: FragmentContainer {
            @_spi(Unsafe) public let __data: DataDict
            @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

            public var productVariantComparisonRowFragment: ProductVariantComparisonRowFragment { _toFragment() }
          }

          public typealias Cell = ProductVariantComparisonRowFragment.Cell
        }

        /// ProductVariantComparison.VariantColumn
        ///
        /// Parent Type: `ProductVariant`
        nonisolated public struct VariantColumn: OctopusGraphQL.SelectionSet {
          @_spi(Unsafe) public let __data: DataDict
          @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

          @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { OctopusGraphQL.Objects.ProductVariant }
          @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
            .field("__typename", String.self),
            .fragment(ProductVariantFragment.self),
          ] }
          @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
            ProductVariantComparisonQuery.Data.ProductVariantComparison.VariantColumn.self,
            ProductVariantFragment.self
          ] }

          public var perils: [Peril] { __data["perils"] }
          public var typeOfContract: String { __data["typeOfContract"] }
          /// A `ProductVariant` is identified by its terms version, which is the more technical
          /// name for a unique incarnation of our insurances (products) at a point in time.
          public var termsVersion: OctopusGraphQL.ID { __data["termsVersion"] }
          public var documents: [Document] { __data["documents"] }
          public var displayName: String { __data["displayName"] }
          public var displayNameTier: String? { __data["displayNameTier"] }
          public var tierDescription: String? { __data["tierDescription"] }
          public var insurableLimits: [InsurableLimit] { __data["insurableLimits"] }

          public struct Fragments: FragmentContainer {
            @_spi(Unsafe) public let __data: DataDict
            @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

            public var productVariantFragment: ProductVariantFragment { _toFragment() }
          }

          public typealias Peril = ProductVariantFragment.Peril

          public typealias Document = ProductVariantFragment.Document

          public typealias InsurableLimit = ProductVariantFragment.InsurableLimit
        }
      }
    }
  }

}