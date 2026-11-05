// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI
@_spi(Execution) @_spi(Unsafe) import ApolloAPI

public extension OctopusGraphQL {
  nonisolated struct ContractAddonFragment: OctopusGraphQL.SelectionSet, Fragment {
    public static var fragmentDefinition: StaticString {
      #"fragment ContractAddonFragment on ContractAddon { __typename addonVariant { __typename ...AddonVariantFragment } displayName description isRemovable isUpgradable startDate endDate }"#
    }

    @_spi(Unsafe) public let __data: DataDict
    @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

    @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { OctopusGraphQL.Objects.ContractAddon }
    @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
      .field("__typename", String.self),
      .field("addonVariant", AddonVariant.self),
      .field("displayName", String.self),
      .field("description", String.self),
      .field("isRemovable", Bool.self),
      .field("isUpgradable", Bool.self),
      .field("startDate", OctopusGraphQL.Date?.self),
      .field("endDate", OctopusGraphQL.Date?.self),
    ] }
    @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
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

    /// AddonVariant
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
        ContractAddonFragment.AddonVariant.self,
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

}