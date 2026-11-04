// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI
@_spi(Execution) @_spi(Unsafe) import ApolloAPI

public extension OctopusGraphQL {
  nonisolated struct MemberReferralFragment2: OctopusGraphQL.SelectionSet, Fragment {
    public static var fragmentDefinition: StaticString {
      #"fragment MemberReferralFragment2 on MemberReferral { __typename name code status activeDiscount { __typename ...MoneyFragment } }"#
    }

    @_spi(Unsafe) public let __data: DataDict
    @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

    @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { OctopusGraphQL.Objects.MemberReferral }
    @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
      .field("__typename", String.self),
      .field("name", String.self),
      .field("code", String?.self),
      .field("status", GraphQLEnum<OctopusGraphQL.MemberReferralStatus>.self),
      .field("activeDiscount", ActiveDiscount?.self),
    ] }
    @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
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

    /// ActiveDiscount
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
        MemberReferralFragment2.ActiveDiscount.self,
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