// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI
@_spi(Execution) @_spi(Unsafe) import ApolloAPI

public extension OctopusGraphQL {
  nonisolated struct TerminateContractMutation: GraphQLMutation {
    public static let operationName: String = "TerminateContract"
    public static let operationDocument: ApolloAPI.OperationDocument = .init(
      definition: .init(
        #"mutation TerminateContract($input: TerminationFlowTerminateContractInput!) { terminateContract(input: $input) { __typename userError { __typename message } } }"#
      ))

    public var input: TerminationFlowTerminateContractInput

    public init(input: TerminationFlowTerminateContractInput) {
      self.input = input
    }

    @_spi(Unsafe) public var __variables: Variables? { ["input": input] }

    nonisolated public struct Data: OctopusGraphQL.SelectionSet {
      @_spi(Unsafe) public let __data: DataDict
      @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

      @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { OctopusGraphQL.Objects.Mutation }
      @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
        .field("terminateContract", TerminateContract.self, arguments: ["input": .variable("input")]),
      ] }
      @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
        TerminateContractMutation.Data.self
      ] }

      public var terminateContract: TerminateContract { __data["terminateContract"] }

      /// TerminateContract
      ///
      /// Parent Type: `TerminationFlowContractMutationOutput`
      nonisolated public struct TerminateContract: OctopusGraphQL.SelectionSet {
        @_spi(Unsafe) public let __data: DataDict
        @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

        @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { OctopusGraphQL.Objects.TerminationFlowContractMutationOutput }
        @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
          .field("__typename", String.self),
          .field("userError", UserError?.self),
        ] }
        @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
          TerminateContractMutation.Data.TerminateContract.self
        ] }

        public var userError: UserError? { __data["userError"] }

        /// TerminateContract.UserError
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
            TerminateContractMutation.Data.TerminateContract.UserError.self
          ] }

          public var message: String { __data["message"] }
        }
      }
    }
  }

}