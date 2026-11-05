// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI
@_spi(Execution) @_spi(Unsafe) import ApolloAPI

public extension OctopusGraphQL {
  nonisolated struct MidtermChangeIntentFragment: OctopusGraphQL.SelectionSet, Fragment {
    public static var fragmentDefinition: StaticString {
      #"fragment MidtermChangeIntentFragment on MidtermChangeIntent { __typename id currentTotalCost { __typename ...TotalCostFragment } newTotalCost { __typename ...TotalCostFragment } activationDate newCostBreakdown { __typename ...MidtermChangePriceDetailItemFragment } }"#
    }

    @_spi(Unsafe) public let __data: DataDict
    @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

    @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { OctopusGraphQL.Objects.MidtermChangeIntent }
    @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
      .field("__typename", String.self),
      .field("id", OctopusGraphQL.ID.self),
      .field("currentTotalCost", CurrentTotalCost.self),
      .field("newTotalCost", NewTotalCost.self),
      .field("activationDate", OctopusGraphQL.Date.self),
      .field("newCostBreakdown", [NewCostBreakdown].self),
    ] }
    @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
      MidtermChangeIntentFragment.self
    ] }

    public var id: OctopusGraphQL.ID { __data["id"] }
    /// Breakdown of current total cost. Includes addons
    public var currentTotalCost: CurrentTotalCost { __data["currentTotalCost"] }
    /// Breakdown of new total cost. Includes addons
    public var newTotalCost: NewTotalCost { __data["newTotalCost"] }
    /// The date changes will take effect.
    public var activationDate: OctopusGraphQL.Date { __data["activationDate"] }
    /// Includes the quote price breakdown:
    /// insurance base premium, addons premiums, campaigns and bundle discounts
    public var newCostBreakdown: [NewCostBreakdown] { __data["newCostBreakdown"] }

    /// CurrentTotalCost
    ///
    /// Parent Type: `TotalCost`
    nonisolated public struct CurrentTotalCost: OctopusGraphQL.SelectionSet {
      @_spi(Unsafe) public let __data: DataDict
      @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

      @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { OctopusGraphQL.Objects.TotalCost }
      @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
        .field("__typename", String.self),
        .fragment(TotalCostFragment.self),
      ] }
      @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
        MidtermChangeIntentFragment.CurrentTotalCost.self,
        TotalCostFragment.self
      ] }

      public var monthlyGross: MonthlyGross { __data["monthlyGross"] }
      public var monthlyNet: MonthlyNet { __data["monthlyNet"] }

      public struct Fragments: FragmentContainer {
        @_spi(Unsafe) public let __data: DataDict
        @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

        public var totalCostFragment: TotalCostFragment { _toFragment() }
      }

      public typealias MonthlyGross = TotalCostFragment.MonthlyGross

      public typealias MonthlyNet = TotalCostFragment.MonthlyNet
    }

    /// NewTotalCost
    ///
    /// Parent Type: `TotalCost`
    nonisolated public struct NewTotalCost: OctopusGraphQL.SelectionSet {
      @_spi(Unsafe) public let __data: DataDict
      @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

      @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { OctopusGraphQL.Objects.TotalCost }
      @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
        .field("__typename", String.self),
        .fragment(TotalCostFragment.self),
      ] }
      @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
        MidtermChangeIntentFragment.NewTotalCost.self,
        TotalCostFragment.self
      ] }

      public var monthlyGross: MonthlyGross { __data["monthlyGross"] }
      public var monthlyNet: MonthlyNet { __data["monthlyNet"] }

      public struct Fragments: FragmentContainer {
        @_spi(Unsafe) public let __data: DataDict
        @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

        public var totalCostFragment: TotalCostFragment { _toFragment() }
      }

      public typealias MonthlyGross = TotalCostFragment.MonthlyGross

      public typealias MonthlyNet = TotalCostFragment.MonthlyNet
    }

    /// NewCostBreakdown
    ///
    /// Parent Type: `MidtermChangePriceDetailItem`
    nonisolated public struct NewCostBreakdown: OctopusGraphQL.SelectionSet {
      @_spi(Unsafe) public let __data: DataDict
      @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

      @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { OctopusGraphQL.Objects.MidtermChangePriceDetailItem }
      @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
        .field("__typename", String.self),
        .fragment(MidtermChangePriceDetailItemFragment.self),
      ] }
      @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
        MidtermChangeIntentFragment.NewCostBreakdown.self,
        MidtermChangePriceDetailItemFragment.self
      ] }

      public var displayName: String { __data["displayName"] }
      public var displayValue: String { __data["displayValue"] }

      public struct Fragments: FragmentContainer {
        @_spi(Unsafe) public let __data: DataDict
        @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

        public var midtermChangePriceDetailItemFragment: MidtermChangePriceDetailItemFragment { _toFragment() }
      }
    }
  }

}