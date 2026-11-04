// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI
@_spi(Execution) @_spi(Unsafe) import ApolloAPI

public extension OctopusGraphQL {
  nonisolated struct AddonRemoveStartQuery: GraphQLQuery {
    public static let operationName: String = "AddonRemoveStart"
    public static let operationDocument: ApolloAPI.OperationDocument = .init(
      definition: .init(
        #"query AddonRemoveStart($contractId: ID!) { addonRemoveStart(contractId: $contractId) { __typename ... on UserError { message } ... on AddonRemoveOffer { pageTitle pageDescription currentTotalCost { __typename ...ItemCostFragment } baseCost { __typename ...ItemCostFragment } productVariant { __typename ...ProductVariantFragment } activationDate removableAddons { __typename id cost { __typename ...ItemCostFragment } displayTitle displayDescription } } } }"#,
        fragments: [InsuranceDocumentFragment.self, ItemCostFragment.self, ItemDiscountFragment.self, MoneyFragment.self, PerilFragment.self, ProductVariantFragment.self]
      ))

    public var contractId: ID

    public init(contractId: ID) {
      self.contractId = contractId
    }

    @_spi(Unsafe) public var __variables: Variables? { ["contractId": contractId] }

    nonisolated public struct Data: OctopusGraphQL.SelectionSet {
      @_spi(Unsafe) public let __data: DataDict
      @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

      @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { OctopusGraphQL.Objects.Query }
      @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
        .field("addonRemoveStart", AddonRemoveStart.self, arguments: ["contractId": .variable("contractId")]),
      ] }
      @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
        AddonRemoveStartQuery.Data.self
      ] }

      /// Call this to get removable addon quotes to show in the removal flow.
      public var addonRemoveStart: AddonRemoveStart { __data["addonRemoveStart"] }

      /// AddonRemoveStart
      ///
      /// Parent Type: `AddonRemoveOutput`
      nonisolated public struct AddonRemoveStart: OctopusGraphQL.SelectionSet {
        @_spi(Unsafe) public let __data: DataDict
        @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

        @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { OctopusGraphQL.Unions.AddonRemoveOutput }
        @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
          .field("__typename", String.self),
          .inlineFragment(AsUserError.self),
          .inlineFragment(AsAddonRemoveOffer.self),
        ] }
        @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
          AddonRemoveStartQuery.Data.AddonRemoveStart.self
        ] }

        public var asUserError: AsUserError? { _asInlineFragment() }
        public var asAddonRemoveOffer: AsAddonRemoveOffer? { _asInlineFragment() }

        /// AddonRemoveStart.AsUserError
        ///
        /// Parent Type: `UserError`
        nonisolated public struct AsUserError: OctopusGraphQL.InlineFragment {
          @_spi(Unsafe) public let __data: DataDict
          @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

          public typealias RootEntityType = AddonRemoveStartQuery.Data.AddonRemoveStart
          @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { OctopusGraphQL.Objects.UserError }
          @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
            .field("message", String.self),
          ] }
          @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
            AddonRemoveStartQuery.Data.AddonRemoveStart.self,
            AddonRemoveStartQuery.Data.AddonRemoveStart.AsUserError.self
          ] }

          public var message: String { __data["message"] }
        }

        /// AddonRemoveStart.AsAddonRemoveOffer
        ///
        /// Parent Type: `AddonRemoveOffer`
        nonisolated public struct AsAddonRemoveOffer: OctopusGraphQL.InlineFragment {
          @_spi(Unsafe) public let __data: DataDict
          @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

          public typealias RootEntityType = AddonRemoveStartQuery.Data.AddonRemoveStart
          @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { OctopusGraphQL.Objects.AddonRemoveOffer }
          @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
            .field("pageTitle", String.self),
            .field("pageDescription", String.self),
            .field("currentTotalCost", CurrentTotalCost.self),
            .field("baseCost", BaseCost.self),
            .field("productVariant", ProductVariant.self),
            .field("activationDate", OctopusGraphQL.Date.self),
            .field("removableAddons", [RemovableAddon].self),
          ] }
          @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
            AddonRemoveStartQuery.Data.AddonRemoveStart.self,
            AddonRemoveStartQuery.Data.AddonRemoveStart.AsAddonRemoveOffer.self
          ] }

          /// Title to show in removal page.
          public var pageTitle: String { __data["pageTitle"] }
          /// Description to show in removal page.
          public var pageDescription: String { __data["pageDescription"] }
          /// Current agreement total cost.
          public var currentTotalCost: CurrentTotalCost { __data["currentTotalCost"] }
          /// Base insurance cost after removal of removable addons.
          public var baseCost: BaseCost { __data["baseCost"] }
          /// Product variant.
          public var productVariant: ProductVariant { __data["productVariant"] }
          /// The date the removal will take effect.
          public var activationDate: OctopusGraphQL.Date { __data["activationDate"] }
          /// Addons available for removal.
          public var removableAddons: [RemovableAddon] { __data["removableAddons"] }

          /// AddonRemoveStart.AsAddonRemoveOffer.CurrentTotalCost
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
              AddonRemoveStartQuery.Data.AddonRemoveStart.AsAddonRemoveOffer.CurrentTotalCost.self,
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

          /// AddonRemoveStart.AsAddonRemoveOffer.BaseCost
          ///
          /// Parent Type: `ItemCost`
          nonisolated public struct BaseCost: OctopusGraphQL.SelectionSet {
            @_spi(Unsafe) public let __data: DataDict
            @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

            @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { OctopusGraphQL.Objects.ItemCost }
            @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
              .field("__typename", String.self),
              .fragment(ItemCostFragment.self),
            ] }
            @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
              AddonRemoveStartQuery.Data.AddonRemoveStart.AsAddonRemoveOffer.BaseCost.self,
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

          /// AddonRemoveStart.AsAddonRemoveOffer.ProductVariant
          ///
          /// Parent Type: `ProductVariant`
          nonisolated public struct ProductVariant: OctopusGraphQL.SelectionSet {
            @_spi(Unsafe) public let __data: DataDict
            @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

            @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { OctopusGraphQL.Objects.ProductVariant }
            @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
              .field("__typename", String.self),
              .fragment(ProductVariantFragment.self),
            ] }
            @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
              AddonRemoveStartQuery.Data.AddonRemoveStart.AsAddonRemoveOffer.ProductVariant.self,
              ProductVariantFragment.self
            ] }

            public var perils: [Peril] { __data["perils"] }
            public var typeOfContract: String { __data["typeOfContract"] }
            /// A `ProductVariant` is identified by its terms version, which is the more technical
            /// name for a unique incarnation of our insurances (products) at a point in time.
            public var termsVersion: OctopusGraphQL.ID { __data["termsVersion"] }
            public var documents: [Document] { __data["documents"] }
            public var displayName: String { __data["displayName"] }
            public var displayNameTier: String? { __data["displayNameTier"] }
            public var tierDescription: String? { __data["tierDescription"] }
            public var insurableLimits: [InsurableLimit] { __data["insurableLimits"] }

            public struct Fragments: FragmentContainer {
              @_spi(Unsafe) public let __data: DataDict
              @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

              public var productVariantFragment: ProductVariantFragment { _toFragment() }
            }

            public typealias Peril = ProductVariantFragment.Peril

            public typealias Document = ProductVariantFragment.Document

            public typealias InsurableLimit = ProductVariantFragment.InsurableLimit
          }

          /// AddonRemoveStart.AsAddonRemoveOffer.RemovableAddon
          ///
          /// Parent Type: `ActiveAddon`
          nonisolated public struct RemovableAddon: OctopusGraphQL.SelectionSet {
            @_spi(Unsafe) public let __data: DataDict
            @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

            @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { OctopusGraphQL.Objects.ActiveAddon }
            @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
              .field("__typename", String.self),
              .field("id", OctopusGraphQL.ID.self),
              .field("cost", Cost.self),
              .field("displayTitle", String.self),
              .field("displayDescription", String?.self),
            ] }
            @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
              AddonRemoveStartQuery.Data.AddonRemoveStart.AsAddonRemoveOffer.RemovableAddon.self
            ] }

            public var id: OctopusGraphQL.ID { __data["id"] }
            /// Cost of the existing addon.
            public var cost: Cost { __data["cost"] }
            /// Used for displaying current coverage.
            /// eg Travel Insurance Plus (45 days)
            public var displayTitle: String { __data["displayTitle"] }
            /// Used for displaying current coverage.
            /// eg Risk description
            public var displayDescription: String? { __data["displayDescription"] }

            /// AddonRemoveStart.AsAddonRemoveOffer.RemovableAddon.Cost
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
                AddonRemoveStartQuery.Data.AddonRemoveStart.AsAddonRemoveOffer.RemovableAddon.Cost.self,
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

}