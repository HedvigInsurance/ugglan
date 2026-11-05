// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI
@_spi(Execution) @_spi(Unsafe) import ApolloAPI

public extension OctopusGraphQL {
  nonisolated struct DeflectFragment: OctopusGraphQL.SelectionSet, Fragment {
    public static var fragmentDefinition: StaticString {
      #"fragment DeflectFragment on ClaimIntentStepContentDeflection { __typename infoText warningText partnersInfo { __typename title description } content { __typename description title } faq { __typename title description } title partners { __typename ...ClaimIntentOutcomeDeflectionPartnerFragment } simplePartners { __typename ...ClaimIntentOutcomeDeflectionSimplePartnerFragment } buttonTitle }"#
    }

    @_spi(Unsafe) public let __data: DataDict
    @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

    @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { OctopusGraphQL.Objects.ClaimIntentStepContentDeflection }
    @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
      .field("__typename", String.self),
      .field("infoText", String?.self),
      .field("warningText", String?.self),
      .field("partnersInfo", PartnersInfo?.self),
      .field("content", Content.self),
      .field("faq", [Faq].self),
      .field("title", String?.self),
      .field("partners", [Partner].self),
      .field("simplePartners", [SimplePartner].self),
      .field("buttonTitle", String.self),
    ] }
    @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
      DeflectFragment.self
    ] }

    public var infoText: String? { __data["infoText"] }
    public var warningText: String? { __data["warningText"] }
    public var partnersInfo: PartnersInfo? { __data["partnersInfo"] }
    public var content: Content { __data["content"] }
    public var faq: [Faq] { __data["faq"] }
    public var title: String? { __data["title"] }
    public var partners: [Partner] { __data["partners"] }
    public var simplePartners: [SimplePartner] { __data["simplePartners"] }
    public var buttonTitle: String { __data["buttonTitle"] }

    /// PartnersInfo
    ///
    /// Parent Type: `ClaimIntentStepContentDeflectionInfoBlock`
    nonisolated public struct PartnersInfo: OctopusGraphQL.SelectionSet {
      @_spi(Unsafe) public let __data: DataDict
      @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

      @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { OctopusGraphQL.Objects.ClaimIntentStepContentDeflectionInfoBlock }
      @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
        .field("__typename", String.self),
        .field("title", String.self),
        .field("description", String.self),
      ] }
      @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
        DeflectFragment.PartnersInfo.self
      ] }

      public var title: String { __data["title"] }
      public var description: String { __data["description"] }
    }

    /// Content
    ///
    /// Parent Type: `ClaimIntentStepContentDeflectionInfoBlock`
    nonisolated public struct Content: OctopusGraphQL.SelectionSet {
      @_spi(Unsafe) public let __data: DataDict
      @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

      @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { OctopusGraphQL.Objects.ClaimIntentStepContentDeflectionInfoBlock }
      @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
        .field("__typename", String.self),
        .field("description", String.self),
        .field("title", String.self),
      ] }
      @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
        DeflectFragment.Content.self
      ] }

      public var description: String { __data["description"] }
      public var title: String { __data["title"] }
    }

    /// Faq
    ///
    /// Parent Type: `ClaimIntentStepContentDeflectionInfoBlock`
    nonisolated public struct Faq: OctopusGraphQL.SelectionSet {
      @_spi(Unsafe) public let __data: DataDict
      @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

      @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { OctopusGraphQL.Objects.ClaimIntentStepContentDeflectionInfoBlock }
      @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
        .field("__typename", String.self),
        .field("title", String.self),
        .field("description", String.self),
      ] }
      @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
        DeflectFragment.Faq.self
      ] }

      public var title: String { __data["title"] }
      public var description: String { __data["description"] }
    }

    /// Partner
    ///
    /// Parent Type: `ClaimIntentStepContentDeflectionPartner`
    nonisolated public struct Partner: OctopusGraphQL.SelectionSet {
      @_spi(Unsafe) public let __data: DataDict
      @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

      @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { OctopusGraphQL.Objects.ClaimIntentStepContentDeflectionPartner }
      @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
        .field("__typename", String.self),
        .fragment(ClaimIntentOutcomeDeflectionPartnerFragment.self),
      ] }
      @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
        DeflectFragment.Partner.self,
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

      public struct Fragments: FragmentContainer {
        @_spi(Unsafe) public let __data: DataDict
        @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

        public var claimIntentOutcomeDeflectionPartnerFragment: ClaimIntentOutcomeDeflectionPartnerFragment { _toFragment() }
      }
    }

    /// SimplePartner
    ///
    /// Parent Type: `ClaimIntentStepContentDeflectionSimplePartner`
    nonisolated public struct SimplePartner: OctopusGraphQL.SelectionSet {
      @_spi(Unsafe) public let __data: DataDict
      @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

      @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { OctopusGraphQL.Objects.ClaimIntentStepContentDeflectionSimplePartner }
      @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
        .field("__typename", String.self),
        .fragment(ClaimIntentOutcomeDeflectionSimplePartnerFragment.self),
      ] }
      @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
        DeflectFragment.SimplePartner.self,
        ClaimIntentOutcomeDeflectionSimplePartnerFragment.self
      ] }

      public var url: OctopusGraphQL.Url { __data["url"] }
      public var urlButtonTitle: String { __data["urlButtonTitle"] }

      public struct Fragments: FragmentContainer {
        @_spi(Unsafe) public let __data: DataDict
        @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

        public var claimIntentOutcomeDeflectionSimplePartnerFragment: ClaimIntentOutcomeDeflectionSimplePartnerFragment { _toFragment() }
      }
    }
  }

}