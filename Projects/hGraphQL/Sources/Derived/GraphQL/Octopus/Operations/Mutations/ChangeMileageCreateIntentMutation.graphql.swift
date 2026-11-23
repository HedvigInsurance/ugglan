// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI
@_spi(Execution) @_spi(Unsafe) import ApolloAPI

public extension OctopusGraphQL {
  nonisolated struct ChangeMileageCreateIntentMutation: GraphQLMutation {
    public static let operationName: String = "ChangeMileageCreateIntent"
    public static let operationDocument: ApolloAPI.OperationDocument = .init(
      definition: .init(
        #"mutation ChangeMileageCreateIntent($contractId: ID!) { changeMileageCreateIntent(contractId: $contractId) { __typename ... on ChangeMileageIntent { activationDate currentTotalCost { __typename ...ItemCostFragment } quotes { __typename id displayName isCurrent totalCost { __typename ...ItemCostFragment } displayItems { __typename displayTitle displayValue previousDisplayValue } } } ... on UserError { message } } }"#,
        fragments: [ItemCostFragment.self, ItemDiscountFragment.self, MoneyFragment.self]
      ))

    public var contractId: ID

    public init(contractId: ID) {
      self.contractId = contractId
    }

    @_spi(Unsafe) public var __variables: Variables? { ["contractId": contractId] }

    nonisolated public struct Data: OctopusGraphQL.SelectionSet {
      @_spi(Unsafe) public let __data: DataDict
      @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

      @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { OctopusGraphQL.Objects.Mutation }
      @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
        .field("changeMileageCreateIntent", ChangeMileageCreateIntent.self, arguments: ["contractId": .variable("contractId")]),
      ] }
      @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
        ChangeMileageCreateIntentMutation.Data.self
      ] }

      /// Creates quotes for all yearly mileage options the contract can be changed to.
      public var changeMileageCreateIntent: ChangeMileageCreateIntent { __data["changeMileageCreateIntent"] }

      /// ChangeMileageCreateIntent
      ///
      /// Parent Type: `ChangeMileageCreateIntentOutput`
      nonisolated public struct ChangeMileageCreateIntent: OctopusGraphQL.SelectionSet {
        @_spi(Unsafe) public let __data: DataDict
        @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

        @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { OctopusGraphQL.Unions.ChangeMileageCreateIntentOutput }
        @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
          .field("__typename", String.self),
          .inlineFragment(AsChangeMileageIntent.self),
          .inlineFragment(AsUserError.self),
        ] }
        @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
          ChangeMileageCreateIntentMutation.Data.ChangeMileageCreateIntent.self
        ] }

        public var asChangeMileageIntent: AsChangeMileageIntent? { _asInlineFragment() }
        public var asUserError: AsUserError? { _asInlineFragment() }

        /// ChangeMileageCreateIntent.AsChangeMileageIntent
        ///
        /// Parent Type: `ChangeMileageIntent`
        nonisolated public struct AsChangeMileageIntent: OctopusGraphQL.InlineFragment {
          @_spi(Unsafe) public let __data: DataDict
          @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

          public typealias RootEntityType = ChangeMileageCreateIntentMutation.Data.ChangeMileageCreateIntent
          @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { OctopusGraphQL.Objects.ChangeMileageIntent }
          @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
            .field("activationDate", OctopusGraphQL.Date.self),
            .field("currentTotalCost", CurrentTotalCost.self),
            .field("quotes", [Quote].self),
          ] }
          @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
            ChangeMileageCreateIntentMutation.Data.ChangeMileageCreateIntent.self,
            ChangeMileageCreateIntentMutation.Data.ChangeMileageCreateIntent.AsChangeMileageIntent.self
          ] }

          ///  The date the change will take effect. Tomorrow, or the start date of an upcoming change or renewal if there is one. 
          public var activationDate: OctopusGraphQL.Date { __data["activationDate"] }
          ///  Total monthly cost of the contract on the activation date without the change (incl. addons) 
          public var currentTotalCost: CurrentTotalCost { __data["currentTotalCost"] }
          ///  Sorted ascending by mileage. Exactly one has isCurrent = true. 
          public var quotes: [Quote] { __data["quotes"] }

          /// ChangeMileageCreateIntent.AsChangeMileageIntent.CurrentTotalCost
          ///
          /// Parent Type: `ItemCost`
          nonisolated public struct CurrentTotalCost: OctopusGraphQL.SelectionSet {
            @_spi(Unsafe) public let __data: DataDict
            @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

            @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { OctopusGraphQL.Objects.ItemCost }
            @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
              .field("__typename", String.self),
              .fragment(ItemCostFragment.self),
            ] }
            @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
              ChangeMileageCreateIntentMutation.Data.ChangeMileageCreateIntent.AsChangeMileageIntent.CurrentTotalCost.self,
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

          /// ChangeMileageCreateIntent.AsChangeMileageIntent.Quote
          ///
          /// Parent Type: `ChangeMileageQuote`
          nonisolated public struct Quote: OctopusGraphQL.SelectionSet {
            @_spi(Unsafe) public let __data: DataDict
            @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

            @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { OctopusGraphQL.Objects.ChangeMileageQuote }
            @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
              .field("__typename", String.self),
              .field("id", OctopusGraphQL.ID.self),
              .field("displayName", String.self),
              .field("isCurrent", Bool.self),
              .field("totalCost", TotalCost.self),
              .field("displayItems", [DisplayItem].self),
            ] }
            @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
              ChangeMileageCreateIntentMutation.Data.ChangeMileageCreateIntent.AsChangeMileageIntent.Quote.self
            ] }

            /// The quote id. For the quote with isCurrent = true no quote is created, and this is the id of the agreement that is changed.
            public var id: OctopusGraphQL.ID { __data["id"] }
            ///  The mileage option, ex. "1 000 mil", "Över 2 500 mil" 
            public var displayName: String { __data["displayName"] }
            ///  Whether this is the mileage the contract already has on the activation date 
            public var isCurrent: Bool { __data["isCurrent"] }
            ///  Total monthly contract cost if this mileage is chosen (incl. addons) 
            public var totalCost: TotalCost { __data["totalCost"] }
            ///  Summary rows, ex. mileage, registration number and coverage level 
            public var displayItems: [DisplayItem] { __data["displayItems"] }

            /// ChangeMileageCreateIntent.AsChangeMileageIntent.Quote.TotalCost
            ///
            /// Parent Type: `ItemCost`
            nonisolated public struct TotalCost: OctopusGraphQL.SelectionSet {
              @_spi(Unsafe) public let __data: DataDict
              @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

              @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { OctopusGraphQL.Objects.ItemCost }
              @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
                .field("__typename", String.self),
                .fragment(ItemCostFragment.self),
              ] }
              @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
                ChangeMileageCreateIntentMutation.Data.ChangeMileageCreateIntent.AsChangeMileageIntent.Quote.TotalCost.self,
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

            /// ChangeMileageCreateIntent.AsChangeMileageIntent.Quote.DisplayItem
            ///
            /// Parent Type: `ChangeMileageDisplayItem`
            nonisolated public struct DisplayItem: OctopusGraphQL.SelectionSet {
              @_spi(Unsafe) public let __data: DataDict
              @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

              @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { OctopusGraphQL.Objects.ChangeMileageDisplayItem }
              @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
                .field("__typename", String.self),
                .field("displayTitle", String.self),
                .field("displayValue", String.self),
                .field("previousDisplayValue", String?.self),
              ] }
              @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
                ChangeMileageCreateIntentMutation.Data.ChangeMileageCreateIntent.AsChangeMileageIntent.Quote.DisplayItem.self
              ] }

              public var displayTitle: String { __data["displayTitle"] }
              public var displayValue: String { __data["displayValue"] }
              ///  The value without the change. Set only when this quote changes the row. 
              public var previousDisplayValue: String? { __data["previousDisplayValue"] }
            }
          }
        }

        /// ChangeMileageCreateIntent.AsUserError
        ///
        /// Parent Type: `UserError`
        nonisolated public struct AsUserError: OctopusGraphQL.InlineFragment {
          @_spi(Unsafe) public let __data: DataDict
          @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

          public typealias RootEntityType = ChangeMileageCreateIntentMutation.Data.ChangeMileageCreateIntent
          @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { OctopusGraphQL.Objects.UserError }
          @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
            .field("message", String.self),
          ] }
          @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
            ChangeMileageCreateIntentMutation.Data.ChangeMileageCreateIntent.self,
            ChangeMileageCreateIntentMutation.Data.ChangeMileageCreateIntent.AsUserError.self
          ] }

          public var message: String { __data["message"] }
        }
      }
    }
  }

}