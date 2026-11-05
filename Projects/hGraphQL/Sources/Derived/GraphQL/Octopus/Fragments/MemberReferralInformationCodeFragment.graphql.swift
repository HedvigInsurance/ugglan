// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI
@_spi(Execution) @_spi(Unsafe) import ApolloAPI

public extension OctopusGraphQL {
  nonisolated struct MemberReferralInformationCodeFragment: OctopusGraphQL.SelectionSet, Fragment {
    public static var fragmentDefinition: StaticString {
      #"fragment MemberReferralInformationCodeFragment on MemberReferralInformation { __typename code monthlyDiscountPerReferral { __typename ...MoneyFragment } }"#
    }

    @_spi(Unsafe) public let __data: DataDict
    @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

    @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { OctopusGraphQL.Objects.MemberReferralInformation }
    @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
      .field("__typename", String.self),
      .field("code", String.self),
      .field("monthlyDiscountPerReferral", MonthlyDiscountPerReferral.self),
    ] }
    @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
      MemberReferralInformationCodeFragment.self
    ] }

    /// The unique invite-code this member that can be sent to other people.
    ///
    /// Can be updated with `Mutation.memberReferralInformationCodeUpdate`
    public var code: String { __data["code"] }
    /// How much a single successful referral is worth.
    public var monthlyDiscountPerReferral: MonthlyDiscountPerReferral { __data["monthlyDiscountPerReferral"] }

    /// MonthlyDiscountPerReferral
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
        MemberReferralInformationCodeFragment.MonthlyDiscountPerReferral.self,
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