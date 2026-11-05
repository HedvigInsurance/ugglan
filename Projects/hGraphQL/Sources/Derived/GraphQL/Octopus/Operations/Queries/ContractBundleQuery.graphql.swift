// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI
@_spi(Execution) @_spi(Unsafe) import ApolloAPI

public extension OctopusGraphQL {
  nonisolated struct ContractBundleQuery: GraphQLQuery {
    public static let operationName: String = "ContractBundle"
    public static let operationDocument: ApolloAPI.OperationDocument = .init(
      definition: .init(
        #"query ContractBundle($options: DisplayItemOptions) { currentMember { __typename firstName lastName ssn activeContracts { __typename ...ContractFragment currentAgreement { __typename itemCost { __typename ...ItemCostFragment } addons { __typename ...AddonPriceFragment } displayItems(options: $options) { __typename ...AgreementDisplayItemFragment } } upcomingChangedAgreement { __typename itemCost { __typename ...ItemCostFragment } addons { __typename ...AddonPriceFragment } displayItems(options: $options) { __typename ...AgreementDisplayItemFragment } } existingAddons { __typename ...ContractAddonFragment } availableAddons { __typename ...AvailableAddonFragment } } pendingContracts { __typename displayItems(options: $options) { __typename ...AgreementDisplayItemFragment } exposureDisplayName exposureDisplayNameShort id supportsTermination basePremium { __typename ...MoneyFragment } productVariant { __typename ...ProductVariantFragment } addons { __typename addonVariant { __typename ...AddonVariantFragment } ...AddonPriceFragment } itemCost { __typename ...ItemCostFragment } existingAddons { __typename ...ContractAddonFragment } availableAddons { __typename ...AvailableAddonFragment } } terminatedContracts { __typename ...ContractFragment currentAgreement { __typename displayItems(options: $options) { __typename ...AgreementDisplayItemFragment } } } } }"#,
        fragments: [AddonPriceFragment.self, AddonVariantFragment.self, AgreementDisplayItemFragment.self, AgreementFragment.self, AvailableAddonFragment.self, CoInsuredFragment.self, CoOwnerFragment.self, ContractAddonFragment.self, ContractFragment.self, InsuranceDocumentFragment.self, ItemCostFragment.self, ItemDiscountFragment.self, MoneyFragment.self, PerilFragment.self, ProductVariantFragment.self]
      ))

    public var options: GraphQLNullable<DisplayItemOptions>

    public init(options: GraphQLNullable<DisplayItemOptions>) {
      self.options = options
    }

    @_spi(Unsafe) public var __variables: Variables? { ["options": options] }

    nonisolated public struct Data: OctopusGraphQL.SelectionSet {
      @_spi(Unsafe) public let __data: DataDict
      @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

      @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { OctopusGraphQL.Objects.Query }
      @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
        .field("currentMember", CurrentMember.self),
      ] }
      @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
        ContractBundleQuery.Data.self
      ] }

      /// Gets the currently authenticated member. This is the only valid way to query a `Member` type, and it is based
      /// on the input Authorization header.
      public var currentMember: CurrentMember { __data["currentMember"] }

      /// CurrentMember
      ///
      /// Parent Type: `Member`
      nonisolated public struct CurrentMember: OctopusGraphQL.SelectionSet {
        @_spi(Unsafe) public let __data: DataDict
        @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

        @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { OctopusGraphQL.Objects.Member }
        @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
          .field("__typename", String.self),
          .field("firstName", String.self),
          .field("lastName", String.self),
          .field("ssn", String?.self),
          .field("activeContracts", [ActiveContract].self),
          .field("pendingContracts", [PendingContract].self),
          .field("terminatedContracts", [TerminatedContract].self),
        ] }
        @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
          ContractBundleQuery.Data.CurrentMember.self
        ] }

        public var firstName: String { __data["firstName"] }
        public var lastName: String { __data["lastName"] }
        public var ssn: String? { __data["ssn"] }
        /// Fetch all the active contracts for this member. Active contracts include all insurances that are either
        /// active today, or to-be-active in the future.
        public var activeContracts: [ActiveContract] { __data["activeContracts"] }
        /// Fetch all the pending contracts for this member.
        public var pendingContracts: [PendingContract] { __data["pendingContracts"] }
        /// Terminated contracts are all past contracts that have ended.
        public var terminatedContracts: [TerminatedContract] { __data["terminatedContracts"] }

        /// CurrentMember.ActiveContract
        ///
        /// Parent Type: `Contract`
        nonisolated public struct ActiveContract: OctopusGraphQL.SelectionSet {
          @_spi(Unsafe) public let __data: DataDict
          @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

          @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { OctopusGraphQL.Objects.Contract }
          @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
            .field("__typename", String.self),
            .field("currentAgreement", CurrentAgreement.self),
            .field("upcomingChangedAgreement", UpcomingChangedAgreement?.self),
            .field("existingAddons", [ExistingAddon].self),
            .field("availableAddons", [AvailableAddon].self),
            .fragment(ContractFragment.self),
          ] }
          @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
            ContractBundleQuery.Data.CurrentMember.ActiveContract.self,
            ContractFragment.self
          ] }

          /// The currently active/relevant agreement for this contract.
          public var currentAgreement: CurrentAgreement { __data["currentAgreement"] }
          /// A possible upcoming change of agreement. If there are multiple upcoming changes, this one will return
          /// the first.
          public var upcomingChangedAgreement: UpcomingChangedAgreement? { __data["upcomingChangedAgreement"] }
          /// List of available addons for the contract.
          public var existingAddons: [ExistingAddon] { __data["existingAddons"] }
          /// List of available addons for the contract.
          public var availableAddons: [AvailableAddon] { __data["availableAddons"] }
          /// Current state of co-insured including upcoming changes.
          /// If current agreement doesn't support co-insured, this is null
          public var coInsured: [CoInsured]? { __data["coInsured"] }
          /// Current state of co-owners including upcoming changes.
          /// If current agreement doesn't support co-owners, this is null
          /// Reuses ContractCoInsured type, for now.
          public var coOwners: [CoOwner]? { __data["coOwners"] }
          /// The display name of the "exposure" of this insurance - i.e. the 'object' being insured. This could be
          /// the address of an apartment + number of co insured,
          /// or the person having accident insurance,
          /// or the dog being insured + breed
          /// or car registration number + model etc.
          public var exposureDisplayName: String { __data["exposureDisplayName"] }
          /// The display name of the "exposure" of this insurance - i.e. the 'object' being insured. This could be
          /// the address of an apartment
          /// or the person having accident insurance,
          /// or the dog being insured
          /// or car registration number etc
          public var exposureDisplayNameShort: String { __data["exposureDisplayNameShort"] }
          public var id: OctopusGraphQL.UUID { __data["id"] }
          /// The first date this insurance became active - i.e. the "from date" of the first agreement.
          public var masterInceptionDate: OctopusGraphQL.Date { __data["masterInceptionDate"] }
          /// Whether or not this contract can be changes through the 'MoveIntent' API.
          public var supportsMoving: Bool { __data["supportsMoving"] }
          /// Whether or not this co-insured for contract can be changed through the 'MidtermChange' API.
          public var supportsCoInsured: Bool { __data["supportsCoInsured"] }
          /// Whether or not this co-insured for contract can be changed through the 'MidtermChange' API.
          public var supportsCoOwners: Bool { __data["supportsCoOwners"] }
          /// Whether or not travel certificate can be created for the contract
          public var supportsTravelCertificate: Bool { __data["supportsTravelCertificate"] }
          /// Whether or not this contract can be changed through the 'ChangeTier' API.
          public var supportsChangeTier: Bool { __data["supportsChangeTier"] }
          /// Whether or not this contract can be terminated by user
          public var supportsTermination: Bool { __data["supportsTermination"] }
          /// The last date this insurance will be active, if there is one.
          public var terminationDate: OctopusGraphQL.Date? { __data["terminationDate"] }
          /// Checks if petId is missing on the current or upcoming agreement.
          public var isMissingPetId: Bool { __data["isMissingPetId"] }

          public struct Fragments: FragmentContainer {
            @_spi(Unsafe) public let __data: DataDict
            @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

            public var contractFragment: ContractFragment { _toFragment() }
          }

          /// CurrentMember.ActiveContract.CurrentAgreement
          ///
          /// Parent Type: `Agreement`
          nonisolated public struct CurrentAgreement: OctopusGraphQL.SelectionSet {
            @_spi(Unsafe) public let __data: DataDict
            @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

            @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { OctopusGraphQL.Objects.Agreement }
            @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
              .field("__typename", String.self),
              .field("itemCost", ItemCost?.self),
              .field("addons", [Addon].self),
              .field("displayItems", [DisplayItem].self, arguments: ["options": .variable("options")]),
            ] }
            @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
              ContractBundleQuery.Data.CurrentMember.ActiveContract.CurrentAgreement.self,
              ContractFragment.CurrentAgreement.self,
              AgreementFragment.self
            ] }

            /// The cost details of this agreement on today's date or the date it starts
            public var itemCost: ItemCost? { __data["itemCost"] }
            /// List of addons on the agreement.
            public var addons: [Addon] { __data["addons"] }
            /// A localized list of key/value pairs the define the properties of this insurance.
            public var displayItems: [DisplayItem] { __data["displayItems"] }
            public var id: OctopusGraphQL.ID { __data["id"] }
            /// The date this agreement took effect.
            public var activeFrom: OctopusGraphQL.Date { __data["activeFrom"] }
            /// The last date this is in effect.
            public var activeTo: OctopusGraphQL.Date { __data["activeTo"] }
            /// The URL of the insurance certificate.
            public var certificateUrl: OctopusGraphQL.Url? { __data["certificateUrl"] }
            /// The reason this agreement was created, useful to distinguish between renewals and other creations for instance.
            public var creationCause: GraphQLEnum<OctopusGraphQL.AgreementCreationCause> { __data["creationCause"] }
            /// The monthly premium of this agreement.
            public var basePremium: BasePremium { __data["basePremium"] }
            /// The ProductVariant of the agreement, which is the umbrella container for a lot of data related to the insurance,
            /// such as names, legal documents, perils etc.
            public var productVariant: ProductVariant { __data["productVariant"] }

            public struct Fragments: FragmentContainer {
              @_spi(Unsafe) public let __data: DataDict
              @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

              public var agreementFragment: AgreementFragment { _toFragment() }
            }

            /// CurrentMember.ActiveContract.CurrentAgreement.ItemCost
            ///
            /// Parent Type: `ItemCost`
            nonisolated public struct ItemCost: OctopusGraphQL.SelectionSet {
              @_spi(Unsafe) public let __data: DataDict
              @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

              @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { OctopusGraphQL.Objects.ItemCost }
              @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
                .field("__typename", String.self),
                .fragment(ItemCostFragment.self),
              ] }
              @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
                ContractBundleQuery.Data.CurrentMember.ActiveContract.CurrentAgreement.ItemCost.self,
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

            /// CurrentMember.ActiveContract.CurrentAgreement.Addon
            ///
            /// Parent Type: `Addon`
            nonisolated public struct Addon: OctopusGraphQL.SelectionSet {
              @_spi(Unsafe) public let __data: DataDict
              @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

              @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { OctopusGraphQL.Objects.Addon }
              @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
                .field("__typename", String.self),
                .fragment(AddonPriceFragment.self),
              ] }
              @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
                ContractBundleQuery.Data.CurrentMember.ActiveContract.CurrentAgreement.Addon.self,
                AddonPriceFragment.self,
                AgreementFragment.Addon.self
              ] }

              /// Premium of the addon.
              public var premium: Premium { __data["premium"] }
              /// The AddonVariant of the agreement, which is the umbrella container for a lot of data related to the addon,
              /// such as names, legal documents, perils etc.
              public var addonVariant: AddonVariant { __data["addonVariant"] }

              public struct Fragments: FragmentContainer {
                @_spi(Unsafe) public let __data: DataDict
                @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

                public var addonPriceFragment: AddonPriceFragment { _toFragment() }
              }

              public typealias Premium = AddonPriceFragment.Premium

              public typealias AddonVariant = AgreementFragment.Addon.AddonVariant
            }

            /// CurrentMember.ActiveContract.CurrentAgreement.DisplayItem
            ///
            /// Parent Type: `AgreementDisplayItem`
            nonisolated public struct DisplayItem: OctopusGraphQL.SelectionSet {
              @_spi(Unsafe) public let __data: DataDict
              @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

              @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { OctopusGraphQL.Objects.AgreementDisplayItem }
              @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
                .field("__typename", String.self),
                .fragment(AgreementDisplayItemFragment.self),
              ] }
              @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
                ContractBundleQuery.Data.CurrentMember.ActiveContract.CurrentAgreement.DisplayItem.self,
                AgreementDisplayItemFragment.self
              ] }

              public var displayTitle: String { __data["displayTitle"] }
              public var displayValue: String { __data["displayValue"] }
              public var displaySubtitle: String? { __data["displaySubtitle"] }

              public struct Fragments: FragmentContainer {
                @_spi(Unsafe) public let __data: DataDict
                @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

                public var agreementDisplayItemFragment: AgreementDisplayItemFragment { _toFragment() }
              }
            }

            public typealias BasePremium = AgreementFragment.BasePremium

            public typealias ProductVariant = AgreementFragment.ProductVariant
          }

          /// CurrentMember.ActiveContract.UpcomingChangedAgreement
          ///
          /// Parent Type: `Agreement`
          nonisolated public struct UpcomingChangedAgreement: OctopusGraphQL.SelectionSet {
            @_spi(Unsafe) public let __data: DataDict
            @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

            @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { OctopusGraphQL.Objects.Agreement }
            @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
              .field("__typename", String.self),
              .field("itemCost", ItemCost?.self),
              .field("addons", [Addon].self),
              .field("displayItems", [DisplayItem].self, arguments: ["options": .variable("options")]),
            ] }
            @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
              ContractBundleQuery.Data.CurrentMember.ActiveContract.UpcomingChangedAgreement.self,
              ContractFragment.UpcomingChangedAgreement.self,
              AgreementFragment.self
            ] }

            /// The cost details of this agreement on today's date or the date it starts
            public var itemCost: ItemCost? { __data["itemCost"] }
            /// List of addons on the agreement.
            public var addons: [Addon] { __data["addons"] }
            /// A localized list of key/value pairs the define the properties of this insurance.
            public var displayItems: [DisplayItem] { __data["displayItems"] }
            public var id: OctopusGraphQL.ID { __data["id"] }
            /// The date this agreement took effect.
            public var activeFrom: OctopusGraphQL.Date { __data["activeFrom"] }
            /// The last date this is in effect.
            public var activeTo: OctopusGraphQL.Date { __data["activeTo"] }
            /// The URL of the insurance certificate.
            public var certificateUrl: OctopusGraphQL.Url? { __data["certificateUrl"] }
            /// The reason this agreement was created, useful to distinguish between renewals and other creations for instance.
            public var creationCause: GraphQLEnum<OctopusGraphQL.AgreementCreationCause> { __data["creationCause"] }
            /// The monthly premium of this agreement.
            public var basePremium: BasePremium { __data["basePremium"] }
            /// The ProductVariant of the agreement, which is the umbrella container for a lot of data related to the insurance,
            /// such as names, legal documents, perils etc.
            public var productVariant: ProductVariant { __data["productVariant"] }

            public struct Fragments: FragmentContainer {
              @_spi(Unsafe) public let __data: DataDict
              @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

              public var agreementFragment: AgreementFragment { _toFragment() }
            }

            /// CurrentMember.ActiveContract.UpcomingChangedAgreement.ItemCost
            ///
            /// Parent Type: `ItemCost`
            nonisolated public struct ItemCost: OctopusGraphQL.SelectionSet {
              @_spi(Unsafe) public let __data: DataDict
              @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

              @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { OctopusGraphQL.Objects.ItemCost }
              @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
                .field("__typename", String.self),
                .fragment(ItemCostFragment.self),
              ] }
              @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
                ContractBundleQuery.Data.CurrentMember.ActiveContract.UpcomingChangedAgreement.ItemCost.self,
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

            /// CurrentMember.ActiveContract.UpcomingChangedAgreement.Addon
            ///
            /// Parent Type: `Addon`
            nonisolated public struct Addon: OctopusGraphQL.SelectionSet {
              @_spi(Unsafe) public let __data: DataDict
              @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

              @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { OctopusGraphQL.Objects.Addon }
              @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
                .field("__typename", String.self),
                .fragment(AddonPriceFragment.self),
              ] }
              @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
                ContractBundleQuery.Data.CurrentMember.ActiveContract.UpcomingChangedAgreement.Addon.self,
                AddonPriceFragment.self,
                AgreementFragment.Addon.self
              ] }

              /// Premium of the addon.
              public var premium: Premium { __data["premium"] }
              /// The AddonVariant of the agreement, which is the umbrella container for a lot of data related to the addon,
              /// such as names, legal documents, perils etc.
              public var addonVariant: AddonVariant { __data["addonVariant"] }

              public struct Fragments: FragmentContainer {
                @_spi(Unsafe) public let __data: DataDict
                @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

                public var addonPriceFragment: AddonPriceFragment { _toFragment() }
              }

              public typealias Premium = AddonPriceFragment.Premium

              public typealias AddonVariant = AgreementFragment.Addon.AddonVariant
            }

            /// CurrentMember.ActiveContract.UpcomingChangedAgreement.DisplayItem
            ///
            /// Parent Type: `AgreementDisplayItem`
            nonisolated public struct DisplayItem: OctopusGraphQL.SelectionSet {
              @_spi(Unsafe) public let __data: DataDict
              @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

              @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { OctopusGraphQL.Objects.AgreementDisplayItem }
              @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
                .field("__typename", String.self),
                .fragment(AgreementDisplayItemFragment.self),
              ] }
              @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
                ContractBundleQuery.Data.CurrentMember.ActiveContract.UpcomingChangedAgreement.DisplayItem.self,
                AgreementDisplayItemFragment.self
              ] }

              public var displayTitle: String { __data["displayTitle"] }
              public var displayValue: String { __data["displayValue"] }
              public var displaySubtitle: String? { __data["displaySubtitle"] }

              public struct Fragments: FragmentContainer {
                @_spi(Unsafe) public let __data: DataDict
                @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

                public var agreementDisplayItemFragment: AgreementDisplayItemFragment { _toFragment() }
              }
            }

            public typealias BasePremium = AgreementFragment.BasePremium

            public typealias ProductVariant = AgreementFragment.ProductVariant
          }

          /// CurrentMember.ActiveContract.ExistingAddon
          ///
          /// Parent Type: `ContractAddon`
          nonisolated public struct ExistingAddon: OctopusGraphQL.SelectionSet {
            @_spi(Unsafe) public let __data: DataDict
            @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

            @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { OctopusGraphQL.Objects.ContractAddon }
            @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
              .field("__typename", String.self),
              .fragment(ContractAddonFragment.self),
            ] }
            @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
              ContractBundleQuery.Data.CurrentMember.ActiveContract.ExistingAddon.self,
              ContractAddonFragment.self
            ] }

            /// The AddonVariant of the agreement, which is the umbrella container for a lot of data related to the addon,
            /// such as names, legal documents, perils etc.
            public var addonVariant: AddonVariant { __data["addonVariant"] }
            /// Display name of the addon.
            public var displayName: String { __data["displayName"] }
            /// Description of the addon.
            public var description: String { __data["description"] }
            /// If the addon is currently removable.
            public var isRemovable: Bool { __data["isRemovable"] }
            /// If the addon is currently upgradeable.
            public var isUpgradable: Bool { __data["isUpgradable"] }
            /// Start date, null if pending
            public var startDate: OctopusGraphQL.Date? { __data["startDate"] }
            /// End date, null if open-ended
            public var endDate: OctopusGraphQL.Date? { __data["endDate"] }

            public struct Fragments: FragmentContainer {
              @_spi(Unsafe) public let __data: DataDict
              @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

              public var contractAddonFragment: ContractAddonFragment { _toFragment() }
            }

            public typealias AddonVariant = ContractAddonFragment.AddonVariant
          }

          /// CurrentMember.ActiveContract.AvailableAddon
          ///
          /// Parent Type: `AvailableAddon`
          nonisolated public struct AvailableAddon: OctopusGraphQL.SelectionSet {
            @_spi(Unsafe) public let __data: DataDict
            @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

            @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { OctopusGraphQL.Objects.AvailableAddon }
            @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
              .field("__typename", String.self),
              .fragment(AvailableAddonFragment.self),
            ] }
            @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
              ContractBundleQuery.Data.CurrentMember.ActiveContract.AvailableAddon.self,
              AvailableAddonFragment.self
            ] }

            /// Display name of the addon.
            public var displayName: String { __data["displayName"] }
            /// Description of the addon.
            public var description: String { __data["description"] }

            public struct Fragments: FragmentContainer {
              @_spi(Unsafe) public let __data: DataDict
              @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

              public var availableAddonFragment: AvailableAddonFragment { _toFragment() }
            }
          }

          public typealias CoInsured = ContractFragment.CoInsured

          public typealias CoOwner = ContractFragment.CoOwner
        }

        /// CurrentMember.PendingContract
        ///
        /// Parent Type: `PendingContract`
        nonisolated public struct PendingContract: OctopusGraphQL.SelectionSet {
          @_spi(Unsafe) public let __data: DataDict
          @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

          @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { OctopusGraphQL.Objects.PendingContract }
          @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
            .field("__typename", String.self),
            .field("displayItems", [DisplayItem].self, arguments: ["options": .variable("options")]),
            .field("exposureDisplayName", String.self),
            .field("exposureDisplayNameShort", String.self),
            .field("id", OctopusGraphQL.UUID.self),
            .field("supportsTermination", Bool.self),
            .field("basePremium", BasePremium.self),
            .field("productVariant", ProductVariant.self),
            .field("addons", [Addon].self),
            .field("itemCost", ItemCost?.self),
            .field("existingAddons", [ExistingAddon].self),
            .field("availableAddons", [AvailableAddon].self),
          ] }
          @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
            ContractBundleQuery.Data.CurrentMember.PendingContract.self
          ] }

          /// Same as `Contract.currentAgreement.displayItems`.
          public var displayItems: [DisplayItem] { __data["displayItems"] }
          /// Same as `Contract.exposureDisplayName`.
          public var exposureDisplayName: String { __data["exposureDisplayName"] }
          /// Same as `Contract.exposureDisplayNameShort`.
          public var exposureDisplayNameShort: String { __data["exposureDisplayNameShort"] }
          public var id: OctopusGraphQL.UUID { __data["id"] }
          /// Whether or not this contract can be terminated by user
          public var supportsTermination: Bool { __data["supportsTermination"] }
          /// Same as `Contract.currentAgreement.basePremium`.
          public var basePremium: BasePremium { __data["basePremium"] }
          /// Same as `Contract.currentAgreement.productVariant`.
          public var productVariant: ProductVariant { __data["productVariant"] }
          /// List of addons on the agreement.
          public var addons: [Addon] { __data["addons"] }
          /// Calculated based on the pending agreement
          public var itemCost: ItemCost? { __data["itemCost"] }
          /// List of available addons for the contract.
          public var existingAddons: [ExistingAddon] { __data["existingAddons"] }
          /// List of available addons for the contract.
          public var availableAddons: [AvailableAddon] { __data["availableAddons"] }

          /// CurrentMember.PendingContract.DisplayItem
          ///
          /// Parent Type: `AgreementDisplayItem`
          nonisolated public struct DisplayItem: OctopusGraphQL.SelectionSet {
            @_spi(Unsafe) public let __data: DataDict
            @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

            @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { OctopusGraphQL.Objects.AgreementDisplayItem }
            @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
              .field("__typename", String.self),
              .fragment(AgreementDisplayItemFragment.self),
            ] }
            @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
              ContractBundleQuery.Data.CurrentMember.PendingContract.DisplayItem.self,
              AgreementDisplayItemFragment.self
            ] }

            public var displayTitle: String { __data["displayTitle"] }
            public var displayValue: String { __data["displayValue"] }
            public var displaySubtitle: String? { __data["displaySubtitle"] }

            public struct Fragments: FragmentContainer {
              @_spi(Unsafe) public let __data: DataDict
              @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

              public var agreementDisplayItemFragment: AgreementDisplayItemFragment { _toFragment() }
            }
          }

          /// CurrentMember.PendingContract.BasePremium
          ///
          /// Parent Type: `Money`
          nonisolated public struct BasePremium: OctopusGraphQL.SelectionSet {
            @_spi(Unsafe) public let __data: DataDict
            @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

            @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { OctopusGraphQL.Objects.Money }
            @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
              .field("__typename", String.self),
              .fragment(MoneyFragment.self),
            ] }
            @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
              ContractBundleQuery.Data.CurrentMember.PendingContract.BasePremium.self,
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

          /// CurrentMember.PendingContract.ProductVariant
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
              ContractBundleQuery.Data.CurrentMember.PendingContract.ProductVariant.self,
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

          /// CurrentMember.PendingContract.Addon
          ///
          /// Parent Type: `Addon`
          nonisolated public struct Addon: OctopusGraphQL.SelectionSet {
            @_spi(Unsafe) public let __data: DataDict
            @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

            @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { OctopusGraphQL.Objects.Addon }
            @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
              .field("__typename", String.self),
              .field("addonVariant", AddonVariant.self),
              .fragment(AddonPriceFragment.self),
            ] }
            @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
              ContractBundleQuery.Data.CurrentMember.PendingContract.Addon.self,
              AddonPriceFragment.self
            ] }

            /// The AddonVariant of the agreement, which is the umbrella container for a lot of data related to the addon,
            /// such as names, legal documents, perils etc.
            public var addonVariant: AddonVariant { __data["addonVariant"] }
            /// Premium of the addon.
            public var premium: Premium { __data["premium"] }

            public struct Fragments: FragmentContainer {
              @_spi(Unsafe) public let __data: DataDict
              @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

              public var addonPriceFragment: AddonPriceFragment { _toFragment() }
            }

            /// CurrentMember.PendingContract.Addon.AddonVariant
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
                ContractBundleQuery.Data.CurrentMember.PendingContract.Addon.AddonVariant.self,
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

            public typealias Premium = AddonPriceFragment.Premium
          }

          /// CurrentMember.PendingContract.ItemCost
          ///
          /// Parent Type: `ItemCost`
          nonisolated public struct ItemCost: OctopusGraphQL.SelectionSet {
            @_spi(Unsafe) public let __data: DataDict
            @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

            @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { OctopusGraphQL.Objects.ItemCost }
            @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
              .field("__typename", String.self),
              .fragment(ItemCostFragment.self),
            ] }
            @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
              ContractBundleQuery.Data.CurrentMember.PendingContract.ItemCost.self,
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

          /// CurrentMember.PendingContract.ExistingAddon
          ///
          /// Parent Type: `ContractAddon`
          nonisolated public struct ExistingAddon: OctopusGraphQL.SelectionSet {
            @_spi(Unsafe) public let __data: DataDict
            @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

            @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { OctopusGraphQL.Objects.ContractAddon }
            @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
              .field("__typename", String.self),
              .fragment(ContractAddonFragment.self),
            ] }
            @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
              ContractBundleQuery.Data.CurrentMember.PendingContract.ExistingAddon.self,
              ContractAddonFragment.self
            ] }

            /// The AddonVariant of the agreement, which is the umbrella container for a lot of data related to the addon,
            /// such as names, legal documents, perils etc.
            public var addonVariant: AddonVariant { __data["addonVariant"] }
            /// Display name of the addon.
            public var displayName: String { __data["displayName"] }
            /// Description of the addon.
            public var description: String { __data["description"] }
            /// If the addon is currently removable.
            public var isRemovable: Bool { __data["isRemovable"] }
            /// If the addon is currently upgradeable.
            public var isUpgradable: Bool { __data["isUpgradable"] }
            /// Start date, null if pending
            public var startDate: OctopusGraphQL.Date? { __data["startDate"] }
            /// End date, null if open-ended
            public var endDate: OctopusGraphQL.Date? { __data["endDate"] }

            public struct Fragments: FragmentContainer {
              @_spi(Unsafe) public let __data: DataDict
              @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

              public var contractAddonFragment: ContractAddonFragment { _toFragment() }
            }

            public typealias AddonVariant = ContractAddonFragment.AddonVariant
          }

          /// CurrentMember.PendingContract.AvailableAddon
          ///
          /// Parent Type: `AvailableAddon`
          nonisolated public struct AvailableAddon: OctopusGraphQL.SelectionSet {
            @_spi(Unsafe) public let __data: DataDict
            @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

            @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { OctopusGraphQL.Objects.AvailableAddon }
            @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
              .field("__typename", String.self),
              .fragment(AvailableAddonFragment.self),
            ] }
            @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
              ContractBundleQuery.Data.CurrentMember.PendingContract.AvailableAddon.self,
              AvailableAddonFragment.self
            ] }

            /// Display name of the addon.
            public var displayName: String { __data["displayName"] }
            /// Description of the addon.
            public var description: String { __data["description"] }

            public struct Fragments: FragmentContainer {
              @_spi(Unsafe) public let __data: DataDict
              @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

              public var availableAddonFragment: AvailableAddonFragment { _toFragment() }
            }
          }
        }

        /// CurrentMember.TerminatedContract
        ///
        /// Parent Type: `Contract`
        nonisolated public struct TerminatedContract: OctopusGraphQL.SelectionSet {
          @_spi(Unsafe) public let __data: DataDict
          @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

          @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { OctopusGraphQL.Objects.Contract }
          @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
            .field("__typename", String.self),
            .field("currentAgreement", CurrentAgreement.self),
            .fragment(ContractFragment.self),
          ] }
          @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
            ContractBundleQuery.Data.CurrentMember.TerminatedContract.self,
            ContractFragment.self
          ] }

          /// The currently active/relevant agreement for this contract.
          public var currentAgreement: CurrentAgreement { __data["currentAgreement"] }
          /// Current state of co-insured including upcoming changes.
          /// If current agreement doesn't support co-insured, this is null
          public var coInsured: [CoInsured]? { __data["coInsured"] }
          /// Current state of co-owners including upcoming changes.
          /// If current agreement doesn't support co-owners, this is null
          /// Reuses ContractCoInsured type, for now.
          public var coOwners: [CoOwner]? { __data["coOwners"] }
          /// The display name of the "exposure" of this insurance - i.e. the 'object' being insured. This could be
          /// the address of an apartment + number of co insured,
          /// or the person having accident insurance,
          /// or the dog being insured + breed
          /// or car registration number + model etc.
          public var exposureDisplayName: String { __data["exposureDisplayName"] }
          /// The display name of the "exposure" of this insurance - i.e. the 'object' being insured. This could be
          /// the address of an apartment
          /// or the person having accident insurance,
          /// or the dog being insured
          /// or car registration number etc
          public var exposureDisplayNameShort: String { __data["exposureDisplayNameShort"] }
          public var id: OctopusGraphQL.UUID { __data["id"] }
          /// The first date this insurance became active - i.e. the "from date" of the first agreement.
          public var masterInceptionDate: OctopusGraphQL.Date { __data["masterInceptionDate"] }
          /// Whether or not this contract can be changes through the 'MoveIntent' API.
          public var supportsMoving: Bool { __data["supportsMoving"] }
          /// Whether or not this co-insured for contract can be changed through the 'MidtermChange' API.
          public var supportsCoInsured: Bool { __data["supportsCoInsured"] }
          /// Whether or not this co-insured for contract can be changed through the 'MidtermChange' API.
          public var supportsCoOwners: Bool { __data["supportsCoOwners"] }
          /// Whether or not travel certificate can be created for the contract
          public var supportsTravelCertificate: Bool { __data["supportsTravelCertificate"] }
          /// Whether or not this contract can be changed through the 'ChangeTier' API.
          public var supportsChangeTier: Bool { __data["supportsChangeTier"] }
          /// Whether or not this contract can be terminated by user
          public var supportsTermination: Bool { __data["supportsTermination"] }
          /// The last date this insurance will be active, if there is one.
          public var terminationDate: OctopusGraphQL.Date? { __data["terminationDate"] }
          /// A possible upcoming change of agreement. If there are multiple upcoming changes, this one will return
          /// the first.
          public var upcomingChangedAgreement: UpcomingChangedAgreement? { __data["upcomingChangedAgreement"] }
          /// Checks if petId is missing on the current or upcoming agreement.
          public var isMissingPetId: Bool { __data["isMissingPetId"] }

          public struct Fragments: FragmentContainer {
            @_spi(Unsafe) public let __data: DataDict
            @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

            public var contractFragment: ContractFragment { _toFragment() }
          }

          /// CurrentMember.TerminatedContract.CurrentAgreement
          ///
          /// Parent Type: `Agreement`
          nonisolated public struct CurrentAgreement: OctopusGraphQL.SelectionSet {
            @_spi(Unsafe) public let __data: DataDict
            @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

            @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { OctopusGraphQL.Objects.Agreement }
            @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
              .field("__typename", String.self),
              .field("displayItems", [DisplayItem].self, arguments: ["options": .variable("options")]),
            ] }
            @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
              ContractBundleQuery.Data.CurrentMember.TerminatedContract.CurrentAgreement.self,
              ContractFragment.CurrentAgreement.self,
              AgreementFragment.self
            ] }

            /// A localized list of key/value pairs the define the properties of this insurance.
            public var displayItems: [DisplayItem] { __data["displayItems"] }
            public var id: OctopusGraphQL.ID { __data["id"] }
            /// The date this agreement took effect.
            public var activeFrom: OctopusGraphQL.Date { __data["activeFrom"] }
            /// The last date this is in effect.
            public var activeTo: OctopusGraphQL.Date { __data["activeTo"] }
            /// The URL of the insurance certificate.
            public var certificateUrl: OctopusGraphQL.Url? { __data["certificateUrl"] }
            /// The reason this agreement was created, useful to distinguish between renewals and other creations for instance.
            public var creationCause: GraphQLEnum<OctopusGraphQL.AgreementCreationCause> { __data["creationCause"] }
            /// The monthly premium of this agreement.
            public var basePremium: BasePremium { __data["basePremium"] }
            /// The ProductVariant of the agreement, which is the umbrella container for a lot of data related to the insurance,
            /// such as names, legal documents, perils etc.
            public var productVariant: ProductVariant { __data["productVariant"] }
            /// List of addons on the agreement.
            public var addons: [Addon] { __data["addons"] }

            public struct Fragments: FragmentContainer {
              @_spi(Unsafe) public let __data: DataDict
              @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

              public var agreementFragment: AgreementFragment { _toFragment() }
            }

            /// CurrentMember.TerminatedContract.CurrentAgreement.DisplayItem
            ///
            /// Parent Type: `AgreementDisplayItem`
            nonisolated public struct DisplayItem: OctopusGraphQL.SelectionSet {
              @_spi(Unsafe) public let __data: DataDict
              @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

              @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { OctopusGraphQL.Objects.AgreementDisplayItem }
              @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
                .field("__typename", String.self),
                .fragment(AgreementDisplayItemFragment.self),
              ] }
              @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
                ContractBundleQuery.Data.CurrentMember.TerminatedContract.CurrentAgreement.DisplayItem.self,
                AgreementDisplayItemFragment.self
              ] }

              public var displayTitle: String { __data["displayTitle"] }
              public var displayValue: String { __data["displayValue"] }
              public var displaySubtitle: String? { __data["displaySubtitle"] }

              public struct Fragments: FragmentContainer {
                @_spi(Unsafe) public let __data: DataDict
                @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

                public var agreementDisplayItemFragment: AgreementDisplayItemFragment { _toFragment() }
              }
            }

            public typealias BasePremium = AgreementFragment.BasePremium

            public typealias ProductVariant = AgreementFragment.ProductVariant

            public typealias Addon = AgreementFragment.Addon
          }

          public typealias CoInsured = ContractFragment.CoInsured

          public typealias CoOwner = ContractFragment.CoOwner

          public typealias UpcomingChangedAgreement = ContractFragment.UpcomingChangedAgreement
        }
      }
    }
  }

}