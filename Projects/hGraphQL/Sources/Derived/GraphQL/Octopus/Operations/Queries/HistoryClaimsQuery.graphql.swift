// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI
@_spi(Execution) @_spi(Unsafe) import ApolloAPI

public extension OctopusGraphQL {
  nonisolated struct HistoryClaimsQuery: GraphQLQuery {
    public static let operationName: String = "HistoryClaims"
    public static let operationDocument: ApolloAPI.OperationDocument = .init(
      definition: .init(
        #"query HistoryClaims { currentMember { __typename claimsHistory { __typename ...ClaimFragment } partnerClaimsHistory { __typename ...PartnerClaimFragment } } }"#,
        fragments: [ChatMessageDisclaimerFragment.self, ChatMessageFileFragment.self, ChatMessageTextFragment.self, ClaimFragment.self, ConversationFragment.self, InsuranceDocumentFragment.self, MessageFragment.self, MoneyFragment.self, PartnerClaimFragment.self, PerilFragment.self, ProductVariantFragment.self]
      ))

    public init() {}

    nonisolated public struct Data: OctopusGraphQL.SelectionSet {
      @_spi(Unsafe) public let __data: DataDict
      @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

      @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { OctopusGraphQL.Objects.Query }
      @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
        .field("currentMember", CurrentMember.self),
      ] }
      @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
        HistoryClaimsQuery.Data.self
      ] }

      /// Gets the currently authenticated member. This is the only valid way to query a `Member` type, and it is based
      /// on the input Authorization header.
      public var currentMember: CurrentMember { __data["currentMember"] }

      /// CurrentMember
      ///
      /// Parent Type: `Member`
      nonisolated public struct CurrentMember: OctopusGraphQL.SelectionSet {
        @_spi(Unsafe) public let __data: DataDict
        @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

        @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { OctopusGraphQL.Objects.Member }
        @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
          .field("__typename", String.self),
          .field("claimsHistory", [ClaimsHistory].self),
          .field("partnerClaimsHistory", [PartnerClaimsHistory].self),
        ] }
        @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
          HistoryClaimsQuery.Data.CurrentMember.self
        ] }

        public var claimsHistory: [ClaimsHistory] { __data["claimsHistory"] }
        public var partnerClaimsHistory: [PartnerClaimsHistory] { __data["partnerClaimsHistory"] }

        /// CurrentMember.ClaimsHistory
        ///
        /// Parent Type: `Claim`
        nonisolated public struct ClaimsHistory: OctopusGraphQL.SelectionSet {
          @_spi(Unsafe) public let __data: DataDict
          @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

          @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { OctopusGraphQL.Objects.Claim }
          @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
            .field("__typename", String.self),
            .fragment(ClaimFragment.self),
          ] }
          @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
            HistoryClaimsQuery.Data.CurrentMember.ClaimsHistory.self,
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

          public struct Fragments: FragmentContainer {
            @_spi(Unsafe) public let __data: DataDict
            @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

            public var claimFragment: ClaimFragment { _toFragment() }
          }

          public typealias PayoutAmount = ClaimFragment.PayoutAmount

          public typealias ProductVariant = ClaimFragment.ProductVariant

          public typealias Conversation = ClaimFragment.Conversation

          public typealias DisplayItem = ClaimFragment.DisplayItem
        }

        /// CurrentMember.PartnerClaimsHistory
        ///
        /// Parent Type: `PartnerClaim`
        nonisolated public struct PartnerClaimsHistory: OctopusGraphQL.SelectionSet {
          @_spi(Unsafe) public let __data: DataDict
          @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

          @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { OctopusGraphQL.Objects.PartnerClaim }
          @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
            .field("__typename", String.self),
            .fragment(PartnerClaimFragment.self),
          ] }
          @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
            HistoryClaimsQuery.Data.CurrentMember.PartnerClaimsHistory.self,
            PartnerClaimFragment.self
          ] }

          public var id: OctopusGraphQL.ID { __data["id"] }
          public var externalId: String { __data["externalId"] }
          public var exposureDisplayName: String? { __data["exposureDisplayName"] }
          public var status: GraphQLEnum<OctopusGraphQL.ClaimStatus>? { __data["status"] }
          public var submittedAt: OctopusGraphQL.Date? { __data["submittedAt"] }
          public var payoutAmount: PayoutAmount? { __data["payoutAmount"] }
          public var associatedTypeOfContract: String? { __data["associatedTypeOfContract"] }
          public var claimType: String? { __data["claimType"] }
          public var handlerEmail: String? { __data["handlerEmail"] }
          public var displayItems: [DisplayItem] { __data["displayItems"] }
          /// Terms & conditions for the claim found using claims contractId and dateOfOccurrence, otherwise null.
          public var productVariant: ProductVariant? { __data["productVariant"] }

          public struct Fragments: FragmentContainer {
            @_spi(Unsafe) public let __data: DataDict
            @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

            public var partnerClaimFragment: PartnerClaimFragment { _toFragment() }
          }

          public typealias PayoutAmount = PartnerClaimFragment.PayoutAmount

          public typealias DisplayItem = PartnerClaimFragment.DisplayItem

          public typealias ProductVariant = PartnerClaimFragment.ProductVariant
        }
      }
    }
  }

}