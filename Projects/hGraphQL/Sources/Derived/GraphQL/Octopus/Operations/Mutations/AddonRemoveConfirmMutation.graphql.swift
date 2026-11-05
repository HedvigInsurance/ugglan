// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI
@_spi(Execution) @_spi(Unsafe) import ApolloAPI

public extension OctopusGraphQL {
  nonisolated struct AddonRemoveConfirmMutation: GraphQLMutation {
    public static let operationName: String = "AddonRemoveConfirm"
    public static let operationDocument: ApolloAPI.OperationDocument = .init(
      definition: .init(
        #"mutation AddonRemoveConfirm($contractId: ID!, $addonIds: [ID!]!) { addonRemoveConfirm(contractId: $contractId, addonIds: $addonIds) { __typename message } }"#
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

      @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { OctopusGraphQL.Objects.Mutation }
      @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
        .field("addonRemoveConfirm", AddonRemoveConfirm?.self, arguments: [
          "contractId": .variable("contractId"),
          "addonIds": .variable("addonIds")
        ]),
      ] }
      @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
        AddonRemoveConfirmMutation.Data.self
      ] }

      /// Call this to confirm removal of selected addon(s).
      public var addonRemoveConfirm: AddonRemoveConfirm? { __data["addonRemoveConfirm"] }

      /// AddonRemoveConfirm
      ///
      /// Parent Type: `UserError`
      nonisolated public struct AddonRemoveConfirm: OctopusGraphQL.SelectionSet {
        @_spi(Unsafe) public let __data: DataDict
        @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

        @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { OctopusGraphQL.Objects.UserError }
        @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
          .field("__typename", String.self),
          .field("message", String.self),
        ] }
        @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
          AddonRemoveConfirmMutation.Data.AddonRemoveConfirm.self
        ] }

        public var message: String { __data["message"] }
      }
    }
  }

}