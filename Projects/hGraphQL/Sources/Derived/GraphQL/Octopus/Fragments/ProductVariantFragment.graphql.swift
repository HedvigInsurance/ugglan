// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI
@_spi(Execution) @_spi(Unsafe) import ApolloAPI

public extension OctopusGraphQL {
  nonisolated struct ProductVariantFragment: OctopusGraphQL.SelectionSet, Fragment {
    public static var fragmentDefinition: StaticString {
      #"fragment ProductVariantFragment on ProductVariant { __typename perils { __typename ...PerilFragment } typeOfContract termsVersion documents { __typename ...InsuranceDocumentFragment } displayName displayNameTier tierDescription insurableLimits { __typename label limit description } }"#
    }

    @_spi(Unsafe) public let __data: DataDict
    @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

    @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { OctopusGraphQL.Objects.ProductVariant }
    @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
      .field("__typename", String.self),
      .field("perils", [Peril].self),
      .field("typeOfContract", String.self),
      .field("termsVersion", OctopusGraphQL.ID.self),
      .field("documents", [Document].self),
      .field("displayName", String.self),
      .field("displayNameTier", String?.self),
      .field("tierDescription", String?.self),
      .field("insurableLimits", [InsurableLimit].self),
    ] }
    @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
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

    /// Peril
    ///
    /// Parent Type: `Peril`
    nonisolated public struct Peril: OctopusGraphQL.SelectionSet {
      @_spi(Unsafe) public let __data: DataDict
      @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

      @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { OctopusGraphQL.Objects.Peril }
      @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
        .field("__typename", String.self),
        .fragment(PerilFragment.self),
      ] }
      @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
        ProductVariantFragment.Peril.self,
        PerilFragment.self
      ] }

      public var id: OctopusGraphQL.ID { __data["id"] }
      public var title: String { __data["title"] }
      public var description: String { __data["description"] }
      public var covered: [String] { __data["covered"] }
      public var colorCode: String? { __data["colorCode"] }

      public struct Fragments: FragmentContainer {
        @_spi(Unsafe) public let __data: DataDict
        @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

        public var perilFragment: PerilFragment { _toFragment() }
      }
    }

    /// Document
    ///
    /// Parent Type: `InsuranceDocument`
    nonisolated public struct Document: OctopusGraphQL.SelectionSet {
      @_spi(Unsafe) public let __data: DataDict
      @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

      @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { OctopusGraphQL.Objects.InsuranceDocument }
      @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
        .field("__typename", String.self),
        .fragment(InsuranceDocumentFragment.self),
      ] }
      @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
        ProductVariantFragment.Document.self,
        InsuranceDocumentFragment.self
      ] }

      public var displayName: String { __data["displayName"] }
      public var type: GraphQLEnum<OctopusGraphQL.InsuranceDocumentType> { __data["type"] }
      public var url: String { __data["url"] }

      public struct Fragments: FragmentContainer {
        @_spi(Unsafe) public let __data: DataDict
        @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

        public var insuranceDocumentFragment: InsuranceDocumentFragment { _toFragment() }
      }
    }

    /// InsurableLimit
    ///
    /// Parent Type: `InsurableLimit`
    nonisolated public struct InsurableLimit: OctopusGraphQL.SelectionSet {
      @_spi(Unsafe) public let __data: DataDict
      @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

      @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { OctopusGraphQL.Objects.InsurableLimit }
      @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
        .field("__typename", String.self),
        .field("label", String.self),
        .field("limit", String.self),
        .field("description", String.self),
      ] }
      @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
        ProductVariantFragment.InsurableLimit.self
      ] }

      public var label: String { __data["label"] }
      public var limit: String { __data["limit"] }
      public var description: String { __data["description"] }
    }
  }

}