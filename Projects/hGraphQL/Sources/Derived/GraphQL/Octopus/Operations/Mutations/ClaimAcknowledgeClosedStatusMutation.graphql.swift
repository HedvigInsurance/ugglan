// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI
@_spi(Execution) @_spi(Unsafe) import ApolloAPI

public extension OctopusGraphQL {
  nonisolated struct ClaimAcknowledgeClosedStatusMutation: GraphQLMutation {
    public static let operationName: String = "ClaimAcknowledgeClosedStatus"
    public static let operationDocument: ApolloAPI.OperationDocument = .init(
      definition: .init(
        #"mutation ClaimAcknowledgeClosedStatus($claimAcknowledgeClosedStatusId: ID!) { claimAcknowledgeClosedStatus(id: $claimAcknowledgeClosedStatusId) { __typename userError { __typename message } } }"#
      ))

    public var claimAcknowledgeClosedStatusId: ID

    public init(claimAcknowledgeClosedStatusId: ID) {
      self.claimAcknowledgeClosedStatusId = claimAcknowledgeClosedStatusId
    }

    @_spi(Unsafe) public var __variables: Variables? { ["claimAcknowledgeClosedStatusId": claimAcknowledgeClosedStatusId] }

    nonisolated public struct Data: OctopusGraphQL.SelectionSet {
      @_spi(Unsafe) public let __data: DataDict
      @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

      @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { OctopusGraphQL.Objects.Mutation }
      @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
        .field("claimAcknowledgeClosedStatus", ClaimAcknowledgeClosedStatus?.self, arguments: ["id": .variable("claimAcknowledgeClosedStatusId")]),
      ] }
      @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
        ClaimAcknowledgeClosedStatusMutation.Data.self
      ] }

      public var claimAcknowledgeClosedStatus: ClaimAcknowledgeClosedStatus? { __data["claimAcknowledgeClosedStatus"] }

      /// ClaimAcknowledgeClosedStatus
      ///
      /// Parent Type: `ClaimMutationOutput`
      nonisolated public struct ClaimAcknowledgeClosedStatus: OctopusGraphQL.SelectionSet {
        @_spi(Unsafe) public let __data: DataDict
        @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

        @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { OctopusGraphQL.Objects.ClaimMutationOutput }
        @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
          .field("__typename", String.self),
          .field("userError", UserError?.self),
        ] }
        @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
          ClaimAcknowledgeClosedStatusMutation.Data.ClaimAcknowledgeClosedStatus.self
        ] }

        public var userError: UserError? { __data["userError"] }

        /// ClaimAcknowledgeClosedStatus.UserError
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
            ClaimAcknowledgeClosedStatusMutation.Data.ClaimAcknowledgeClosedStatus.UserError.self
          ] }

          public var message: String { __data["message"] }
        }
      }
    }
  }

}