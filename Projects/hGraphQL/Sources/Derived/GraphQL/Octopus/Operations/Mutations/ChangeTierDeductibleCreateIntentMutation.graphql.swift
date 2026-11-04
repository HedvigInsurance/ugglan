// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI
@_spi(Execution) @_spi(Unsafe) import ApolloAPI

public extension OctopusGraphQL {
  nonisolated struct ChangeTierDeductibleCreateIntentMutation: GraphQLMutation {
    public static let operationName: String = "ChangeTierDeductibleCreateIntent"
    public static let operationDocument: ApolloAPI.OperationDocument = .init(
      definition: .init(
        #"mutation ChangeTierDeductibleCreateIntent($input: ChangeTierDeductibleCreateIntentInput!) { changeTierDeductibleCreateIntent(input: $input) { __typename intent { __typename activationDate agreementToChange { __typename ...ChangeTierDeductibleFromAgreementFragment } quotes { __typename id tierName tierLevel tierDescription deductible { __typename amount { __typename ...MoneyFragment } percentage displayText } displayItems { __typename displayTitle displaySubtitle displayValue } productVariant { __typename ...ProductVariantFragment } addons { __typename addonVariant { __typename ...AddonVariantFragment } } costBreakdown { __typename displayName displayValue isCrossed } currentTotalCost { __typename ...TotalCostFragment } newTotalCost { __typename ...TotalCostFragment } info } } userError { __typename message } deflectOutput { __typename title message } } }"#,
        fragments: [AddonVariantFragment.self, ChangeTierDeductibleFromAgreementFragment.self, InsuranceDocumentFragment.self, MoneyFragment.self, PerilFragment.self, ProductVariantFragment.self, TotalCostFragment.self]
      ))

    public var input: ChangeTierDeductibleCreateIntentInput

    public init(input: ChangeTierDeductibleCreateIntentInput) {
      self.input = input
    }

    @_spi(Unsafe) public var __variables: Variables? { ["input": input] }

    nonisolated public struct Data: OctopusGraphQL.SelectionSet {
      @_spi(Unsafe) public let __data: DataDict
      @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

      @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { OctopusGraphQL.Objects.Mutation }
      @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
        .field("changeTierDeductibleCreateIntent", ChangeTierDeductibleCreateIntent.self, arguments: ["input": .variable("input")]),
      ] }
      @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
        ChangeTierDeductibleCreateIntentMutation.Data.self
      ] }

      ///  Create change tier/deductible intent 
      public var changeTierDeductibleCreateIntent: ChangeTierDeductibleCreateIntent { __data["changeTierDeductibleCreateIntent"] }

      /// ChangeTierDeductibleCreateIntent
      ///
      /// Parent Type: `ChangeTierDeductibleCreateIntentOutput`
      nonisolated public struct ChangeTierDeductibleCreateIntent: OctopusGraphQL.SelectionSet {
        @_spi(Unsafe) public let __data: DataDict
        @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

        @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { OctopusGraphQL.Objects.ChangeTierDeductibleCreateIntentOutput }
        @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
          .field("__typename", String.self),
          .field("intent", Intent?.self),
          .field("userError", UserError?.self),
          .field("deflectOutput", DeflectOutput?.self),
        ] }
        @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
          ChangeTierDeductibleCreateIntentMutation.Data.ChangeTierDeductibleCreateIntent.self
        ] }

        ///  Success case 
        public var intent: Intent? { __data["intent"] }
        ///  Fail case 
        public var userError: UserError? { __data["userError"] }
        ///  Deflect output 
        public var deflectOutput: DeflectOutput? { __data["deflectOutput"] }

        /// ChangeTierDeductibleCreateIntent.Intent
        ///
        /// Parent Type: `ChangeTierDeductibleIntent`
        nonisolated public struct Intent: OctopusGraphQL.SelectionSet {
          @_spi(Unsafe) public let __data: DataDict
          @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

          @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { OctopusGraphQL.Objects.ChangeTierDeductibleIntent }
          @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
            .field("__typename", String.self),
            .field("activationDate", OctopusGraphQL.Date.self),
            .field("agreementToChange", AgreementToChange.self),
            .field("quotes", [Quote].self),
          ] }
          @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
            ChangeTierDeductibleCreateIntentMutation.Data.ChangeTierDeductibleCreateIntent.Intent.self
          ] }

          ///  When change is becoming active 
          public var activationDate: OctopusGraphQL.Date { __data["activationDate"] }
          ///  The agreement to change tier/deductible on 
          public var agreementToChange: AgreementToChange { __data["agreementToChange"] }
          ///  A sorted list of quotes in tier level. 
          public var quotes: [Quote] { __data["quotes"] }

          /// ChangeTierDeductibleCreateIntent.Intent.AgreementToChange
          ///
          /// Parent Type: `ChangeTierDeductibleFromAgreement`
          nonisolated public struct AgreementToChange: OctopusGraphQL.SelectionSet {
            @_spi(Unsafe) public let __data: DataDict
            @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

            @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { OctopusGraphQL.Objects.ChangeTierDeductibleFromAgreement }
            @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
              .field("__typename", String.self),
              .fragment(ChangeTierDeductibleFromAgreementFragment.self),
            ] }
            @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
              ChangeTierDeductibleCreateIntentMutation.Data.ChangeTierDeductibleCreateIntent.Intent.AgreementToChange.self,
              ChangeTierDeductibleFromAgreementFragment.self
            ] }

            ///  Base Premium 
            public var basePremium: BasePremium { __data["basePremium"] }
            ///  The deductible if any 
            public var deductible: Deductible? { __data["deductible"] }
            ///  The tier name 
            public var tierName: String? { __data["tierName"] }
            ///  The tier level 
            public var tierLevel: Int? { __data["tierLevel"] }
            /// Optional tier description, if set use that rather than productVariant->tierDescription.
            /// An empty string means the description should deliberately be left blank.
            public var tierDescription: String? { __data["tierDescription"] }
            ///  List of display items for the quote 
            public var displayItems: [DisplayItem] { __data["displayItems"] }
            ///  The terms 
            public var productVariant: ProductVariant { __data["productVariant"] }

            public struct Fragments: FragmentContainer {
              @_spi(Unsafe) public let __data: DataDict
              @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

              public var changeTierDeductibleFromAgreementFragment: ChangeTierDeductibleFromAgreementFragment { _toFragment() }
            }

            public typealias BasePremium = ChangeTierDeductibleFromAgreementFragment.BasePremium

            public typealias Deductible = ChangeTierDeductibleFromAgreementFragment.Deductible

            public typealias DisplayItem = ChangeTierDeductibleFromAgreementFragment.DisplayItem

            public typealias ProductVariant = ChangeTierDeductibleFromAgreementFragment.ProductVariant
          }

          /// ChangeTierDeductibleCreateIntent.Intent.Quote
          ///
          /// Parent Type: `ChangeTierDeductibleQuote`
          nonisolated public struct Quote: OctopusGraphQL.SelectionSet {
            @_spi(Unsafe) public let __data: DataDict
            @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

            @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { OctopusGraphQL.Objects.ChangeTierDeductibleQuote }
            @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
              .field("__typename", String.self),
              .field("id", OctopusGraphQL.ID.self),
              .field("tierName", String?.self),
              .field("tierLevel", Int?.self),
              .field("tierDescription", String?.self),
              .field("deductible", Deductible?.self),
              .field("displayItems", [DisplayItem].self),
              .field("productVariant", ProductVariant.self),
              .field("addons", [Addon].self),
              .field("costBreakdown", [CostBreakdown].self),
              .field("currentTotalCost", CurrentTotalCost.self),
              .field("newTotalCost", NewTotalCost.self),
              .field("info", String?.self),
            ] }
            @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
              ChangeTierDeductibleCreateIntentMutation.Data.ChangeTierDeductibleCreateIntent.Intent.Quote.self
            ] }

            ///  The quote id to activate when committing intent
            public var id: OctopusGraphQL.ID { __data["id"] }
            ///  The tier name, eg BASIC, STANDARD, MAX. Use this enum to group quotes to get the different deductibles for the tiers. 
            public var tierName: String? { __data["tierName"] }
            ///  The tier level, a smaller number means lower coverage. Use this to sort the tier list. 
            public var tierLevel: Int? { __data["tierLevel"] }
            /// Optional tier description, if set use that rather than productVariant->tierDescription.
            /// An empty string means the description should deliberately be left blank.
            public var tierDescription: String? { __data["tierDescription"] }
            ///  The deductible if any 
            public var deductible: Deductible? { __data["deductible"] }
            ///  List of display items for the quote 
            public var displayItems: [DisplayItem] { __data["displayItems"] }
            ///  The terms 
            public var productVariant: ProductVariant { __data["productVariant"] }
            ///  Changed prices for existing addons 
            public var addons: [Addon] { __data["addons"] }
            /// The new price breakdown:
            /// insurance base premium, addons premiums, campaigns and bundle discounts
            public var costBreakdown: [CostBreakdown] { __data["costBreakdown"] }
            ///  Previous total cost including addons 
            public var currentTotalCost: CurrentTotalCost { __data["currentTotalCost"] }
            ///  New total cost including addons 
            public var newTotalCost: NewTotalCost { __data["newTotalCost"] }
            /// Info message we want to show for selected quote
            public var info: String? { __data["info"] }

            /// ChangeTierDeductibleCreateIntent.Intent.Quote.Deductible
            ///
            /// Parent Type: `Deductible`
            nonisolated public struct Deductible: OctopusGraphQL.SelectionSet {
              @_spi(Unsafe) public let __data: DataDict
              @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

              @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { OctopusGraphQL.Objects.Deductible }
              @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
                .field("__typename", String.self),
                .field("amount", Amount.self),
                .field("percentage", Int.self),
                .field("displayText", String.self),
              ] }
              @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
                ChangeTierDeductibleCreateIntentMutation.Data.ChangeTierDeductibleCreateIntent.Intent.Quote.Deductible.self
              ] }

              ///  The fixed deductible amount if any 
              public var amount: Amount { __data["amount"] }
              ///  The deductible percentage if any 
              public var percentage: Int { __data["percentage"] }
              ///  The deductible display sub title 
              public var displayText: String { __data["displayText"] }

              /// ChangeTierDeductibleCreateIntent.Intent.Quote.Deductible.Amount
              ///
              /// Parent Type: `Money`
              nonisolated public struct Amount: OctopusGraphQL.SelectionSet {
                @_spi(Unsafe) public let __data: DataDict
                @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

                @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { OctopusGraphQL.Objects.Money }
                @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
                  .field("__typename", String.self),
                  .fragment(MoneyFragment.self),
                ] }
                @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
                  ChangeTierDeductibleCreateIntentMutation.Data.ChangeTierDeductibleCreateIntent.Intent.Quote.Deductible.Amount.self,
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

            /// ChangeTierDeductibleCreateIntent.Intent.Quote.DisplayItem
            ///
            /// Parent Type: `ChangeTierDeductibleDisplayItem`
            nonisolated public struct DisplayItem: OctopusGraphQL.SelectionSet {
              @_spi(Unsafe) public let __data: DataDict
              @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

              @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { OctopusGraphQL.Objects.ChangeTierDeductibleDisplayItem }
              @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
                .field("__typename", String.self),
                .field("displayTitle", String.self),
                .field("displaySubtitle", String?.self),
                .field("displayValue", String.self),
              ] }
              @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
                ChangeTierDeductibleCreateIntentMutation.Data.ChangeTierDeductibleCreateIntent.Intent.Quote.DisplayItem.self
              ] }

              public var displayTitle: String { __data["displayTitle"] }
              public var displaySubtitle: String? { __data["displaySubtitle"] }
              public var displayValue: String { __data["displayValue"] }
            }

            /// ChangeTierDeductibleCreateIntent.Intent.Quote.ProductVariant
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
                ChangeTierDeductibleCreateIntentMutation.Data.ChangeTierDeductibleCreateIntent.Intent.Quote.ProductVariant.self,
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

            /// ChangeTierDeductibleCreateIntent.Intent.Quote.Addon
            ///
            /// Parent Type: `ChangeTierDeductibleAddonQuote`
            nonisolated public struct Addon: OctopusGraphQL.SelectionSet {
              @_spi(Unsafe) public let __data: DataDict
              @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

              @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { OctopusGraphQL.Objects.ChangeTierDeductibleAddonQuote }
              @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
                .field("__typename", String.self),
                .field("addonVariant", AddonVariant.self),
              ] }
              @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
                ChangeTierDeductibleCreateIntentMutation.Data.ChangeTierDeductibleCreateIntent.Intent.Quote.Addon.self
              ] }

              /// The terms
              public var addonVariant: AddonVariant { __data["addonVariant"] }

              /// ChangeTierDeductibleCreateIntent.Intent.Quote.Addon.AddonVariant
              ///
              /// Parent Type: `AddonVariant`
              nonisolated public struct AddonVariant: OctopusGraphQL.SelectionSet {
                @_spi(Unsafe) public let __data: DataDict
                @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

                @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { OctopusGraphQL.Objects.AddonVariant }
                @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
                  .field("__typename", String.self),
                  .fragment(AddonVariantFragment.self),
                ] }
                @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
                  ChangeTierDeductibleCreateIntentMutation.Data.ChangeTierDeductibleCreateIntent.Intent.Quote.Addon.AddonVariant.self,
                  AddonVariantFragment.self
                ] }

                /// A `AddonVariant` is identified by its terms version, which is the more technical
                /// name for a unique incarnation of our addons at a point in time.
                public var termsVersion: OctopusGraphQL.ID { __data["termsVersion"] }
                public var product: String { __data["product"] }
                public var addonPerils: [AddonPeril] { __data["addonPerils"] }
                public var documents: [Document] { __data["documents"] }
                public var displayName: String { __data["displayName"] }

                public struct Fragments: FragmentContainer {
                  @_spi(Unsafe) public let __data: DataDict
                  @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

                  public var addonVariantFragment: AddonVariantFragment { _toFragment() }
                }

                public typealias AddonPeril = AddonVariantFragment.AddonPeril

                public typealias Document = AddonVariantFragment.Document
              }
            }

            /// ChangeTierDeductibleCreateIntent.Intent.Quote.CostBreakdown
            ///
            /// Parent Type: `ChangeTierPriceDetailItem`
            nonisolated public struct CostBreakdown: OctopusGraphQL.SelectionSet {
              @_spi(Unsafe) public let __data: DataDict
              @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

              @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { OctopusGraphQL.Objects.ChangeTierPriceDetailItem }
              @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
                .field("__typename", String.self),
                .field("displayName", String.self),
                .field("displayValue", String.self),
                .field("isCrossed", Bool.self),
              ] }
              @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
                ChangeTierDeductibleCreateIntentMutation.Data.ChangeTierDeductibleCreateIntent.Intent.Quote.CostBreakdown.self
              ] }

              public var displayName: String { __data["displayName"] }
              public var displayValue: String { __data["displayValue"] }
              public var isCrossed: Bool { __data["isCrossed"] }
            }

            /// ChangeTierDeductibleCreateIntent.Intent.Quote.CurrentTotalCost
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
                ChangeTierDeductibleCreateIntentMutation.Data.ChangeTierDeductibleCreateIntent.Intent.Quote.CurrentTotalCost.self,
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

            /// ChangeTierDeductibleCreateIntent.Intent.Quote.NewTotalCost
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
                ChangeTierDeductibleCreateIntentMutation.Data.ChangeTierDeductibleCreateIntent.Intent.Quote.NewTotalCost.self,
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
          }
        }

        /// ChangeTierDeductibleCreateIntent.UserError
        ///
        /// Parent Type: `UserError`
        nonisolated public struct UserError: OctopusGraphQL.SelectionSet {
          @_spi(Unsafe) public let __data: DataDict
          @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

          @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { OctopusGraphQL.Objects.UserError }
          @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
            .field("__typename", String.self),
            .field("message", String.self),
          ] }
          @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
            ChangeTierDeductibleCreateIntentMutation.Data.ChangeTierDeductibleCreateIntent.UserError.self
          ] }

          public var message: String { __data["message"] }
        }

        /// ChangeTierDeductibleCreateIntent.DeflectOutput
        ///
        /// Parent Type: `ChangeTierDeflectOutput`
        nonisolated public struct DeflectOutput: OctopusGraphQL.SelectionSet {
          @_spi(Unsafe) public let __data: DataDict
          @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

          @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { OctopusGraphQL.Objects.ChangeTierDeflectOutput }
          @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
            .field("__typename", String.self),
            .field("title", String.self),
            .field("message", String.self),
          ] }
          @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
            ChangeTierDeductibleCreateIntentMutation.Data.ChangeTierDeductibleCreateIntent.DeflectOutput.self
          ] }

          public var title: String { __data["title"] }
          public var message: String { __data["message"] }
        }
      }
    }
  }

}