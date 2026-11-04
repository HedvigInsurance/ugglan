// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI
@_spi(Execution) @_spi(Unsafe) import ApolloAPI

public extension OctopusGraphQL {
  nonisolated struct AddonOfferCostQuery: GraphQLQuery {
    public static let operationName: String = "AddonOfferCost"
    public static let operationDocument: ApolloAPI.OperationDocument = .init(
      definition: .init(
        #"query AddonOfferCost($quoteId: ID!, $selectedAddonIds: [ID!]!) { addonOfferCost(quoteId: $quoteId, selectedAddonIds: $selectedAddonIds) { __typename ...ItemCostFragment } }"#,
        fragments: [ItemCostFragment.self, ItemDiscountFragment.self, MoneyFragment.self]
      ))

    public var quoteId: ID
    public var selectedAddonIds: [ID]

    public init(
      quoteId: ID,
      selectedAddonIds: [ID]
    ) {
      self.quoteId = quoteId
      self.selectedAddonIds = selectedAddonIds
    }

    @_spi(Unsafe) public var __variables: Variables? { [
      "quoteId": quoteId,
      "selectedAddonIds": selectedAddonIds
    ] }

    nonisolated public struct Data: OctopusGraphQL.SelectionSet {
      @_spi(Unsafe) public let __data: DataDict
      @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

      @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { OctopusGraphQL.Objects.Query }
      @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
        .field("addonOfferCost", AddonOfferCost.self, arguments: [
          "quoteId": .variable("quoteId"),
          "selectedAddonIds": .variable("selectedAddonIds")
        ]),
      ] }
      @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
        AddonOfferCostQuery.Data.self
      ] }

      /// Call this to get the cost of an addon offer for selected addon(s).
      public var addonOfferCost: AddonOfferCost { __data["addonOfferCost"] }

      /// AddonOfferCost
      ///
      /// Parent Type: `ItemCost`
      nonisolated public struct AddonOfferCost: OctopusGraphQL.SelectionSet {
        @_spi(Unsafe) public let __data: DataDict
        @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

        @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { OctopusGraphQL.Objects.ItemCost }
        @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
          .field("__typename", String.self),
          .fragment(ItemCostFragment.self),
        ] }
        @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
          AddonOfferCostQuery.Data.AddonOfferCost.self,
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