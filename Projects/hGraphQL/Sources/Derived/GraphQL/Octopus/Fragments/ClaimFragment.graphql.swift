// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI
@_spi(Execution) @_spi(Unsafe) import ApolloAPI

public extension OctopusGraphQL {
  nonisolated struct ClaimFragment: OctopusGraphQL.SelectionSet, Fragment {
    public static var fragmentDefinition: StaticString {
      #"fragment ClaimFragment on Claim { __typename targetFileUploadUri id outcome status submittedAt audioUrl memberFreeText payoutAmount { __typename ...MoneyFragment } productVariant { __typename ...ProductVariantFragment } claimType conversation { __typename ...ConversationFragment } appealInstructionsUrl isUploadingFilesEnabled showClaimClosedFlow infoText displayItems { __typename displayTitle displayValue } contractId }"#
    }

    @_spi(Unsafe) public let __data: DataDict
    @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

    @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { OctopusGraphQL.Objects.Claim }
    @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
      .field("__typename", String.self),
      .field("targetFileUploadUri", String.self),
      .field("id", OctopusGraphQL.ID.self),
      .field("outcome", GraphQLEnum<OctopusGraphQL.ClaimOutcome>?.self),
      .field("status", GraphQLEnum<OctopusGraphQL.ClaimStatus>?.self),
      .field("submittedAt", OctopusGraphQL.DateTime.self),
      .field("audioUrl", String?.self),
      .field("memberFreeText", String?.self),
      .field("payoutAmount", PayoutAmount?.self),
      .field("productVariant", ProductVariant?.self),
      .field("claimType", String?.self),
      .field("conversation", Conversation.self),
      .field("appealInstructionsUrl", String?.self),
      .field("isUploadingFilesEnabled", Bool.self),
      .field("showClaimClosedFlow", Bool.self),
      .field("infoText", String?.self),
      .field("displayItems", [DisplayItem].self),
      .field("contractId", String?.self),
    ] }
    @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
      ClaimFragment.self
    ] }

    /// Use this relative path as the target for file uploads.
    ///
    /// This needs to be placed on top of the base URL of the API (usually `https://gateway.hedvig.com`
    /// or the staging equivalent) like so: "<baseUrl><targetFileUploadUri>".
    ///
    /// This target accepts multipart file uploads, and will automatically attach the uploaded files to the given claim.
    /// Therefore, the same claim can be refreshed in GraphQL and it should be visible in the `Claim.files` field.
    public var targetFileUploadUri: String { __data["targetFileUploadUri"] }
    public var id: OctopusGraphQL.ID { __data["id"] }
    public var outcome: GraphQLEnum<OctopusGraphQL.ClaimOutcome>? { __data["outcome"] }
    public var status: GraphQLEnum<OctopusGraphQL.ClaimStatus>? { __data["status"] }
    public var submittedAt: OctopusGraphQL.DateTime { __data["submittedAt"] }
    public var audioUrl: String? { __data["audioUrl"] }
    public var memberFreeText: String? { __data["memberFreeText"] }
    public var payoutAmount: PayoutAmount? { __data["payoutAmount"] }
    /// Terms & conditions for the claim found using claims contractId and dateOfOccurrence, otherwise null.
    public var productVariant: ProductVariant? { __data["productVariant"] }
    public var claimType: String? { __data["claimType"] }
    /// Return the relevant conversation for this claim.
    ///
    /// These conversations can be one of two kinds:
    /// - either it will be a dedicated conversation for this specific claim
    /// - or it will be the "legacy conversation", containing the entire old chat history
    ///
    /// The first one will be given for claims that are newer, created after the release of conversations.
    /// The second one for all other (older) claims.
    public var conversation: Conversation { __data["conversation"] }
    public var appealInstructionsUrl: String? { __data["appealInstructionsUrl"] }
    public var isUploadingFilesEnabled: Bool { __data["isUploadingFilesEnabled"] }
    public var showClaimClosedFlow: Bool { __data["showClaimClosedFlow"] }
    public var infoText: String? { __data["infoText"] }
    public var displayItems: [DisplayItem] { __data["displayItems"] }
    public var contractId: String? { __data["contractId"] }

    /// PayoutAmount
    ///
    /// Parent Type: `Money`
    nonisolated public struct PayoutAmount: OctopusGraphQL.SelectionSet {
      @_spi(Unsafe) public let __data: DataDict
      @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

      @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { OctopusGraphQL.Objects.Money }
      @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
        .field("__typename", String.self),
        .fragment(MoneyFragment.self),
      ] }
      @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
        ClaimFragment.PayoutAmount.self,
        MoneyFragment.self
      ] }

      public var amount: Double { __data["amount"] }
      /// Currency of the money (ISO 4217).
      public var currencyCode: GraphQLEnum<OctopusGraphQL.CurrencyCode> { __data["currencyCode"] }

      public struct Fragments: FragmentContainer {
        @_spi(Unsafe) public let __data: DataDict
        @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

        public var moneyFragment: MoneyFragment { _toFragment() }
      }
    }

    /// ProductVariant
    ///
    /// Parent Type: `ProductVariant`
    nonisolated public struct ProductVariant: OctopusGraphQL.SelectionSet {
      @_spi(Unsafe) public let __data: DataDict
      @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

      @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { OctopusGraphQL.Objects.ProductVariant }
      @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
        .field("__typename", String.self),
        .fragment(ProductVariantFragment.self),
      ] }
      @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
        ClaimFragment.ProductVariant.self,
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

    /// Conversation
    ///
    /// Parent Type: `Conversation`
    nonisolated public struct Conversation: OctopusGraphQL.SelectionSet {
      @_spi(Unsafe) public let __data: DataDict
      @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

      @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { OctopusGraphQL.Objects.Conversation }
      @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
        .field("__typename", String.self),
        .fragment(ConversationFragment.self),
      ] }
      @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
        ClaimFragment.Conversation.self,
        ConversationFragment.self
      ] }

      public var createdAt: OctopusGraphQL.DateTime { __data["createdAt"] }
      public var id: OctopusGraphQL.UUID { __data["id"] }
      public var isOpen: Bool { __data["isOpen"] }
      public var unreadMessageCount: Int { __data["unreadMessageCount"] }
      public var newestMessage: NewestMessage? { __data["newestMessage"] }
      public var statusMessage: String? { __data["statusMessage"] }
      public var isLegacy: Bool { __data["isLegacy"] }
      /// Return the claim for this conversation, if it has one.
      ///
      /// Conversations auto-created when a claim is opened will have this, others will not.
      /// The `legacyConversation` will not have any associated claim.
      public var claim: Claim? { __data["claim"] }

      public struct Fragments: FragmentContainer {
        @_spi(Unsafe) public let __data: DataDict
        @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

        public var conversationFragment: ConversationFragment { _toFragment() }
      }

      public typealias NewestMessage = ConversationFragment.NewestMessage

      public typealias Claim = ConversationFragment.Claim
    }

    /// DisplayItem
    ///
    /// Parent Type: `ClaimDisplayItem`
    nonisolated public struct DisplayItem: OctopusGraphQL.SelectionSet {
      @_spi(Unsafe) public let __data: DataDict
      @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

      @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { OctopusGraphQL.Objects.ClaimDisplayItem }
      @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
        .field("__typename", String.self),
        .field("displayTitle", String.self),
        .field("displayValue", String.self),
      ] }
      @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
        ClaimFragment.DisplayItem.self
      ] }

      public var displayTitle: String { __data["displayTitle"] }
      public var displayValue: String { __data["displayValue"] }
    }
  }

}