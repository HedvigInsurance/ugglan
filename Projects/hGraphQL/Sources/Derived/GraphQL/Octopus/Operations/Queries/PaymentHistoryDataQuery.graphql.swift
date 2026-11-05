// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI
@_spi(Execution) @_spi(Unsafe) import ApolloAPI

public extension OctopusGraphQL {
  nonisolated struct PaymentHistoryDataQuery: GraphQLQuery {
    public static let operationName: String = "PaymentHistoryData"
    public static let operationDocument: ApolloAPI.OperationDocument = .init(
      definition: .init(
        #"query PaymentHistoryData { currentMember { __typename pastCharges { __typename ...MemberChargeFragment } referralInformation { __typename ...MemberReferralInformationCodeFragment } } }"#,
        fragments: [MemberChargeFragment.self, MemberReferralInformationCodeFragment.self, MoneyFragment.self]
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
        PaymentHistoryDataQuery.Data.self
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
          .field("pastCharges", [PastCharge].self),
          .field("referralInformation", ReferralInformation.self),
        ] }
        @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
          PaymentHistoryDataQuery.Data.CurrentMember.self
        ] }

        /// List of all past charges, this list will be empty in case of pending members
        public var pastCharges: [PastCharge] { __data["pastCharges"] }
        /// Member-specific data related to Referrals (Hedvig Forever)
        public var referralInformation: ReferralInformation { __data["referralInformation"] }

        /// CurrentMember.PastCharge
        ///
        /// Parent Type: `MemberCharge`
        nonisolated public struct PastCharge: OctopusGraphQL.SelectionSet {
          @_spi(Unsafe) public let __data: DataDict
          @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

          @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { OctopusGraphQL.Objects.MemberCharge }
          @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
            .field("__typename", String.self),
            .fragment(MemberChargeFragment.self),
          ] }
          @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
            PaymentHistoryDataQuery.Data.CurrentMember.PastCharge.self,
            MemberChargeFragment.self
          ] }

          /// Breakdown of the upcoming charge by items
          public var chargeBreakdown: [ChargeBreakdown] { __data["chargeBreakdown"] }
          /// Due date of the upcoming charge
          public var date: OctopusGraphQL.Date { __data["date"] }
          /// Total discount amount of the upcoming charge, includes all active discounts
          public var discount: Discount { __data["discount"] }
          /// Referral discount amount of the charge
          public var referralDiscount: ReferralDiscount? { __data["referralDiscount"] }
          /// Total gross amount of the upcoming charge based on all contracts premium divided by the number of days in the month
          public var gross: Gross { __data["gross"] }
          public var id: OctopusGraphQL.ID? { __data["id"] }
          /// Total net amount of the upcoming charge, (gross - discount)
          public var net: Net { __data["net"] }
          public var status: GraphQLEnum<OctopusGraphQL.MemberChargeStatus> { __data["status"] }
          ///  usedCredit is the amount that the member has used towards their paid subscription. 
          public var carriedAdjustment: CarriedAdjustment? { __data["carriedAdjustment"] }
          ///  gainedCredit is the amount that the member is owed due to settlement adjustment. 
          public var settlementAdjustment: SettlementAdjustment? { __data["settlementAdjustment"] }
          /// URL to the invoice of a past charge, null if no invoice generated
          public var paymentInvoiceUrl: String? { __data["paymentInvoiceUrl"] }
          /// The provider that was or will be used to charge the member, null if unknown
          public var paymentProvider: String? { __data["paymentProvider"] }

          public struct Fragments: FragmentContainer {
            @_spi(Unsafe) public let __data: DataDict
            @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

            public var memberChargeFragment: MemberChargeFragment { _toFragment() }
          }

          public typealias ChargeBreakdown = MemberChargeFragment.ChargeBreakdown

          public typealias Discount = MemberChargeFragment.Discount

          public typealias ReferralDiscount = MemberChargeFragment.ReferralDiscount

          public typealias Gross = MemberChargeFragment.Gross

          public typealias Net = MemberChargeFragment.Net

          public typealias CarriedAdjustment = MemberChargeFragment.CarriedAdjustment

          public typealias SettlementAdjustment = MemberChargeFragment.SettlementAdjustment
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
            .fragment(MemberReferralInformationCodeFragment.self),
          ] }
          @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
            PaymentHistoryDataQuery.Data.CurrentMember.ReferralInformation.self,
            MemberReferralInformationCodeFragment.self
          ] }

          /// The unique invite-code this member that can be sent to other people.
          ///
          /// Can be updated with `Mutation.memberReferralInformationCodeUpdate`
          public var code: String { __data["code"] }
          /// How much a single successful referral is worth.
          public var monthlyDiscountPerReferral: MonthlyDiscountPerReferral { __data["monthlyDiscountPerReferral"] }

          public struct Fragments: FragmentContainer {
            @_spi(Unsafe) public let __data: DataDict
            @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

            public var memberReferralInformationCodeFragment: MemberReferralInformationCodeFragment { _toFragment() }
          }

          public typealias MonthlyDiscountPerReferral = MemberReferralInformationCodeFragment.MonthlyDiscountPerReferral
        }
      }
    }
  }

}