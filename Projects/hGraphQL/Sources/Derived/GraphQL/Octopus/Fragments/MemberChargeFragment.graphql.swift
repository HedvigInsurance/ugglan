// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI
@_spi(Execution) @_spi(Unsafe) import ApolloAPI

public extension OctopusGraphQL {
  nonisolated struct MemberChargeFragment: OctopusGraphQL.SelectionSet, Fragment {
    public static var fragmentDefinition: StaticString {
      #"fragment MemberChargeFragment on MemberCharge { __typename chargeBreakdown { __typename displayTitle displaySubtitle gross { __typename ...MoneyFragment } net { __typename ...MoneyFragment } insurancePriceBreakdown { __typename amount { __typename ...MoneyFragment } displayTitle } periods { __typename fromDate toDate amount { __typename ...MoneyFragment } isPreviouslyFailedCharge } } date discount { __typename ...MoneyFragment } referralDiscount { __typename ...MoneyFragment } gross { __typename ...MoneyFragment } id net { __typename ...MoneyFragment } status carriedAdjustment { __typename ...MoneyFragment } settlementAdjustment { __typename ...MoneyFragment } paymentInvoiceUrl paymentProvider }"#
    }

    @_spi(Unsafe) public let __data: DataDict
    @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

    @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { OctopusGraphQL.Objects.MemberCharge }
    @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
      .field("__typename", String.self),
      .field("chargeBreakdown", [ChargeBreakdown].self),
      .field("date", OctopusGraphQL.Date.self),
      .field("discount", Discount.self),
      .field("referralDiscount", ReferralDiscount?.self),
      .field("gross", Gross.self),
      .field("id", OctopusGraphQL.ID?.self),
      .field("net", Net.self),
      .field("status", GraphQLEnum<OctopusGraphQL.MemberChargeStatus>.self),
      .field("carriedAdjustment", CarriedAdjustment?.self),
      .field("settlementAdjustment", SettlementAdjustment?.self),
      .field("paymentInvoiceUrl", String?.self),
      .field("paymentProvider", String?.self),
    ] }
    @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
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

    /// ChargeBreakdown
    ///
    /// Parent Type: `MemberChargeBreakdownItem`
    nonisolated public struct ChargeBreakdown: OctopusGraphQL.SelectionSet {
      @_spi(Unsafe) public let __data: DataDict
      @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

      @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { OctopusGraphQL.Objects.MemberChargeBreakdownItem }
      @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
        .field("__typename", String.self),
        .field("displayTitle", String.self),
        .field("displaySubtitle", String?.self),
        .field("gross", Gross.self),
        .field("net", Net.self),
        .field("insurancePriceBreakdown", [InsurancePriceBreakdown].self),
        .field("periods", [Period].self),
      ] }
      @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
        MemberChargeFragment.ChargeBreakdown.self
      ] }

      public var displayTitle: String { __data["displayTitle"] }
      public var displaySubtitle: String? { __data["displaySubtitle"] }
      public var gross: Gross { __data["gross"] }
      public var net: Net { __data["net"] }
      public var insurancePriceBreakdown: [InsurancePriceBreakdown] { __data["insurancePriceBreakdown"] }
      public var periods: [Period] { __data["periods"] }

      /// ChargeBreakdown.Gross
      ///
      /// Parent Type: `Money`
      nonisolated public struct Gross: OctopusGraphQL.SelectionSet {
        @_spi(Unsafe) public let __data: DataDict
        @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

        @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { OctopusGraphQL.Objects.Money }
        @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
          .field("__typename", String.self),
          .fragment(MoneyFragment.self),
        ] }
        @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
          MemberChargeFragment.ChargeBreakdown.Gross.self,
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

      /// ChargeBreakdown.Net
      ///
      /// Parent Type: `Money`
      nonisolated public struct Net: OctopusGraphQL.SelectionSet {
        @_spi(Unsafe) public let __data: DataDict
        @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

        @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { OctopusGraphQL.Objects.Money }
        @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
          .field("__typename", String.self),
          .fragment(MoneyFragment.self),
        ] }
        @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
          MemberChargeFragment.ChargeBreakdown.Net.self,
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

      /// ChargeBreakdown.InsurancePriceBreakdown
      ///
      /// Parent Type: `MemberChargePriceBreakdownItem`
      nonisolated public struct InsurancePriceBreakdown: OctopusGraphQL.SelectionSet {
        @_spi(Unsafe) public let __data: DataDict
        @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

        @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { OctopusGraphQL.Objects.MemberChargePriceBreakdownItem }
        @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
          .field("__typename", String.self),
          .field("amount", Amount.self),
          .field("displayTitle", String.self),
        ] }
        @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
          MemberChargeFragment.ChargeBreakdown.InsurancePriceBreakdown.self
        ] }

        public var amount: Amount { __data["amount"] }
        public var displayTitle: String { __data["displayTitle"] }

        /// ChargeBreakdown.InsurancePriceBreakdown.Amount
        ///
        /// Parent Type: `Money`
        nonisolated public struct Amount: OctopusGraphQL.SelectionSet {
          @_spi(Unsafe) public let __data: DataDict
          @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

          @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { OctopusGraphQL.Objects.Money }
          @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
            .field("__typename", String.self),
            .fragment(MoneyFragment.self),
          ] }
          @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
            MemberChargeFragment.ChargeBreakdown.InsurancePriceBreakdown.Amount.self,
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

      /// ChargeBreakdown.Period
      ///
      /// Parent Type: `MemberChargeBreakdownItemPeriod`
      nonisolated public struct Period: OctopusGraphQL.SelectionSet {
        @_spi(Unsafe) public let __data: DataDict
        @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

        @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { OctopusGraphQL.Objects.MemberChargeBreakdownItemPeriod }
        @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
          .field("__typename", String.self),
          .field("fromDate", OctopusGraphQL.Date.self),
          .field("toDate", OctopusGraphQL.Date.self),
          .field("amount", Amount.self),
          .field("isPreviouslyFailedCharge", Bool.self),
        ] }
        @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
          MemberChargeFragment.ChargeBreakdown.Period.self
        ] }

        public var fromDate: OctopusGraphQL.Date { __data["fromDate"] }
        public var toDate: OctopusGraphQL.Date { __data["toDate"] }
        public var amount: Amount { __data["amount"] }
        public var isPreviouslyFailedCharge: Bool { __data["isPreviouslyFailedCharge"] }

        /// ChargeBreakdown.Period.Amount
        ///
        /// Parent Type: `Money`
        nonisolated public struct Amount: OctopusGraphQL.SelectionSet {
          @_spi(Unsafe) public let __data: DataDict
          @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

          @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { OctopusGraphQL.Objects.Money }
          @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
            .field("__typename", String.self),
            .fragment(MoneyFragment.self),
          ] }
          @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
            MemberChargeFragment.ChargeBreakdown.Period.Amount.self,
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

    /// Discount
    ///
    /// Parent Type: `Money`
    nonisolated public struct Discount: OctopusGraphQL.SelectionSet {
      @_spi(Unsafe) public let __data: DataDict
      @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

      @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { OctopusGraphQL.Objects.Money }
      @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
        .field("__typename", String.self),
        .fragment(MoneyFragment.self),
      ] }
      @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
        MemberChargeFragment.Discount.self,
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

    /// ReferralDiscount
    ///
    /// Parent Type: `Money`
    nonisolated public struct ReferralDiscount: OctopusGraphQL.SelectionSet {
      @_spi(Unsafe) public let __data: DataDict
      @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

      @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { OctopusGraphQL.Objects.Money }
      @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
        .field("__typename", String.self),
        .fragment(MoneyFragment.self),
      ] }
      @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
        MemberChargeFragment.ReferralDiscount.self,
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

    /// Gross
    ///
    /// Parent Type: `Money`
    nonisolated public struct Gross: OctopusGraphQL.SelectionSet {
      @_spi(Unsafe) public let __data: DataDict
      @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

      @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { OctopusGraphQL.Objects.Money }
      @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
        .field("__typename", String.self),
        .fragment(MoneyFragment.self),
      ] }
      @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
        MemberChargeFragment.Gross.self,
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

    /// Net
    ///
    /// Parent Type: `Money`
    nonisolated public struct Net: OctopusGraphQL.SelectionSet {
      @_spi(Unsafe) public let __data: DataDict
      @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

      @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { OctopusGraphQL.Objects.Money }
      @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
        .field("__typename", String.self),
        .fragment(MoneyFragment.self),
      ] }
      @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
        MemberChargeFragment.Net.self,
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

    /// CarriedAdjustment
    ///
    /// Parent Type: `Money`
    nonisolated public struct CarriedAdjustment: OctopusGraphQL.SelectionSet {
      @_spi(Unsafe) public let __data: DataDict
      @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

      @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { OctopusGraphQL.Objects.Money }
      @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
        .field("__typename", String.self),
        .fragment(MoneyFragment.self),
      ] }
      @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
        MemberChargeFragment.CarriedAdjustment.self,
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

    /// SettlementAdjustment
    ///
    /// Parent Type: `Money`
    nonisolated public struct SettlementAdjustment: OctopusGraphQL.SelectionSet {
      @_spi(Unsafe) public let __data: DataDict
      @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

      @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { OctopusGraphQL.Objects.Money }
      @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
        .field("__typename", String.self),
        .fragment(MoneyFragment.self),
      ] }
      @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
        MemberChargeFragment.SettlementAdjustment.self,
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