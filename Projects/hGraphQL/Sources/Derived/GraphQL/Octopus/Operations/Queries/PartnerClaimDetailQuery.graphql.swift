// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI
@_spi(Execution) @_spi(Unsafe) import ApolloAPI

public extension OctopusGraphQL {
  nonisolated struct PartnerClaimDetailQuery: GraphQLQuery {
    public static let operationName: String = "PartnerClaimDetail"
    public static let operationDocument: ApolloAPI.OperationDocument = .init(
      definition: .init(
        #"query PartnerClaimDetail($claimId: ID!) { partnerClaim(id: $claimId) { __typename ...PartnerClaimFragment } }"#,
        fragments: [InsuranceDocumentFragment.self, MoneyFragment.self, PartnerClaimFragment.self, PerilFragment.self, ProductVariantFragment.self]
      ))

    public var claimId: ID

    public init(claimId: ID) {
      self.claimId = claimId
    }

    @_spi(Unsafe) public var __variables: Variables? { ["claimId": claimId] }

    nonisolated public struct Data: OctopusGraphQL.SelectionSet {
      @_spi(Unsafe) public let __data: DataDict
      @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

      @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { OctopusGraphQL.Objects.Query }
      @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
        .field("partnerClaim", PartnerClaim?.self, arguments: ["id": .variable("claimId")]),
      ] }
      @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
        PartnerClaimDetailQuery.Data.self
      ] }

      public var partnerClaim: PartnerClaim? { __data["partnerClaim"] }

      /// PartnerClaim
      ///
      /// Parent Type: `PartnerClaim`
      nonisolated public struct PartnerClaim: OctopusGraphQL.SelectionSet {
        @_spi(Unsafe) public let __data: DataDict
        @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

        @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { OctopusGraphQL.Objects.PartnerClaim }
        @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
          .field("__typename", String.self),
          .fragment(PartnerClaimFragment.self),
        ] }
        @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
          PartnerClaimDetailQuery.Data.PartnerClaim.self,
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