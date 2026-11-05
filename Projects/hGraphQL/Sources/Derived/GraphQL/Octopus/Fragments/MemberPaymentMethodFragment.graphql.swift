// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI
@_spi(Execution) @_spi(Unsafe) import ApolloAPI

public extension OctopusGraphQL {
  nonisolated struct MemberPaymentMethodFragment: OctopusGraphQL.SelectionSet, Fragment {
    public static var fragmentDefinition: StaticString {
      #"fragment MemberPaymentMethodFragment on MemberPaymentMethod { __typename provider status isDefault details { __typename ... on PaymentMethodInvoiceDetails { delivery email } ... on PaymentMethodSwishDetails { phoneNumber } ... on PaymentMethodBankAccountDetails { account bank } } }"#
    }

    @_spi(Unsafe) public let __data: DataDict
    @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

    @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { OctopusGraphQL.Objects.MemberPaymentMethod }
    @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
      .field("__typename", String.self),
      .field("provider", GraphQLEnum<OctopusGraphQL.MemberPaymentProvider>.self),
      .field("status", GraphQLEnum<OctopusGraphQL.MemberPaymentMethodStatus>.self),
      .field("isDefault", Bool.self),
      .field("details", Details?.self),
    ] }
    @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
      MemberPaymentMethodFragment.self
    ] }

    /// Payment provider, eg Trustly, Swish, Nordea, Invoice etc.
    /// This is used as the "identifier" of the payment method since there can only be one ACTIVE or PENDING payment method
    /// per provider.
    public var provider: GraphQLEnum<OctopusGraphQL.MemberPaymentProvider> { __data["provider"] }
    /// The payment method status - ACTIVE, PENDING.
    /// If ACTIVE, the payment method is ready to use for payins or payouts depending on if it's a payin or payout method.
    /// If PENDING, the payment method has been set up but is still awaiting activation and cannot be used for payins or
    /// payouts until then. Once activated, the status will change to ACTIVE.
    public var status: GraphQLEnum<OctopusGraphQL.MemberPaymentMethodStatus> { __data["status"] }
    /// This is 'true' for only one of the members ACTIVE methods which is the default payment method that will be used for
    /// charging or payout the member. For PENDING methods, this can also be 'true' if the member has chosen to set up this
    /// payment method as default during the setup process.
    public var isDefault: Bool { __data["isDefault"] }
    /// Specific details of the actual connection if method is ACTIVE - e.g. a bank account reference, phone number for swish,
    /// or email/kivra for invoice. If method is PENDING, then this field will be null since the member has not yet set up
    /// this payment method.
    public var details: Details? { __data["details"] }

    /// Details
    ///
    /// Parent Type: `PaymentMethodDetails`
    nonisolated public struct Details: OctopusGraphQL.SelectionSet {
      @_spi(Unsafe) public let __data: DataDict
      @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

      @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { OctopusGraphQL.Unions.PaymentMethodDetails }
      @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
        .field("__typename", String.self),
        .inlineFragment(AsPaymentMethodInvoiceDetails.self),
        .inlineFragment(AsPaymentMethodSwishDetails.self),
        .inlineFragment(AsPaymentMethodBankAccountDetails.self),
      ] }
      @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
        MemberPaymentMethodFragment.Details.self
      ] }

      public var asPaymentMethodInvoiceDetails: AsPaymentMethodInvoiceDetails? { _asInlineFragment() }
      public var asPaymentMethodSwishDetails: AsPaymentMethodSwishDetails? { _asInlineFragment() }
      public var asPaymentMethodBankAccountDetails: AsPaymentMethodBankAccountDetails? { _asInlineFragment() }

      /// Details.AsPaymentMethodInvoiceDetails
      ///
      /// Parent Type: `PaymentMethodInvoiceDetails`
      nonisolated public struct AsPaymentMethodInvoiceDetails: OctopusGraphQL.InlineFragment {
        @_spi(Unsafe) public let __data: DataDict
        @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

        public typealias RootEntityType = MemberPaymentMethodFragment.Details
        @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { OctopusGraphQL.Objects.PaymentMethodInvoiceDetails }
        @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
          .field("delivery", GraphQLEnum<OctopusGraphQL.PaymentMethodInvoiceDelivery>.self),
          .field("email", String?.self),
        ] }
        @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
          MemberPaymentMethodFragment.Details.self,
          MemberPaymentMethodFragment.Details.AsPaymentMethodInvoiceDetails.self
        ] }

        ///  How email is delivered - e.g. Kivra or mail. 
        public var delivery: GraphQLEnum<OctopusGraphQL.PaymentMethodInvoiceDelivery> { __data["delivery"] }
        ///  The email address where the invoice is sent in case delivery is set to MAIL. 
        public var email: String? { __data["email"] }
      }

      /// Details.AsPaymentMethodSwishDetails
      ///
      /// Parent Type: `PaymentMethodSwishDetails`
      nonisolated public struct AsPaymentMethodSwishDetails: OctopusGraphQL.InlineFragment {
        @_spi(Unsafe) public let __data: DataDict
        @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

        public typealias RootEntityType = MemberPaymentMethodFragment.Details
        @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { OctopusGraphQL.Objects.PaymentMethodSwishDetails }
        @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
          .field("phoneNumber", String.self),
        ] }
        @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
          MemberPaymentMethodFragment.Details.self,
          MemberPaymentMethodFragment.Details.AsPaymentMethodSwishDetails.self
        ] }

        ///  The Swish phone number. 
        public var phoneNumber: String { __data["phoneNumber"] }
      }

      /// Details.AsPaymentMethodBankAccountDetails
      ///
      /// Parent Type: `PaymentMethodBankAccountDetails`
      nonisolated public struct AsPaymentMethodBankAccountDetails: OctopusGraphQL.InlineFragment {
        @_spi(Unsafe) public let __data: DataDict
        @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

        public typealias RootEntityType = MemberPaymentMethodFragment.Details
        @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { OctopusGraphQL.Objects.PaymentMethodBankAccountDetails }
        @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
          .field("account", String.self),
          .field("bank", String.self),
        ] }
        @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
          MemberPaymentMethodFragment.Details.self,
          MemberPaymentMethodFragment.Details.AsPaymentMethodBankAccountDetails.self
        ] }

        ///  The bank account reference - e.g. clearing number + account number. 
        public var account: String { __data["account"] }
        ///  The name of the bank - e.g. Nordea, SEB, Handelsbanken. 
        public var bank: String { __data["bank"] }
      }
    }
  }

}