// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI
@_spi(Execution) @_spi(Unsafe) import ApolloAPI

public extension OctopusGraphQL {
  nonisolated struct MemberReferralInformationQuery: GraphQLQuery {
    public static let operationName: String = "MemberReferralInformation"
    public static let operationDocument: ApolloAPI.OperationDocument = .init(
      definition: .init(
        #"query MemberReferralInformation { currentMember { __typename insuranceCost { __typename monthlyDiscount { __typename ...MoneyFragment } monthlyGross { __typename ...MoneyFragment } monthlyNet { __typename ...MoneyFragment } } referralInformation { __typename code monthlyDiscountPerReferral { __typename ...MoneyFragment } referrals { __typename ...MemberReferralFragment } referredBy { __typename activeDiscount { __typename ...MoneyFragment } } monthlyDiscountPerReferral { __typename ...MoneyFragment } referrals { __typename ...MemberReferralFragment } referredBy { __typename ...MemberReferralFragment } } } }"#,
        fragments: [MemberReferralFragment.self, MoneyFragment.self]
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
        MemberReferralInformationQuery.Data.self
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
          .field("insuranceCost", InsuranceCost.self),
          .field("referralInformation", ReferralInformation.self),
        ] }
        @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
          MemberReferralInformationQuery.Data.CurrentMember.self
        ] }

        /// A breakdown of the total cost of this member's insurance.
        ///
        /// The exact charge every month can vary based on other factors,
        public var insuranceCost: InsuranceCost { __data["insuranceCost"] }
        /// Member-specific data related to Referrals (Hedvig Forever)
        public var referralInformation: ReferralInformation { __data["referralInformation"] }

        /// CurrentMember.InsuranceCost
        ///
        /// Parent Type: `MemberInsuranceCost`
        nonisolated public struct InsuranceCost: OctopusGraphQL.SelectionSet {
          @_spi(Unsafe) public let __data: DataDict
          @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

          @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { OctopusGraphQL.Objects.MemberInsuranceCost }
          @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
            .field("__typename", String.self),
            .field("monthlyDiscount", MonthlyDiscount.self),
            .field("monthlyGross", MonthlyGross.self),
            .field("monthlyNet", MonthlyNet.self),
          ] }
          @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
            MemberReferralInformationQuery.Data.CurrentMember.InsuranceCost.self
          ] }

          /// The total discount when everything is applied.
          public var monthlyDiscount: MonthlyDiscount { __data["monthlyDiscount"] }
          /// Total cost of the insurances before any discounts.
          public var monthlyGross: MonthlyGross { __data["monthlyGross"] }
          /// The total to actually be charged every month.
          public var monthlyNet: MonthlyNet { __data["monthlyNet"] }

          /// CurrentMember.InsuranceCost.MonthlyDiscount
          ///
          /// Parent Type: `Money`
          nonisolated public struct MonthlyDiscount: OctopusGraphQL.SelectionSet {
            @_spi(Unsafe) public let __data: DataDict
            @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

            @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { OctopusGraphQL.Objects.Money }
            @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
              .field("__typename", String.self),
              .fragment(MoneyFragment.self),
            ] }
            @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
              MemberReferralInformationQuery.Data.CurrentMember.InsuranceCost.MonthlyDiscount.self,
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

          /// CurrentMember.InsuranceCost.MonthlyGross
          ///
          /// Parent Type: `Money`
          nonisolated public struct MonthlyGross: OctopusGraphQL.SelectionSet {
            @_spi(Unsafe) public let __data: DataDict
            @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

            @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { OctopusGraphQL.Objects.Money }
            @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
              .field("__typename", String.self),
              .fragment(MoneyFragment.self),
            ] }
            @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
              MemberReferralInformationQuery.Data.CurrentMember.InsuranceCost.MonthlyGross.self,
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

          /// CurrentMember.InsuranceCost.MonthlyNet
          ///
          /// Parent Type: `Money`
          nonisolated public struct MonthlyNet: OctopusGraphQL.SelectionSet {
            @_spi(Unsafe) public let __data: DataDict
            @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

            @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { OctopusGraphQL.Objects.Money }
            @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
              .field("__typename", String.self),
              .fragment(MoneyFragment.self),
            ] }
            @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
              MemberReferralInformationQuery.Data.CurrentMember.InsuranceCost.MonthlyNet.self,
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
            MemberReferralInformationQuery.Data.CurrentMember.ReferralInformation.self
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
              MemberReferralInformationQuery.Data.CurrentMember.ReferralInformation.MonthlyDiscountPerReferral.self,
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
              .fragment(MemberReferralFragment.self),
            ] }
            @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
              MemberReferralInformationQuery.Data.CurrentMember.ReferralInformation.Referral.self,
              MemberReferralFragment.self
            ] }

            /// The currently active discount of this referral.
            public var activeDiscount: ActiveDiscount? { __data["activeDiscount"] }
            /// The name of this referral. This reflects the name of the member created through the referral.
            public var name: String { __data["name"] }
            /// Status of the referral - only ACTIVE referrals generate a discount.
            public var status: GraphQLEnum<OctopusGraphQL.MemberReferralStatus> { __data["status"] }

            public struct Fragments: FragmentContainer {
              @_spi(Unsafe) public let __data: DataDict
              @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

              public var memberReferralFragment: MemberReferralFragment { _toFragment() }
            }

            public typealias ActiveDiscount = MemberReferralFragment.ActiveDiscount
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
              .field("activeDiscount", ActiveDiscount?.self),
              .fragment(MemberReferralFragment.self),
            ] }
            @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
              MemberReferralInformationQuery.Data.CurrentMember.ReferralInformation.ReferredBy.self,
              MemberReferralFragment.self
            ] }

            /// The currently active discount of this referral.
            public var activeDiscount: ActiveDiscount? { __data["activeDiscount"] }
            /// The name of this referral. This reflects the name of the member created through the referral.
            public var name: String { __data["name"] }
            /// Status of the referral - only ACTIVE referrals generate a discount.
            public var status: GraphQLEnum<OctopusGraphQL.MemberReferralStatus> { __data["status"] }

            public struct Fragments: FragmentContainer {
              @_spi(Unsafe) public let __data: DataDict
              @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

              public var memberReferralFragment: MemberReferralFragment { _toFragment() }
            }

            /// CurrentMember.ReferralInformation.ReferredBy.ActiveDiscount
            ///
            /// Parent Type: `Money`
            nonisolated public struct ActiveDiscount: OctopusGraphQL.SelectionSet {
              @_spi(Unsafe) public let __data: DataDict
              @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

              @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { OctopusGraphQL.Objects.Money }
              @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
                .field("__typename", String.self),
                .fragment(MoneyFragment.self),
              ] }
              @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
                MemberReferralInformationQuery.Data.CurrentMember.ReferralInformation.ReferredBy.ActiveDiscount.self,
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
          }
        }
      }
    }
  }

}