// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI
@_spi(Execution) @_spi(Unsafe) import ApolloAPI

public extension OctopusGraphQL {
  nonisolated struct MoveIntentRequestMutation: GraphQLMutation {
    public static let operationName: String = "MoveIntentRequest"
    public static let operationDocument: ApolloAPI.OperationDocument = .init(
      definition: .init(
        #"mutation MoveIntentRequest($intentId: ID!, $input: MoveIntentRequestInput!) { moveIntentRequest(intentId: $intentId, input: $input) { __typename userError { __typename message } moveIntent { __typename ...MoveIntentFragment } } }"#,
        fragments: [AddonVariantFragment.self, InsuranceDocumentFragment.self, ItemCostFragment.self, ItemDiscountFragment.self, MoneyFragment.self, MoveAddonQuoteFragment.self, MoveAddressFragment.self, MoveIntentFragment.self, MoveQuoteDisplayItemFragment.self, PerilFragment.self, ProductVariantFragment.self, QuoteFragment.self]
      ))

    public var intentId: ID
    public var input: MoveIntentRequestInput

    public init(
      intentId: ID,
      input: MoveIntentRequestInput
    ) {
      self.intentId = intentId
      self.input = input
    }

    @_spi(Unsafe) public var __variables: Variables? { [
      "intentId": intentId,
      "input": input
    ] }

    nonisolated public struct Data: OctopusGraphQL.SelectionSet {
      @_spi(Unsafe) public let __data: DataDict
      @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

      @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { OctopusGraphQL.Objects.Mutation }
      @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
        .field("moveIntentRequest", MoveIntentRequest.self, arguments: [
          "intentId": .variable("intentId"),
          "input": .variable("input")
        ]),
      ] }
      @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
        MoveIntentRequestMutation.Data.self
      ] }

      ///  Request move 
      public var moveIntentRequest: MoveIntentRequest { __data["moveIntentRequest"] }

      /// MoveIntentRequest
      ///
      /// Parent Type: `MoveIntentMutationOutput`
      nonisolated public struct MoveIntentRequest: OctopusGraphQL.SelectionSet {
        @_spi(Unsafe) public let __data: DataDict
        @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

        @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { OctopusGraphQL.Objects.MoveIntentMutationOutput }
        @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
          .field("__typename", String.self),
          .field("userError", UserError?.self),
          .field("moveIntent", MoveIntent?.self),
        ] }
        @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
          MoveIntentRequestMutation.Data.MoveIntentRequest.self
        ] }

        ///  Fail case 
        public var userError: UserError? { __data["userError"] }
        ///  Success case 
        public var moveIntent: MoveIntent? { __data["moveIntent"] }

        /// MoveIntentRequest.UserError
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
            MoveIntentRequestMutation.Data.MoveIntentRequest.UserError.self
          ] }

          public var message: String { __data["message"] }
        }

        /// MoveIntentRequest.MoveIntent
        ///
        /// Parent Type: `MoveIntent`
        nonisolated public struct MoveIntent: OctopusGraphQL.SelectionSet {
          @_spi(Unsafe) public let __data: DataDict
          @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

          @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { OctopusGraphQL.Objects.MoveIntent }
          @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
            .field("__typename", String.self),
            .fragment(MoveIntentFragment.self),
          ] }
          @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
            MoveIntentRequestMutation.Data.MoveIntentRequest.MoveIntent.self,
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

            public var moveIntentFragment: MoveIntentFragment { _toFragment() }
            public var quoteFragment: QuoteFragment { _toFragment() }
          }

          public typealias CurrentHomeAddress = MoveIntentFragment.CurrentHomeAddress

          public typealias ExtraBuildingTypesV2 = MoveIntentFragment.ExtraBuildingTypesV2

          public typealias MtaQuote = QuoteFragment.MtaQuote

          public typealias HomeQuote = QuoteFragment.HomeQuote
        }
      }
    }
  }

}