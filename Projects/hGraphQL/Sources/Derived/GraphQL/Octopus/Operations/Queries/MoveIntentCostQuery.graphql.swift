// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI
@_spi(Execution) @_spi(Unsafe) import ApolloAPI

public extension OctopusGraphQL {
  nonisolated struct MoveIntentCostQuery: GraphQLQuery {
    public static let operationName: String = "MoveIntentCost"
    public static let operationDocument: ApolloAPI.OperationDocument = .init(
      definition: .init(
        #"query MoveIntentCost($intentId: ID!, $selectedAddonIds: [ID!]!, $selectedHomeQuoteId: ID!) { moveIntentCost( intentId: $intentId selectedAddonIds: $selectedAddonIds selectedHomeQuoteId: $selectedHomeQuoteId ) { __typename totalCost { __typename monthlyGross { __typename ...MoneyFragment } monthlyNet { __typename ...MoneyFragment } } quoteCosts { __typename cost { __typename ...ItemCostFragment } quoteId } } }"#,
        fragments: [ItemCostFragment.self, ItemDiscountFragment.self, MoneyFragment.self]
      ))

    public var intentId: ID
    public var selectedAddonIds: [ID]
    public var selectedHomeQuoteId: ID

    public init(
      intentId: ID,
      selectedAddonIds: [ID],
      selectedHomeQuoteId: ID
    ) {
      self.intentId = intentId
      self.selectedAddonIds = selectedAddonIds
      self.selectedHomeQuoteId = selectedHomeQuoteId
    }

    @_spi(Unsafe) public var __variables: Variables? { [
      "intentId": intentId,
      "selectedAddonIds": selectedAddonIds,
      "selectedHomeQuoteId": selectedHomeQuoteId
    ] }

    nonisolated public struct Data: OctopusGraphQL.SelectionSet {
      @_spi(Unsafe) public let __data: DataDict
      @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

      @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { OctopusGraphQL.Objects.Query }
      @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
        .field("moveIntentCost", MoveIntentCost.self, arguments: [
          "intentId": .variable("intentId"),
          "selectedAddonIds": .variable("selectedAddonIds"),
          "selectedHomeQuoteId": .variable("selectedHomeQuoteId")
        ]),
      ] }
      @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
        MoveIntentCostQuery.Data.self
      ] }

      /// Cost for selected configuration of moveIntent
      public var moveIntentCost: MoveIntentCost { __data["moveIntentCost"] }

      /// MoveIntentCost
      ///
      /// Parent Type: `MoveIntentCost`
      nonisolated public struct MoveIntentCost: OctopusGraphQL.SelectionSet {
        @_spi(Unsafe) public let __data: DataDict
        @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

        @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { OctopusGraphQL.Objects.MoveIntentCost }
        @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
          .field("__typename", String.self),
          .field("totalCost", TotalCost.self),
          .field("quoteCosts", [QuoteCost].self),
        ] }
        @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
          MoveIntentCostQuery.Data.MoveIntentCost.self
        ] }

        /// Total breakdown
        public var totalCost: TotalCost { __data["totalCost"] }
        /// Cost breakdown for both home quote and quotes for other contracts
        public var quoteCosts: [QuoteCost] { __data["quoteCosts"] }

        /// MoveIntentCost.TotalCost
        ///
        /// Parent Type: `MoveIntentTotalCost`
        nonisolated public struct TotalCost: OctopusGraphQL.SelectionSet {
          @_spi(Unsafe) public let __data: DataDict
          @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

          @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { OctopusGraphQL.Objects.MoveIntentTotalCost }
          @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
            .field("__typename", String.self),
            .field("monthlyGross", MonthlyGross.self),
            .field("monthlyNet", MonthlyNet.self),
          ] }
          @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
            MoveIntentCostQuery.Data.MoveIntentCost.TotalCost.self
          ] }

          public var monthlyGross: MonthlyGross { __data["monthlyGross"] }
          public var monthlyNet: MonthlyNet { __data["monthlyNet"] }

          /// MoveIntentCost.TotalCost.MonthlyGross
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
              MoveIntentCostQuery.Data.MoveIntentCost.TotalCost.MonthlyGross.self,
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

          /// MoveIntentCost.TotalCost.MonthlyNet
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
              MoveIntentCostQuery.Data.MoveIntentCost.TotalCost.MonthlyNet.self,
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

        /// MoveIntentCost.QuoteCost
        ///
        /// Parent Type: `MoveIntentQuoteCost`
        nonisolated public struct QuoteCost: OctopusGraphQL.SelectionSet {
          @_spi(Unsafe) public let __data: DataDict
          @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

          @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { OctopusGraphQL.Objects.MoveIntentQuoteCost }
          @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
            .field("__typename", String.self),
            .field("cost", Cost.self),
            .field("quoteId", OctopusGraphQL.ID.self),
          ] }
          @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
            MoveIntentCostQuery.Data.MoveIntentCost.QuoteCost.self
          ] }

          public var cost: Cost { __data["cost"] }
          public var quoteId: OctopusGraphQL.ID { __data["quoteId"] }

          /// MoveIntentCost.QuoteCost.Cost
          ///
          /// Parent Type: `ItemCost`
          nonisolated public struct Cost: OctopusGraphQL.SelectionSet {
            @_spi(Unsafe) public let __data: DataDict
            @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

            @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { OctopusGraphQL.Objects.ItemCost }
            @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
              .field("__typename", String.self),
              .fragment(ItemCostFragment.self),
            ] }
            @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
              MoveIntentCostQuery.Data.MoveIntentCost.QuoteCost.Cost.self,
              ItemCostFragment.self
            ] }

            public var monthlyGross: MonthlyGross { __data["monthlyGross"] }
            public var monthlyNet: MonthlyNet { __data["monthlyNet"] }
            public var discounts: [Discount] { __data["discounts"] }

            public struct Fragments: FragmentContainer {
              @_spi(Unsafe) public let __data: DataDict
              @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

              public var itemCostFragment: ItemCostFragment { _toFragment() }
            }

            public typealias MonthlyGross = ItemCostFragment.MonthlyGross

            public typealias MonthlyNet = ItemCostFragment.MonthlyNet

            public typealias Discount = ItemCostFragment.Discount
          }
        }
      }
    }
  }

}