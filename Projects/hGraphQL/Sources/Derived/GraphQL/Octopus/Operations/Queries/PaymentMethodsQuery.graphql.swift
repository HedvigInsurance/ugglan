// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI
@_spi(Execution) @_spi(Unsafe) import ApolloAPI

public extension OctopusGraphQL {
  nonisolated struct PaymentMethodsQuery: GraphQLQuery {
    public static let operationName: String = "PaymentMethods"
    public static let operationDocument: ApolloAPI.OperationDocument = .init(
      definition: .init(
        #"query PaymentMethods($version: Int!) { currentMember { __typename paymentMethods(version: $version) { __typename payinMethods { __typename ...MemberPaymentMethodFragment } payoutMethods { __typename ...MemberPaymentMethodFragment } defaultPayinMethod { __typename ...MemberPaymentMethodFragment } defaultPayoutMethod { __typename ...MemberPaymentMethodFragment } availableMethods { __typename provider supportsPayin supportsPayout } chargingDay missingConnection } activeContracts { __typename terminationDueToMissedPayments terminationDate currentAgreement { __typename productVariant { __typename typeOfContract } } } terminatedContracts { __typename currentAgreement { __typename productVariant { __typename typeOfContract } } } pendingContracts { __typename id productVariant { __typename typeOfContract } } } }"#,
        fragments: [MemberPaymentMethodFragment.self]
      ))

    public var version: Int32

    public init(version: Int32) {
      self.version = version
    }

    @_spi(Unsafe) public var __variables: Variables? { ["version": version] }

    nonisolated public struct Data: OctopusGraphQL.SelectionSet {
      @_spi(Unsafe) public let __data: DataDict
      @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

      @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { OctopusGraphQL.Objects.Query }
      @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
        .field("currentMember", CurrentMember.self),
      ] }
      @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
        PaymentMethodsQuery.Data.self
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
          .field("paymentMethods", PaymentMethods.self, arguments: ["version": .variable("version")]),
          .field("activeContracts", [ActiveContract].self),
          .field("terminatedContracts", [TerminatedContract].self),
          .field("pendingContracts", [PendingContract].self),
        ] }
        @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
          PaymentMethodsQuery.Data.CurrentMember.self
        ] }

        /// The member's payment methods: what they can be charged with, what they are paid out to,
        /// and which connection is still missing.
        public var paymentMethods: PaymentMethods { __data["paymentMethods"] }
        /// Fetch all the active contracts for this member. Active contracts include all insurances that are either
        /// active today, or to-be-active in the future.
        public var activeContracts: [ActiveContract] { __data["activeContracts"] }
        /// Terminated contracts are all past contracts that have ended.
        public var terminatedContracts: [TerminatedContract] { __data["terminatedContracts"] }
        /// Fetch all the pending contracts for this member.
        public var pendingContracts: [PendingContract] { __data["pendingContracts"] }

        /// CurrentMember.PaymentMethods
        ///
        /// Parent Type: `MemberPaymentMethods`
        nonisolated public struct PaymentMethods: OctopusGraphQL.SelectionSet {
          @_spi(Unsafe) public let __data: DataDict
          @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

          @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { OctopusGraphQL.Objects.MemberPaymentMethods }
          @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
            .field("__typename", String.self),
            .field("payinMethods", [PayinMethod].self),
            .field("payoutMethods", [PayoutMethod].self),
            .field("defaultPayinMethod", DefaultPayinMethod?.self),
            .field("defaultPayoutMethod", DefaultPayoutMethod?.self),
            .field("availableMethods", [AvailableMethod].self),
            .field("chargingDay", Int?.self),
            .field("missingConnection", GraphQLEnum<OctopusGraphQL.MissingPaymentConnection>?.self),
          ] }
          @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
            PaymentMethodsQuery.Data.CurrentMember.PaymentMethods.self
          ] }

          /// List of all member's ACTIVE and PENDING payment payin methods.
          /// A member can have multiple ACTIVE payment methods with these constraints:
          /// - Only one ACTIVE payment method per provider, eg. one Trustly, one Swish, one Nordea etc.
          /// - Only one ACTIVE payment method can be default at a time.
          ///
          /// A member can have multiple PENDING payment methods with these constraints:
          /// - Only one PENDING payment method per provider, eg. one Trustly, one Swish, one Nordea etc.
          ///
          /// So there can exist max two payment methods per provider, one ACTIVE and one PENDING.
          ///
          /// If a PENDING payment method has isDefault=true, then it will become the default ACTIVE payment method once activated.
          public var payinMethods: [PayinMethod] { __data["payinMethods"] }
          /// List of all member's ACTIVE and PENDING payment payout methods.
          /// A member can have multiple ACTIVE payment methods with these constraints:
          /// - Only one ACTIVE payment method per provider, eg. one Trustly, one Swish, one Nordea etc.
          /// - Only one ACTIVE payment method can be default at a time.
          ///
          /// A member can have multiple PENDING payment methods with these constraints:
          /// - Only one PENDING payment method per provider, eg. one Trustly, one Swish, one Nordea etc.
          ///
          /// So there can exist max two payment methods per provider, one ACTIVE and one PENDING.
          ///
          /// If a PENDING payment method has isDefault=true, then it will become the default ACTIVE payment method once activated.
          public var payoutMethods: [PayoutMethod] { __data["payoutMethods"] }
          /// The default payment method to use for payins if any.
          /// Note that there can exist a PENDING payment method in `payinMethods` list with `isDefault`=true, in that case this default
          /// payment method will be replaced by it once the pending method is activated.
          public var defaultPayinMethod: DefaultPayinMethod? { __data["defaultPayinMethod"] }
          /// The default payment method to use for payouts if any.
          /// Note that there can exist a PENDING payment method in `payoutMethods` list with `isDefault`=true, in that case this default
          /// payment method will be replaced by it once the pending method is activated.
          public var defaultPayoutMethod: DefaultPayoutMethod? { __data["defaultPayoutMethod"] }
          /// The available payment methods that the member can choose from when setting up a new payment method.
          /// This list can include both payment methods that the member has already set up and new payment methods that the
          /// member has not yet set up but are available to them. For already set up payment methods, the `isActive` field will
          /// be true and the `details` field will be populated with the payment method details. For new payment methods that the
          /// member has not yet set up, the `isActive` field will be false and the `details` field will be null.
          /// If member picks a new payment method to set up, the corresponding mutation for setting up that payment method should
          /// be called, eg. `paymentMethodSetupTrustly`, `paymentMethodSetupSwishPayin` etc.
          /// If member picks an already set up payment method to set up as default, then `paymentMethodSetDefaultPayin` or
          /// `paymentMethodSetDefaultPayout` mutation should be called depending on if it's a payin or payout method.
          public var availableMethods: [AvailableMethod] { __data["availableMethods"] }
          ///  The date of the month when member's premium will be charged (or due if invoice) 
          public var chargingDay: Int? { __data["chargingDay"] }
          /// Indicates which payment connection the member is missing, if any. The rule is:
          /// - If member has only QASA-paid agreements, the payin connection is irrelevant and only payout is checked.
          /// Returns PAYOUT if no default payout method exists, else null.
          /// - Otherwise (any non-QASA agreement, e.g. member-paid), payin takes priority:
          /// Returns PAYIN if no default payin method exists, else PAYOUT if no default payout method exists, else null.
          /// - If member has no ongoing (active or future) agreements, returns null.
          public var missingConnection: GraphQLEnum<OctopusGraphQL.MissingPaymentConnection>? { __data["missingConnection"] }

          /// CurrentMember.PaymentMethods.PayinMethod
          ///
          /// Parent Type: `MemberPaymentMethod`
          nonisolated public struct PayinMethod: OctopusGraphQL.SelectionSet {
            @_spi(Unsafe) public let __data: DataDict
            @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

            @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { OctopusGraphQL.Objects.MemberPaymentMethod }
            @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
              .field("__typename", String.self),
              .fragment(MemberPaymentMethodFragment.self),
            ] }
            @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
              PaymentMethodsQuery.Data.CurrentMember.PaymentMethods.PayinMethod.self,
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

            public struct Fragments: FragmentContainer {
              @_spi(Unsafe) public let __data: DataDict
              @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

              public var memberPaymentMethodFragment: MemberPaymentMethodFragment { _toFragment() }
            }

            public typealias Details = MemberPaymentMethodFragment.Details
          }

          /// CurrentMember.PaymentMethods.PayoutMethod
          ///
          /// Parent Type: `MemberPaymentMethod`
          nonisolated public struct PayoutMethod: OctopusGraphQL.SelectionSet {
            @_spi(Unsafe) public let __data: DataDict
            @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

            @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { OctopusGraphQL.Objects.MemberPaymentMethod }
            @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
              .field("__typename", String.self),
              .fragment(MemberPaymentMethodFragment.self),
            ] }
            @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
              PaymentMethodsQuery.Data.CurrentMember.PaymentMethods.PayoutMethod.self,
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

            public struct Fragments: FragmentContainer {
              @_spi(Unsafe) public let __data: DataDict
              @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

              public var memberPaymentMethodFragment: MemberPaymentMethodFragment { _toFragment() }
            }

            public typealias Details = MemberPaymentMethodFragment.Details
          }

          /// CurrentMember.PaymentMethods.DefaultPayinMethod
          ///
          /// Parent Type: `MemberPaymentMethod`
          nonisolated public struct DefaultPayinMethod: OctopusGraphQL.SelectionSet {
            @_spi(Unsafe) public let __data: DataDict
            @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

            @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { OctopusGraphQL.Objects.MemberPaymentMethod }
            @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
              .field("__typename", String.self),
              .fragment(MemberPaymentMethodFragment.self),
            ] }
            @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
              PaymentMethodsQuery.Data.CurrentMember.PaymentMethods.DefaultPayinMethod.self,
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

            public struct Fragments: FragmentContainer {
              @_spi(Unsafe) public let __data: DataDict
              @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

              public var memberPaymentMethodFragment: MemberPaymentMethodFragment { _toFragment() }
            }

            public typealias Details = MemberPaymentMethodFragment.Details
          }

          /// CurrentMember.PaymentMethods.DefaultPayoutMethod
          ///
          /// Parent Type: `MemberPaymentMethod`
          nonisolated public struct DefaultPayoutMethod: OctopusGraphQL.SelectionSet {
            @_spi(Unsafe) public let __data: DataDict
            @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

            @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { OctopusGraphQL.Objects.MemberPaymentMethod }
            @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
              .field("__typename", String.self),
              .fragment(MemberPaymentMethodFragment.self),
            ] }
            @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
              PaymentMethodsQuery.Data.CurrentMember.PaymentMethods.DefaultPayoutMethod.self,
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

            public struct Fragments: FragmentContainer {
              @_spi(Unsafe) public let __data: DataDict
              @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

              public var memberPaymentMethodFragment: MemberPaymentMethodFragment { _toFragment() }
            }

            public typealias Details = MemberPaymentMethodFragment.Details
          }

          /// CurrentMember.PaymentMethods.AvailableMethod
          ///
          /// Parent Type: `MemberPaymentAvailablePaymentMethod`
          nonisolated public struct AvailableMethod: OctopusGraphQL.SelectionSet {
            @_spi(Unsafe) public let __data: DataDict
            @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

            @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { OctopusGraphQL.Objects.MemberPaymentAvailablePaymentMethod }
            @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
              .field("__typename", String.self),
              .field("provider", GraphQLEnum<OctopusGraphQL.MemberPaymentProvider>.self),
              .field("supportsPayin", Bool.self),
              .field("supportsPayout", Bool.self),
            ] }
            @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
              PaymentMethodsQuery.Data.CurrentMember.PaymentMethods.AvailableMethod.self
            ] }

            ///  Payment provider, eg Trustly, Swish, Nordea, Kivra etc. 
            public var provider: GraphQLEnum<OctopusGraphQL.MemberPaymentProvider> { __data["provider"] }
            ///  True if the member can set up this payment method for payin. 
            public var supportsPayin: Bool { __data["supportsPayin"] }
            ///  True if the member can set up this payment method for payout. 
            public var supportsPayout: Bool { __data["supportsPayout"] }
          }
        }

        /// CurrentMember.ActiveContract
        ///
        /// Parent Type: `Contract`
        nonisolated public struct ActiveContract: OctopusGraphQL.SelectionSet {
          @_spi(Unsafe) public let __data: DataDict
          @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

          @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { OctopusGraphQL.Objects.Contract }
          @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
            .field("__typename", String.self),
            .field("terminationDueToMissedPayments", Bool.self),
            .field("terminationDate", OctopusGraphQL.Date?.self),
            .field("currentAgreement", CurrentAgreement.self),
          ] }
          @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
            PaymentMethodsQuery.Data.CurrentMember.ActiveContract.self
          ] }

          /// Whether or not this contract has termination status because of missed payments
          public var terminationDueToMissedPayments: Bool { __data["terminationDueToMissedPayments"] }
          /// The last date this insurance will be active, if there is one.
          public var terminationDate: OctopusGraphQL.Date? { __data["terminationDate"] }
          /// The currently active/relevant agreement for this contract.
          public var currentAgreement: CurrentAgreement { __data["currentAgreement"] }

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
              PaymentMethodsQuery.Data.CurrentMember.ActiveContract.CurrentAgreement.self
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
                .field("typeOfContract", String.self),
              ] }
              @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
                PaymentMethodsQuery.Data.CurrentMember.ActiveContract.CurrentAgreement.ProductVariant.self
              ] }

              public var typeOfContract: String { __data["typeOfContract"] }
            }
          }
        }

        /// CurrentMember.TerminatedContract
        ///
        /// Parent Type: `Contract`
        nonisolated public struct TerminatedContract: OctopusGraphQL.SelectionSet {
          @_spi(Unsafe) public let __data: DataDict
          @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

          @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { OctopusGraphQL.Objects.Contract }
          @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
            .field("__typename", String.self),
            .field("currentAgreement", CurrentAgreement.self),
          ] }
          @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
            PaymentMethodsQuery.Data.CurrentMember.TerminatedContract.self
          ] }

          /// The currently active/relevant agreement for this contract.
          public var currentAgreement: CurrentAgreement { __data["currentAgreement"] }

          /// CurrentMember.TerminatedContract.CurrentAgreement
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
              PaymentMethodsQuery.Data.CurrentMember.TerminatedContract.CurrentAgreement.self
            ] }

            /// The ProductVariant of the agreement, which is the umbrella container for a lot of data related to the insurance,
            /// such as names, legal documents, perils etc.
            public var productVariant: ProductVariant { __data["productVariant"] }

            /// CurrentMember.TerminatedContract.CurrentAgreement.ProductVariant
            ///
            /// Parent Type: `ProductVariant`
            nonisolated public struct ProductVariant: OctopusGraphQL.SelectionSet {
              @_spi(Unsafe) public let __data: DataDict
              @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

              @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { OctopusGraphQL.Objects.ProductVariant }
              @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
                .field("__typename", String.self),
                .field("typeOfContract", String.self),
              ] }
              @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
                PaymentMethodsQuery.Data.CurrentMember.TerminatedContract.CurrentAgreement.ProductVariant.self
              ] }

              public var typeOfContract: String { __data["typeOfContract"] }
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
            .field("productVariant", ProductVariant.self),
          ] }
          @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
            PaymentMethodsQuery.Data.CurrentMember.PendingContract.self
          ] }

          public var id: OctopusGraphQL.UUID { __data["id"] }
          /// Same as `Contract.currentAgreement.productVariant`.
          public var productVariant: ProductVariant { __data["productVariant"] }

          /// CurrentMember.PendingContract.ProductVariant
          ///
          /// Parent Type: `ProductVariant`
          nonisolated public struct ProductVariant: OctopusGraphQL.SelectionSet {
            @_spi(Unsafe) public let __data: DataDict
            @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

            @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { OctopusGraphQL.Objects.ProductVariant }
            @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
              .field("__typename", String.self),
              .field("typeOfContract", String.self),
            ] }
            @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
              PaymentMethodsQuery.Data.CurrentMember.PendingContract.ProductVariant.self
            ] }

            public var typeOfContract: String { __data["typeOfContract"] }
          }
        }
      }
    }
  }

}