// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI
@_spi(Execution) @_spi(Unsafe) import ApolloAPI

public extension OctopusGraphQL {
  nonisolated struct ItemCostFragment: OctopusGraphQL.SelectionSet, Fragment {
    public static var fragmentDefinition: StaticString {
      #"fragment ItemCostFragment on ItemCost { __typename monthlyGross { __typename ...MoneyFragment } monthlyNet { __typename ...MoneyFragment } discounts { __typename ...ItemDiscountFragment } }"#
    }

    @_spi(Unsafe) public let __data: DataDict
    @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

    @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { OctopusGraphQL.Objects.ItemCost }
    @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
      .field("__typename", String.self),
      .field("monthlyGross", MonthlyGross.self),
      .field("monthlyNet", MonthlyNet.self),
      .field("discounts", [Discount].self),
    ] }
    @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
      ItemCostFragment.self
    ] }

    public var monthlyGross: MonthlyGross { __data["monthlyGross"] }
    public var monthlyNet: MonthlyNet { __data["monthlyNet"] }
    public var discounts: [Discount] { __data["discounts"] }

    /// MonthlyGross
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
        ItemCostFragment.MonthlyGross.self,
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

    /// MonthlyNet
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
        ItemCostFragment.MonthlyNet.self,
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

    /// Discount
    ///
    /// Parent Type: `ItemDiscount`
    nonisolated public struct Discount: OctopusGraphQL.SelectionSet {
      @_spi(Unsafe) public let __data: DataDict
      @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

      @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { OctopusGraphQL.Objects.ItemDiscount }
      @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
        .field("__typename", String.self),
        .fragment(ItemDiscountFragment.self),
      ] }
      @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
        ItemCostFragment.Discount.self,
        ItemDiscountFragment.self
      ] }

      ///  Short name for list display, ex. "50% puppy discount" 
      public var displayName: String { __data["displayName"] }
      ///  Short value for list display, ex. 50% 99 kr 
      public var displayValue: String { __data["displayValue"] }
      ///  Longer explanation, ex. 50% discount for 6 months 
      public var explanation: String { __data["explanation"] }
      ///  Campaign code or some hardcoded descriptor of discount, ex. BUNDLE / BUYHEDVIG / etc 
      public var campaignCode: String { __data["campaignCode"] }

      public struct Fragments: FragmentContainer {
        @_spi(Unsafe) public let __data: DataDict
        @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

        public var itemDiscountFragment: ItemDiscountFragment { _toFragment() }
      }
    }
  }

}