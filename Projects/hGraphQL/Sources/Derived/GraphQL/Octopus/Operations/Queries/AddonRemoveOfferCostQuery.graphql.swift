// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI
@_spi(Execution) @_spi(Unsafe) import ApolloAPI

public extension OctopusGraphQL {
  nonisolated struct AddonRemoveOfferCostQuery: GraphQLQuery {
    public static let operationName: String = "AddonRemoveOfferCost"
    public static let operationDocument: ApolloAPI.OperationDocument = .init(
      definition: .init(
        #"query AddonRemoveOfferCost($contractId: ID!, $addonIds: [ID!]!) { addonRemoveOfferCost(contractId: $contractId, addonIds: $addonIds) { __typename ...ItemCostFragment } }"#,
        fragments: [ItemCostFragment.self, ItemDiscountFragment.self, MoneyFragment.self]
      ))

    public var contractId: ID
    public var addonIds: [ID]

    public init(
      contractId: ID,
      addonIds: [ID]
    ) {
      self.contractId = contractId
      self.addonIds = addonIds
    }

    @_spi(Unsafe) public var __variables: Variables? { [
      "contractId": contractId,
      "addonIds": addonIds
    ] }

    nonisolated public struct Data: OctopusGraphQL.SelectionSet {
      @_spi(Unsafe) public let __data: DataDict
      @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

      @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { OctopusGraphQL.Objects.Query }
      @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
        .field("addonRemoveOfferCost", AddonRemoveOfferCost.self, arguments: [
          "contractId": .variable("contractId"),
          "addonIds": .variable("addonIds")
        ]),
      ] }
      @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
        AddonRemoveOfferCostQuery.Data.self
      ] }

      /// Cost for selected configuration of removed addon offer
      public var addonRemoveOfferCost: AddonRemoveOfferCost { __data["addonRemoveOfferCost"] }

      /// AddonRemoveOfferCost
      ///
      /// Parent Type: `ItemCost`
      nonisolated public struct AddonRemoveOfferCost: OctopusGraphQL.SelectionSet {
        @_spi(Unsafe) public let __data: DataDict
        @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

        @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { OctopusGraphQL.Objects.ItemCost }
        @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
          .field("__typename", String.self),
          .fragment(ItemCostFragment.self),
        ] }
        @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
          AddonRemoveOfferCostQuery.Data.AddonRemoveOfferCost.self,
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