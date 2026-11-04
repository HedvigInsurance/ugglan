// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI
@_spi(Execution) @_spi(Unsafe) import ApolloAPI

public extension OctopusGraphQL {
  nonisolated struct AddonGenerateOfferMutation: GraphQLMutation {
    public static let operationName: String = "AddonGenerateOffer"
    public static let operationDocument: ApolloAPI.OperationDocument = .init(
      definition: .init(
        #"mutation AddonGenerateOffer($contractId: ID!) { addonGenerateOffer(contractId: $contractId) { __typename ... on UserError { message } ... on AddonOffer { pageTitle pageDescription infoMessage quote { __typename quoteId displayTitle displayDescription activationDate addonOffer { __typename ... on AddonOfferSelectable { fieldTitle selectionTitle selectionDescription quotes { __typename ...AddonOfferQuoteFragment } } ... on AddonOfferToggleable { quotes { __typename ...AddonOfferQuoteFragment } } } activeAddons { __typename id cost { __typename ...ItemCostFragment } displayTitle displayDescription } baseQuoteCost { __typename ...ItemCostFragment } productVariant { __typename ...ProductVariantFragment } } currentTotalCost { __typename ...ItemCostFragment } whatsIncludedPageTitle whatsIncludedPageDescription } ... on AddonOfferDeflect { pageTitle pageDescription type } } }"#,
        fragments: [AddonOfferQuoteFragment.self, AddonVariantFragment.self, InsuranceDocumentFragment.self, ItemCostFragment.self, ItemDiscountFragment.self, MoneyFragment.self, PerilFragment.self, ProductVariantFragment.self]
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
        .field("addonGenerateOffer", AddonGenerateOffer.self, arguments: ["contractId": .variable("contractId")]),
      ] }
      @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
        AddonGenerateOfferMutation.Data.self
      ] }

      /// Call this to get addon quotes with price etc to show in the offer page.
      /// Call this when starting the add/upgrade addon flow.
      public var addonGenerateOffer: AddonGenerateOffer { __data["addonGenerateOffer"] }

      /// AddonGenerateOffer
      ///
      /// Parent Type: `AddonOfferOutput`
      nonisolated public struct AddonGenerateOffer: OctopusGraphQL.SelectionSet {
        @_spi(Unsafe) public let __data: DataDict
        @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

        @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { OctopusGraphQL.Unions.AddonOfferOutput }
        @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
          .field("__typename", String.self),
          .inlineFragment(AsUserError.self),
          .inlineFragment(AsAddonOffer.self),
          .inlineFragment(AsAddonOfferDeflect.self),
        ] }
        @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
          AddonGenerateOfferMutation.Data.AddonGenerateOffer.self
        ] }

        public var asUserError: AsUserError? { _asInlineFragment() }
        public var asAddonOffer: AsAddonOffer? { _asInlineFragment() }
        public var asAddonOfferDeflect: AsAddonOfferDeflect? { _asInlineFragment() }

        /// AddonGenerateOffer.AsUserError
        ///
        /// Parent Type: `UserError`
        nonisolated public struct AsUserError: OctopusGraphQL.InlineFragment {
          @_spi(Unsafe) public let __data: DataDict
          @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

          public typealias RootEntityType = AddonGenerateOfferMutation.Data.AddonGenerateOffer
          @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { OctopusGraphQL.Objects.UserError }
          @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
            .field("message", String.self),
          ] }
          @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
            AddonGenerateOfferMutation.Data.AddonGenerateOffer.self,
            AddonGenerateOfferMutation.Data.AddonGenerateOffer.AsUserError.self
          ] }

          public var message: String { __data["message"] }
        }

        /// AddonGenerateOffer.AsAddonOffer
        ///
        /// Parent Type: `AddonOffer`
        nonisolated public struct AsAddonOffer: OctopusGraphQL.InlineFragment {
          @_spi(Unsafe) public let __data: DataDict
          @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

          public typealias RootEntityType = AddonGenerateOfferMutation.Data.AddonGenerateOffer
          @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { OctopusGraphQL.Objects.AddonOffer }
          @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
            .field("pageTitle", String.self),
            .field("pageDescription", String.self),
            .field("infoMessage", String?.self),
            .field("quote", Quote.self),
            .field("currentTotalCost", CurrentTotalCost.self),
            .field("whatsIncludedPageTitle", String.self),
            .field("whatsIncludedPageDescription", String.self),
          ] }
          @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
            AddonGenerateOfferMutation.Data.AddonGenerateOffer.self,
            AddonGenerateOfferMutation.Data.AddonGenerateOffer.AsAddonOffer.self
          ] }

          /// Title to show in offer page.
          /// eg "Extend your coverage"
          public var pageTitle: String { __data["pageTitle"] }
          /// Description to show in offer page.
          /// eg "Get extra coverage when you travel abroad"
          public var pageDescription: String { __data["pageDescription"] }
          /// Optional info message to show on the summary page.
          public var infoMessage: String? { __data["infoMessage"] }
          /// New quote
          public var quote: Quote { __data["quote"] }
          /// Agreement total cost
          public var currentTotalCost: CurrentTotalCost { __data["currentTotalCost"] }
          /// Title to show in what's included page.
          /// eg "What is Travel Insurance Plus?"
          public var whatsIncludedPageTitle: String { __data["whatsIncludedPageTitle"] }
          /// Description to show in what's included page.
          /// eg "Travel Insurance Plus is extended coverage for those..."
          public var whatsIncludedPageDescription: String { __data["whatsIncludedPageDescription"] }

          /// AddonGenerateOffer.AsAddonOffer.Quote
          ///
          /// Parent Type: `AddonContractQuote`
          nonisolated public struct Quote: OctopusGraphQL.SelectionSet {
            @_spi(Unsafe) public let __data: DataDict
            @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

            @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { OctopusGraphQL.Objects.AddonContractQuote }
            @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
              .field("__typename", String.self),
              .field("quoteId", OctopusGraphQL.ID.self),
              .field("displayTitle", String.self),
              .field("displayDescription", String.self),
              .field("activationDate", OctopusGraphQL.Date.self),
              .field("addonOffer", AddonOffer.self),
              .field("activeAddons", [ActiveAddon].self),
              .field("baseQuoteCost", BaseQuoteCost.self),
              .field("productVariant", ProductVariant.self),
            ] }
            @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
              AddonGenerateOfferMutation.Data.AddonGenerateOffer.AsAddonOffer.Quote.self
            ] }

            /// Id of the quote.
            public var quoteId: OctopusGraphQL.ID { __data["quoteId"] }
            /// Display title of the addon group. eg Travel plus or Car Plus
            public var displayTitle: String { __data["displayTitle"] }
            /// Display description of the addon group.
            /// eg For those who travel often: luggage protection and 24/7 assistance worldwide
            public var displayDescription: String { __data["displayDescription"] }
            /// The date the addon will be activated.
            public var activationDate: OctopusGraphQL.Date { __data["activationDate"] }
            /// Addon Content
            public var addonOffer: AddonOffer { __data["addonOffer"] }
            /// List of member current addons
            public var activeAddons: [ActiveAddon] { __data["activeAddons"] }
            /// Base insurance cost
            public var baseQuoteCost: BaseQuoteCost { __data["baseQuoteCost"] }
            /// Product variant
            public var productVariant: ProductVariant { __data["productVariant"] }

            /// AddonGenerateOffer.AsAddonOffer.Quote.AddonOffer
            ///
            /// Parent Type: `AddonOfferContent`
            nonisolated public struct AddonOffer: OctopusGraphQL.SelectionSet {
              @_spi(Unsafe) public let __data: DataDict
              @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

              @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { OctopusGraphQL.Unions.AddonOfferContent }
              @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
                .field("__typename", String.self),
                .inlineFragment(AsAddonOfferSelectable.self),
                .inlineFragment(AsAddonOfferToggleable.self),
              ] }
              @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
                AddonGenerateOfferMutation.Data.AddonGenerateOffer.AsAddonOffer.Quote.AddonOffer.self
              ] }

              public var asAddonOfferSelectable: AsAddonOfferSelectable? { _asInlineFragment() }
              public var asAddonOfferToggleable: AsAddonOfferToggleable? { _asInlineFragment() }

              /// AddonGenerateOffer.AsAddonOffer.Quote.AddonOffer.AsAddonOfferSelectable
              ///
              /// Parent Type: `AddonOfferSelectable`
              nonisolated public struct AsAddonOfferSelectable: OctopusGraphQL.InlineFragment {
                @_spi(Unsafe) public let __data: DataDict
                @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

                public typealias RootEntityType = AddonGenerateOfferMutation.Data.AddonGenerateOffer.AsAddonOffer.Quote.AddonOffer
                @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { OctopusGraphQL.Objects.AddonOfferSelectable }
                @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
                  .field("fieldTitle", String.self),
                  .field("selectionTitle", String.self),
                  .field("selectionDescription", String.self),
                  .field("quotes", [Quote].self),
                ] }
                @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
                  AddonGenerateOfferMutation.Data.AddonGenerateOffer.AsAddonOffer.Quote.AddonOffer.self,
                  AddonGenerateOfferMutation.Data.AddonGenerateOffer.AsAddonOffer.Quote.AddonOffer.AsAddonOfferSelectable.self
                ] }

                /// Display title for variants
                /// eg "Maximum travel limit"
                public var fieldTitle: String { __data["fieldTitle"] }
                /// Info title when selecting from variants
                /// eg "Choose your maximum travel limit"
                public var selectionTitle: String { __data["selectionTitle"] }
                /// Info description when selecting from variants
                /// eg "Days covered when travelling"
                public var selectionDescription: String { __data["selectionDescription"] }
                /// Quotes for addons
                public var quotes: [Quote] { __data["quotes"] }

                /// AddonGenerateOffer.AsAddonOffer.Quote.AddonOffer.AsAddonOfferSelectable.Quote
                ///
                /// Parent Type: `AddonOfferQuote`
                nonisolated public struct Quote: OctopusGraphQL.SelectionSet {
                  @_spi(Unsafe) public let __data: DataDict
                  @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

                  @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { OctopusGraphQL.Objects.AddonOfferQuote }
                  @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
                    .field("__typename", String.self),
                    .fragment(AddonOfferQuoteFragment.self),
                  ] }
                  @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
                    AddonGenerateOfferMutation.Data.AddonGenerateOffer.AsAddonOffer.Quote.AddonOffer.AsAddonOfferSelectable.Quote.self,
                    AddonOfferQuoteFragment.self
                  ] }

                  /// Id of the addon.
                  public var id: OctopusGraphQL.ID { __data["id"] }
                  /// Display value of the addon. Will be shown in the select days dropdown. eg 45 days 60 days
                  public var displayTitle: String { __data["displayTitle"] }
                  /// Display description we want to show that explains addon
                  public var displayDescription: String { __data["displayDescription"] }
                  ///  Addon subtype 
                  public var subtype: String? { __data["subtype"] }
                  /// Display items of the addon.
                  /// eg 'Coverage' with a value of '45 days'
                  public var displayItems: [DisplayItem] { __data["displayItems"] }
                  /// Cost of the addon
                  public var cost: Cost { __data["cost"] }
                  /// Addon variant
                  public var addonVariant: AddonVariant { __data["addonVariant"] }

                  public struct Fragments: FragmentContainer {
                    @_spi(Unsafe) public let __data: DataDict
                    @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

                    public var addonOfferQuoteFragment: AddonOfferQuoteFragment { _toFragment() }
                  }

                  public typealias DisplayItem = AddonOfferQuoteFragment.DisplayItem

                  public typealias Cost = AddonOfferQuoteFragment.Cost

                  public typealias AddonVariant = AddonOfferQuoteFragment.AddonVariant
                }
              }

              /// AddonGenerateOffer.AsAddonOffer.Quote.AddonOffer.AsAddonOfferToggleable
              ///
              /// Parent Type: `AddonOfferToggleable`
              nonisolated public struct AsAddonOfferToggleable: OctopusGraphQL.InlineFragment {
                @_spi(Unsafe) public let __data: DataDict
                @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

                public typealias RootEntityType = AddonGenerateOfferMutation.Data.AddonGenerateOffer.AsAddonOffer.Quote.AddonOffer
                @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { OctopusGraphQL.Objects.AddonOfferToggleable }
                @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
                  .field("quotes", [Quote].self),
                ] }
                @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
                  AddonGenerateOfferMutation.Data.AddonGenerateOffer.AsAddonOffer.Quote.AddonOffer.self,
                  AddonGenerateOfferMutation.Data.AddonGenerateOffer.AsAddonOffer.Quote.AddonOffer.AsAddonOfferToggleable.self
                ] }

                /// Quotes for addon
                public var quotes: [Quote] { __data["quotes"] }

                /// AddonGenerateOffer.AsAddonOffer.Quote.AddonOffer.AsAddonOfferToggleable.Quote
                ///
                /// Parent Type: `AddonOfferQuote`
                nonisolated public struct Quote: OctopusGraphQL.SelectionSet {
                  @_spi(Unsafe) public let __data: DataDict
                  @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

                  @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { OctopusGraphQL.Objects.AddonOfferQuote }
                  @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
                    .field("__typename", String.self),
                    .fragment(AddonOfferQuoteFragment.self),
                  ] }
                  @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
                    AddonGenerateOfferMutation.Data.AddonGenerateOffer.AsAddonOffer.Quote.AddonOffer.AsAddonOfferToggleable.Quote.self,
                    AddonOfferQuoteFragment.self
                  ] }

                  /// Id of the addon.
                  public var id: OctopusGraphQL.ID { __data["id"] }
                  /// Display value of the addon. Will be shown in the select days dropdown. eg 45 days 60 days
                  public var displayTitle: String { __data["displayTitle"] }
                  /// Display description we want to show that explains addon
                  public var displayDescription: String { __data["displayDescription"] }
                  ///  Addon subtype 
                  public var subtype: String? { __data["subtype"] }
                  /// Display items of the addon.
                  /// eg 'Coverage' with a value of '45 days'
                  public var displayItems: [DisplayItem] { __data["displayItems"] }
                  /// Cost of the addon
                  public var cost: Cost { __data["cost"] }
                  /// Addon variant
                  public var addonVariant: AddonVariant { __data["addonVariant"] }

                  public struct Fragments: FragmentContainer {
                    @_spi(Unsafe) public let __data: DataDict
                    @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

                    public var addonOfferQuoteFragment: AddonOfferQuoteFragment { _toFragment() }
                  }

                  public typealias DisplayItem = AddonOfferQuoteFragment.DisplayItem

                  public typealias Cost = AddonOfferQuoteFragment.Cost

                  public typealias AddonVariant = AddonOfferQuoteFragment.AddonVariant
                }
              }
            }

            /// AddonGenerateOffer.AsAddonOffer.Quote.ActiveAddon
            ///
            /// Parent Type: `ActiveAddon`
            nonisolated public struct ActiveAddon: OctopusGraphQL.SelectionSet {
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
                AddonGenerateOfferMutation.Data.AddonGenerateOffer.AsAddonOffer.Quote.ActiveAddon.self
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

              /// AddonGenerateOffer.AsAddonOffer.Quote.ActiveAddon.Cost
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
                  AddonGenerateOfferMutation.Data.AddonGenerateOffer.AsAddonOffer.Quote.ActiveAddon.Cost.self,
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

            /// AddonGenerateOffer.AsAddonOffer.Quote.BaseQuoteCost
            ///
            /// Parent Type: `ItemCost`
            nonisolated public struct BaseQuoteCost: OctopusGraphQL.SelectionSet {
              @_spi(Unsafe) public let __data: DataDict
              @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

              @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { OctopusGraphQL.Objects.ItemCost }
              @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
                .field("__typename", String.self),
                .fragment(ItemCostFragment.self),
              ] }
              @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
                AddonGenerateOfferMutation.Data.AddonGenerateOffer.AsAddonOffer.Quote.BaseQuoteCost.self,
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

            /// AddonGenerateOffer.AsAddonOffer.Quote.ProductVariant
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
                AddonGenerateOfferMutation.Data.AddonGenerateOffer.AsAddonOffer.Quote.ProductVariant.self,
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
          }

          /// AddonGenerateOffer.AsAddonOffer.CurrentTotalCost
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
              AddonGenerateOfferMutation.Data.AddonGenerateOffer.AsAddonOffer.CurrentTotalCost.self,
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

        /// AddonGenerateOffer.AsAddonOfferDeflect
        ///
        /// Parent Type: `AddonOfferDeflect`
        nonisolated public struct AsAddonOfferDeflect: OctopusGraphQL.InlineFragment {
          @_spi(Unsafe) public let __data: DataDict
          @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

          public typealias RootEntityType = AddonGenerateOfferMutation.Data.AddonGenerateOffer
          @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { OctopusGraphQL.Objects.AddonOfferDeflect }
          @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
            .field("pageTitle", String.self),
            .field("pageDescription", String.self),
            .field("type", GraphQLEnum<OctopusGraphQL.AddonDeflectType>?.self),
          ] }
          @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
            AddonGenerateOfferMutation.Data.AddonGenerateOffer.self,
            AddonGenerateOfferMutation.Data.AddonGenerateOffer.AsAddonOfferDeflect.self
          ] }

          /// Title to show in the page.
          /// eg "You have to upgrade your tier"
          public var pageTitle: String { __data["pageTitle"] }
          /// Description to show in the page.
          public var pageDescription: String { __data["pageDescription"] }
          /// Deflect type for clients so clients know which action to take
          public var type: GraphQLEnum<OctopusGraphQL.AddonDeflectType>? { __data["type"] }
        }
      }
    }
  }

}