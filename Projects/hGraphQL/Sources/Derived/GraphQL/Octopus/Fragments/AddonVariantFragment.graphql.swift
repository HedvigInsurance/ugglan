// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI
@_spi(Execution) @_spi(Unsafe) import ApolloAPI

public extension OctopusGraphQL {
  nonisolated struct AddonVariantFragment: OctopusGraphQL.SelectionSet, Fragment {
    public static var fragmentDefinition: StaticString {
      #"fragment AddonVariantFragment on AddonVariant { __typename termsVersion product addonPerils { __typename title description coverageText colorCode } documents { __typename ...InsuranceDocumentFragment } displayName }"#
    }

    @_spi(Unsafe) public let __data: DataDict
    @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

    @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { OctopusGraphQL.Objects.AddonVariant }
    @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
      .field("__typename", String.self),
      .field("termsVersion", OctopusGraphQL.ID.self),
      .field("product", String.self),
      .field("addonPerils", [AddonPeril].self),
      .field("documents", [Document].self),
      .field("displayName", String.self),
    ] }
    @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
      AddonVariantFragment.self
    ] }

    /// A `AddonVariant` is identified by its terms version, which is the more technical
    /// name for a unique incarnation of our addons at a point in time.
    public var termsVersion: OctopusGraphQL.ID { __data["termsVersion"] }
    public var product: String { __data["product"] }
    public var addonPerils: [AddonPeril] { __data["addonPerils"] }
    public var documents: [Document] { __data["documents"] }
    public var displayName: String { __data["displayName"] }

    /// AddonPeril
    ///
    /// Parent Type: `AddonPeril`
    nonisolated public struct AddonPeril: OctopusGraphQL.SelectionSet {
      @_spi(Unsafe) public let __data: DataDict
      @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

      @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { OctopusGraphQL.Objects.AddonPeril }
      @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
        .field("__typename", String.self),
        .field("title", String.self),
        .field("description", String?.self),
        .field("coverageText", String?.self),
        .field("colorCode", String?.self),
      ] }
      @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
        AddonVariantFragment.AddonPeril.self
      ] }

      /// Short display title
      public var title: String { __data["title"] }
      /// Optional description
      public var description: String? { __data["description"] }
      /// Optional coverage detail, ex. covered amount
      public var coverageText: String? { __data["coverageText"] }
      /// Color code
      public var colorCode: String? { __data["colorCode"] }
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
        AddonVariantFragment.Document.self,
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
  }

}