// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI
@_spi(Execution) @_spi(Unsafe) import ApolloAPI

public extension OctopusGraphQL {
  nonisolated struct DiscountsQuery: GraphQLQuery {
    public static let operationName: String = "Discounts"
    public static let operationDocument: ApolloAPI.OperationDocument = .init(
      definition: .init(
        #"query Discounts { currentMember { __typename activeContracts { __typename id exposureDisplayNameShort discountsDetails { __typename ...ContractDiscountDetailsFragment } currentAgreement { __typename productVariant { __typename displayNameShort } } } pendingContracts { __typename id exposureDisplayNameShort discountsDetails { __typename ...ContractDiscountDetailsFragment } productVariant { __typename displayNameShort } } referralInformation { __typename code monthlyDiscountPerReferral { __typename ...MoneyFragment } referrals { __typename ...MemberReferralFragment2 } referredBy { __typename ...MemberReferralFragment2 } } } }"#,
        fragments: [ContractDiscountDetailsFragment.self, ContractDiscountDetailsItemFragment.self, MemberReferralFragment2.self, MoneyFragment.self]
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
        DiscountsQuery.Data.self
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
          .field("activeContracts", [ActiveContract].self),
          .field("pendingContracts", [PendingContract].self),
          .field("referralInformation", ReferralInformation.self),
        ] }
        @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
          DiscountsQuery.Data.CurrentMember.self
        ] }

        /// Fetch all the active contracts for this member. Active contracts include all insurances that are either
        /// active today, or to-be-active in the future.
        public var activeContracts: [ActiveContract] { __data["activeContracts"] }
        /// Fetch all the pending contracts for this member.
        public var pendingContracts: [PendingContract] { __data["pendingContracts"] }
        /// Member-specific data related to Referrals (Hedvig Forever)
        public var referralInformation: ReferralInformation { __data["referralInformation"] }

        /// CurrentMember.ActiveContract
        ///
        /// Parent Type: `Contract`
        nonisolated public struct ActiveContract: OctopusGraphQL.SelectionSet {
          @_spi(Unsafe) public let __data: DataDict
          @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

          @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { OctopusGraphQL.Objects.Contract }
          @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
            .field("__typename", String.self),
            .field("id", OctopusGraphQL.UUID.self),
            .field("exposureDisplayNameShort", String.self),
            .field("discountsDetails", DiscountsDetails.self),
            .field("currentAgreement", CurrentAgreement.self),
          ] }
          @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
            DiscountsQuery.Data.CurrentMember.ActiveContract.self
          ] }

          public var id: OctopusGraphQL.UUID { __data["id"] }
          /// The display name of the "exposure" of this insurance - i.e. the 'object' being insured. This could be
          /// the address of an apartment
          /// or the person having accident insurance,
          /// or the dog being insured
          /// or car registration number etc
          public var exposureDisplayNameShort: String { __data["exposureDisplayNameShort"] }
          public var discountsDetails: DiscountsDetails { __data["discountsDetails"] }
          /// The currently active/relevant agreement for this contract.
          public var currentAgreement: CurrentAgreement { __data["currentAgreement"] }

          /// CurrentMember.ActiveContract.DiscountsDetails
          ///
          /// Parent Type: `ContractDiscountDetails`
          nonisolated public struct DiscountsDetails: OctopusGraphQL.SelectionSet {
            @_spi(Unsafe) public let __data: DataDict
            @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

            @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { OctopusGraphQL.Objects.ContractDiscountDetails }
            @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
              .field("__typename", String.self),
              .fragment(ContractDiscountDetailsFragment.self),
            ] }
            @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
              DiscountsQuery.Data.CurrentMember.ActiveContract.DiscountsDetails.self,
              ContractDiscountDetailsFragment.self
            ] }

            ///  A text to show if an extra explanation is needed, e.g. Your bundle discount will activate when you have two active insurances.
            public var discountsInfo: String? { __data["discountsInfo"] }
            ///  Contract level discounts.
            public var discounts: [Discount] { __data["discounts"] }

            public struct Fragments: FragmentContainer {
              @_spi(Unsafe) public let __data: DataDict
              @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

              public var contractDiscountDetailsFragment: ContractDiscountDetailsFragment { _toFragment() }
            }

            public typealias Discount = ContractDiscountDetailsFragment.Discount
          }

          /// CurrentMember.ActiveContract.CurrentAgreement
          ///
          /// Parent Type: `Agreement`
          nonisolated public struct CurrentAgreement: OctopusGraphQL.SelectionSet {
            @_spi(Unsafe) public let __data: DataDict
            @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

            @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { OctopusGraphQL.Objects.Agreement }
            @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
              .field("__typename", String.self),
              .field("productVariant", ProductVariant.self),
            ] }
            @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
              DiscountsQuery.Data.CurrentMember.ActiveContract.CurrentAgreement.self
            ] }

            /// The ProductVariant of the agreement, which is the umbrella container for a lot of data related to the insurance,
            /// such as names, legal documents, perils etc.
            public var productVariant: ProductVariant { __data["productVariant"] }

            /// CurrentMember.ActiveContract.CurrentAgreement.ProductVariant
            ///
            /// Parent Type: `ProductVariant`
            nonisolated public struct ProductVariant: OctopusGraphQL.SelectionSet {
              @_spi(Unsafe) public let __data: DataDict
              @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

              @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { OctopusGraphQL.Objects.ProductVariant }
              @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
                .field("__typename", String.self),
                .field("displayNameShort", String?.self),
              ] }
              @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
                DiscountsQuery.Data.CurrentMember.ActiveContract.CurrentAgreement.ProductVariant.self
              ] }

              public var displayNameShort: String? { __data["displayNameShort"] }
            }
          }
        }

        /// CurrentMember.PendingContract
        ///
        /// Parent Type: `PendingContract`
        nonisolated public struct PendingContract: OctopusGraphQL.SelectionSet {
          @_spi(Unsafe) public let __data: DataDict
          @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

          @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { OctopusGraphQL.Objects.PendingContract }
          @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
            .field("__typename", String.self),
            .field("id", OctopusGraphQL.UUID.self),
            .field("exposureDisplayNameShort", String.self),
            .field("discountsDetails", DiscountsDetails.self),
            .field("productVariant", ProductVariant.self),
          ] }
          @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
            DiscountsQuery.Data.CurrentMember.PendingContract.self
          ] }

          public var id: OctopusGraphQL.UUID { __data["id"] }
          /// Same as `Contract.exposureDisplayNameShort`.
          public var exposureDisplayNameShort: String { __data["exposureDisplayNameShort"] }
          public var discountsDetails: DiscountsDetails { __data["discountsDetails"] }
          /// Same as `Contract.currentAgreement.productVariant`.
          public var productVariant: ProductVariant { __data["productVariant"] }

          /// CurrentMember.PendingContract.DiscountsDetails
          ///
          /// Parent Type: `ContractDiscountDetails`
          nonisolated public struct DiscountsDetails: OctopusGraphQL.SelectionSet {
            @_spi(Unsafe) public let __data: DataDict
            @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

            @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { OctopusGraphQL.Objects.ContractDiscountDetails }
            @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
              .field("__typename", String.self),
              .fragment(ContractDiscountDetailsFragment.self),
            ] }
            @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
              DiscountsQuery.Data.CurrentMember.PendingContract.DiscountsDetails.self,
              ContractDiscountDetailsFragment.self
            ] }

            ///  A text to show if an extra explanation is needed, e.g. Your bundle discount will activate when you have two active insurances.
            public var discountsInfo: String? { __data["discountsInfo"] }
            ///  Contract level discounts.
            public var discounts: [Discount] { __data["discounts"] }

            public struct Fragments: FragmentContainer {
              @_spi(Unsafe) public let __data: DataDict
              @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

              public var contractDiscountDetailsFragment: ContractDiscountDetailsFragment { _toFragment() }
            }

            public typealias Discount = ContractDiscountDetailsFragment.Discount
          }

          /// CurrentMember.PendingContract.ProductVariant
          ///
          /// Parent Type: `ProductVariant`
          nonisolated public struct ProductVariant: OctopusGraphQL.SelectionSet {
            @_spi(Unsafe) public let __data: DataDict
            @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

            @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { OctopusGraphQL.Objects.ProductVariant }
            @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
              .field("__typename", String.self),
              .field("displayNameShort", String?.self),
            ] }
            @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
              DiscountsQuery.Data.CurrentMember.PendingContract.ProductVariant.self
            ] }

            public var displayNameShort: String? { __data["displayNameShort"] }
          }
        }

        /// CurrentMember.ReferralInformation
        ///
        /// Parent Type: `MemberReferralInformation`
        nonisolated public struct ReferralInformation: OctopusGraphQL.SelectionSet {
          @_spi(Unsafe) public let __data: DataDict
          @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

          @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { OctopusGraphQL.Objects.MemberReferralInformation }
          @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
            .field("__typename", String.self),
            .field("code", String.self),
            .field("monthlyDiscountPerReferral", MonthlyDiscountPerReferral.self),
            .field("referrals", [Referral].self),
            .field("referredBy", ReferredBy?.self),
          ] }
          @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
            DiscountsQuery.Data.CurrentMember.ReferralInformation.self
          ] }

          /// The unique invite-code this member that can be sent to other people.
          ///
          /// Can be updated with `Mutation.memberReferralInformationCodeUpdate`
          public var code: String { __data["code"] }
          /// How much a single successful referral is worth.
          public var monthlyDiscountPerReferral: MonthlyDiscountPerReferral { __data["monthlyDiscountPerReferral"] }
          /// All the referrals this connected to this member and their current status.
          public var referrals: [Referral] { __data["referrals"] }
          /// The referral that ended up with this member signing. This is also overlapped with an entry in redeemedCampaign.
          public var referredBy: ReferredBy? { __data["referredBy"] }

          /// CurrentMember.ReferralInformation.MonthlyDiscountPerReferral
          ///
          /// Parent Type: `Money`
          nonisolated public struct MonthlyDiscountPerReferral: OctopusGraphQL.SelectionSet {
            @_spi(Unsafe) public let __data: DataDict
            @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

            @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { OctopusGraphQL.Objects.Money }
            @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
              .field("__typename", String.self),
              .fragment(MoneyFragment.self),
            ] }
            @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
              DiscountsQuery.Data.CurrentMember.ReferralInformation.MonthlyDiscountPerReferral.self,
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

          /// CurrentMember.ReferralInformation.Referral
          ///
          /// Parent Type: `MemberReferral`
          nonisolated public struct Referral: OctopusGraphQL.SelectionSet {
            @_spi(Unsafe) public let __data: DataDict
            @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

            @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { OctopusGraphQL.Objects.MemberReferral }
            @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
              .field("__typename", String.self),
              .fragment(MemberReferralFragment2.self),
            ] }
            @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
              DiscountsQuery.Data.CurrentMember.ReferralInformation.Referral.self,
              MemberReferralFragment2.self
            ] }

            /// The name of this referral. This reflects the name of the member created through the referral.
            public var name: String { __data["name"] }
            /// The code used for referring.
            public var code: String? { __data["code"] }
            /// Status of the referral - only ACTIVE referrals generate a discount.
            public var status: GraphQLEnum<OctopusGraphQL.MemberReferralStatus> { __data["status"] }
            /// The currently active discount of this referral.
            public var activeDiscount: ActiveDiscount? { __data["activeDiscount"] }

            public struct Fragments: FragmentContainer {
              @_spi(Unsafe) public let __data: DataDict
              @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

              public var memberReferralFragment2: MemberReferralFragment2 { _toFragment() }
            }

            public typealias ActiveDiscount = MemberReferralFragment2.ActiveDiscount
          }

          /// CurrentMember.ReferralInformation.ReferredBy
          ///
          /// Parent Type: `MemberReferral`
          nonisolated public struct ReferredBy: OctopusGraphQL.SelectionSet {
            @_spi(Unsafe) public let __data: DataDict
            @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

            @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { OctopusGraphQL.Objects.MemberReferral }
            @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
              .field("__typename", String.self),
              .fragment(MemberReferralFragment2.self),
            ] }
            @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
              DiscountsQuery.Data.CurrentMember.ReferralInformation.ReferredBy.self,
              MemberReferralFragment2.self
            ] }

            /// The name of this referral. This reflects the name of the member created through the referral.
            public var name: String { __data["name"] }
            /// The code used for referring.
            public var code: String? { __data["code"] }
            /// Status of the referral - only ACTIVE referrals generate a discount.
            public var status: GraphQLEnum<OctopusGraphQL.MemberReferralStatus> { __data["status"] }
            /// The currently active discount of this referral.
            public var activeDiscount: ActiveDiscount? { __data["activeDiscount"] }

            public struct Fragments: FragmentContainer {
              @_spi(Unsafe) public let __data: DataDict
              @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

              public var memberReferralFragment2: MemberReferralFragment2 { _toFragment() }
            }

            public typealias ActiveDiscount = MemberReferralFragment2.ActiveDiscount
          }
        }
      }
    }
  }

}