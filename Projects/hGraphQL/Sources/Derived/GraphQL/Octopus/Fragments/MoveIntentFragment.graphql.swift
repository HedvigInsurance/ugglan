// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI
@_spi(Execution) @_spi(Unsafe) import ApolloAPI

public extension OctopusGraphQL {
  nonisolated struct MoveIntentFragment: OctopusGraphQL.SelectionSet, Fragment {
    public static var fragmentDefinition: StaticString {
      #"fragment MoveIntentFragment on MoveIntent { __typename currentHomeAddresses { __typename ...MoveAddressFragment } extraBuildingTypesV2 { __typename displayName type } id isApartmentAvailableforStudent maxApartmentNumberCoInsured maxApartmentSquareMeters maxHouseNumberCoInsured maxHouseSquareMeters ...QuoteFragment }"#
    }

    @_spi(Unsafe) public let __data: DataDict
    @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

    @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { OctopusGraphQL.Objects.MoveIntent }
    @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
      .field("__typename", String.self),
      .field("currentHomeAddresses", [CurrentHomeAddress].self),
      .field("extraBuildingTypesV2", [ExtraBuildingTypesV2].self),
      .field("id", OctopusGraphQL.ID.self),
      .field("isApartmentAvailableforStudent", Bool?.self),
      .field("maxApartmentNumberCoInsured", Int?.self),
      .field("maxApartmentSquareMeters", Int?.self),
      .field("maxHouseNumberCoInsured", Int?.self),
      .field("maxHouseSquareMeters", Int?.self),
      .fragment(QuoteFragment.self),
    ] }
    @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
      MoveIntentFragment.self,
      QuoteFragment.self
    ] }

    ///  List of members current addresses possible to move from 
    public var currentHomeAddresses: [CurrentHomeAddress] { __data["currentHomeAddresses"] }
    ///  All available external building types accepted for new address 
    public var extraBuildingTypesV2: [ExtraBuildingTypesV2] { __data["extraBuildingTypesV2"] }
    public var id: OctopusGraphQL.ID { __data["id"] }
    ///  If member is eligable for apartment student insurance 
    public var isApartmentAvailableforStudent: Bool? { __data["isApartmentAvailableforStudent"] }
    ///  Max number of co-insured for an apartment to move to
    public var maxApartmentNumberCoInsured: Int? { __data["maxApartmentNumberCoInsured"] }
    ///  Max area of an apartment to move to 
    public var maxApartmentSquareMeters: Int? { __data["maxApartmentSquareMeters"] }
    ///  Max number of co-insured for a house to move to
    public var maxHouseNumberCoInsured: Int? { __data["maxHouseNumberCoInsured"] }
    ///  Max area of a house to move to
    public var maxHouseSquareMeters: Int? { __data["maxHouseSquareMeters"] }
    /// Will only be present after moveIntentRequest and for new V2_TIERS_AND_DEDUCTIBLES API.
    /// The MTA quotes for member's non-home contracts with new address.
    public var mtaQuotes: [MtaQuote] { __data["mtaQuotes"] }
    /// Will only be present after moveIntentRequest and for new V2_TIERS_AND_DEDUCTIBLES API.
    /// Quote variants for new home contract that member needs to pick one from.
    public var homeQuotes: [HomeQuote] { __data["homeQuotes"] }

    public struct Fragments: FragmentContainer {
      @_spi(Unsafe) public let __data: DataDict
      @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

      public var quoteFragment: QuoteFragment { _toFragment() }
    }

    /// CurrentHomeAddress
    ///
    /// Parent Type: `MoveAddress`
    nonisolated public struct CurrentHomeAddress: OctopusGraphQL.SelectionSet {
      @_spi(Unsafe) public let __data: DataDict
      @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

      @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { OctopusGraphQL.Objects.MoveAddress }
      @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
        .field("__typename", String.self),
        .fragment(MoveAddressFragment.self),
      ] }
      @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
        MoveIntentFragment.CurrentHomeAddress.self,
        MoveAddressFragment.self
      ] }

      ///  Address id, will correlate to the contract id 
      public var id: OctopusGraphQL.ID { __data["id"] }
      ///  Display subtitle for the contract when selecting moving flow 
      public var displaySubtitle: String? { __data["displaySubtitle"] }
      ///  Display title for the contract when selecting moving flow 
      public var displayTitle: String { __data["displayTitle"] }
      ///  The latest possible move date according to current contract 
      public var maxMovingDate: OctopusGraphQL.Date { __data["maxMovingDate"] }
      ///  The earliest possible move date according to current contract 
      public var minMovingDate: OctopusGraphQL.Date { __data["minMovingDate"] }
      ///  Number of co-insured from existing contract to use as default 
      public var suggestedNumberCoInsured: Int { __data["suggestedNumberCoInsured"] }

      public struct Fragments: FragmentContainer {
        @_spi(Unsafe) public let __data: DataDict
        @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

        public var moveAddressFragment: MoveAddressFragment { _toFragment() }
      }
    }

    /// ExtraBuildingTypesV2
    ///
    /// Parent Type: `MoveExtraBuildingTypeV2`
    nonisolated public struct ExtraBuildingTypesV2: OctopusGraphQL.SelectionSet {
      @_spi(Unsafe) public let __data: DataDict
      @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

      @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { OctopusGraphQL.Objects.MoveExtraBuildingTypeV2 }
      @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
        .field("__typename", String.self),
        .field("displayName", String.self),
        .field("type", String.self),
      ] }
      @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
        MoveIntentFragment.ExtraBuildingTypesV2.self
      ] }

      public var displayName: String { __data["displayName"] }
      public var type: String { __data["type"] }
    }

    public typealias MtaQuote = QuoteFragment.MtaQuote

    public typealias HomeQuote = QuoteFragment.HomeQuote
  }

}