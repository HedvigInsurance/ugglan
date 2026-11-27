// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI
@_spi(Execution) @_spi(Unsafe) import ApolloAPI

public extension OctopusGraphQL {
  nonisolated struct WithdrawContractMutation: GraphQLMutation {
    public static let operationName: String = "WithdrawContract"
    public static let operationDocument: ApolloAPI.OperationDocument = .init(
      definition: .init(
        #"mutation WithdrawContract($contractId: UUID!) { withdrawContract(contractId: $contractId) { __typename userError { __typename message } } }"#
      ))

    public var contractId: UUID

    public init(contractId: UUID) {
      self.contractId = contractId
    }

    @_spi(Unsafe) public var __variables: Variables? { ["contractId": contractId] }

    nonisolated public struct Data: OctopusGraphQL.SelectionSet {
      @_spi(Unsafe) public let __data: DataDict
      @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

      @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { OctopusGraphQL.Objects.Mutation }
      @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
        .field("withdrawContract", WithdrawContract.self, arguments: ["contractId": .variable("contractId")]),
      ] }
      @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
        WithdrawContractMutation.Data.self
      ] }

      /// Withdraws from the contract: an active contract is terminated on the date given by `ContractWithdrawal.action`,
      /// a contract that has not started yet is deleted.
      public var withdrawContract: WithdrawContract { __data["withdrawContract"] }

      /// WithdrawContract
      ///
      /// Parent Type: `TerminationFlowContractMutationOutput`
      nonisolated public struct WithdrawContract: OctopusGraphQL.SelectionSet {
        @_spi(Unsafe) public let __data: DataDict
        @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

        @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { OctopusGraphQL.Objects.TerminationFlowContractMutationOutput }
        @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
          .field("__typename", String.self),
          .field("userError", UserError?.self),
        ] }
        @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
          WithdrawContractMutation.Data.WithdrawContract.self
        ] }

        public var userError: UserError? { __data["userError"] }

        /// WithdrawContract.UserError
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
            WithdrawContractMutation.Data.WithdrawContract.UserError.self
          ] }

          public var message: String { __data["message"] }
        }
      }
    }
  }

}