// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI
@_spi(Execution) @_spi(Unsafe) import ApolloAPI

public extension OctopusGraphQL {
  nonisolated struct AddonActivateOfferMutation: GraphQLMutation {
    public static let operationName: String = "AddonActivateOffer"
    public static let operationDocument: ApolloAPI.OperationDocument = .init(
      definition: .init(
        #"mutation AddonActivateOffer($quoteId: ID!, $selectedAddonIds: [ID!]!) { addonActivateOffer(quoteId: $quoteId, selectedAddonIds: $selectedAddonIds) { __typename userError { __typename message } } }"#
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

      @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { OctopusGraphQL.Objects.Mutation }
      @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
        .field("addonActivateOffer", AddonActivateOffer.self, arguments: [
          "quoteId": .variable("quoteId"),
          "selectedAddonIds": .variable("selectedAddonIds")
        ]),
      ] }
      @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
        AddonActivateOfferMutation.Data.self
      ] }

      /// Call this to accept an addon offer and activate selected addon(s).
      public var addonActivateOffer: AddonActivateOffer { __data["addonActivateOffer"] }

      /// AddonActivateOffer
      ///
      /// Parent Type: `AddonActivationOutput`
      nonisolated public struct AddonActivateOffer: OctopusGraphQL.SelectionSet {
        @_spi(Unsafe) public let __data: DataDict
        @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

        @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { OctopusGraphQL.Objects.AddonActivationOutput }
        @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
          .field("__typename", String.self),
          .field("userError", UserError?.self),
        ] }
        @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
          AddonActivateOfferMutation.Data.AddonActivateOffer.self
        ] }

        /// If any error occurred.
        public var userError: UserError? { __data["userError"] }

        /// AddonActivateOffer.UserError
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
            AddonActivateOfferMutation.Data.AddonActivateOffer.UserError.self
          ] }

          public var message: String { __data["message"] }
        }
      }
    }
  }

}