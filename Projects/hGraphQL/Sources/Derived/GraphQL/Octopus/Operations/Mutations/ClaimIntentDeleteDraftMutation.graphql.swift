// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI
@_spi(Execution) @_spi(Unsafe) import ApolloAPI

public extension OctopusGraphQL {
  nonisolated struct ClaimIntentDeleteDraftMutation: GraphQLMutation {
    public static let operationName: String = "ClaimIntentDeleteDraft"
    public static let operationDocument: ApolloAPI.OperationDocument = .init(
      definition: .init(
        #"mutation ClaimIntentDeleteDraft($id: ID!) { claimIntentDeleteDraft(id: $id) }"#
      ))

    public var id: ID

    public init(id: ID) {
      self.id = id
    }

    @_spi(Unsafe) public var __variables: Variables? { ["id": id] }

    nonisolated public struct Data: OctopusGraphQL.SelectionSet {
      @_spi(Unsafe) public let __data: DataDict
      @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

      @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { OctopusGraphQL.Objects.Mutation }
      @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
        .field("claimIntentDeleteDraft", Bool.self, arguments: ["id": .variable("id")]),
      ] }
      @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
        ClaimIntentDeleteDraftMutation.Data.self
      ] }

      /// Delete a draft claim intent from the member's perspective (a soft delete) so it is no longer returned by `resumableClaimIntent`.
      public var claimIntentDeleteDraft: Bool { __data["claimIntentDeleteDraft"] }
    }
  }

}