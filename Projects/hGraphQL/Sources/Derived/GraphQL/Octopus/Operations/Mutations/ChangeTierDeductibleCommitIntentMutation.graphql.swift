// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI
@_spi(Execution) @_spi(Unsafe) import ApolloAPI

public extension OctopusGraphQL {
  nonisolated struct ChangeTierDeductibleCommitIntentMutation: GraphQLMutation {
    public static let operationName: String = "ChangeTierDeductibleCommitIntent"
    public static let operationDocument: ApolloAPI.OperationDocument = .init(
      definition: .init(
        #"mutation ChangeTierDeductibleCommitIntent($input: ChangeTierDeductibleCommitIntentInput!) { changeTierDeductibleCommitIntent(input: $input) { __typename userError { __typename message } } }"#
      ))

    public var input: ChangeTierDeductibleCommitIntentInput

    public init(input: ChangeTierDeductibleCommitIntentInput) {
      self.input = input
    }

    @_spi(Unsafe) public var __variables: Variables? { ["input": input] }

    nonisolated public struct Data: OctopusGraphQL.SelectionSet {
      @_spi(Unsafe) public let __data: DataDict
      @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

      @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { OctopusGraphQL.Objects.Mutation }
      @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
        .field("changeTierDeductibleCommitIntent", ChangeTierDeductibleCommitIntent.self, arguments: ["input": .variable("input")]),
      ] }
      @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
        ChangeTierDeductibleCommitIntentMutation.Data.self
      ] }

      ///  Accept quote 
      public var changeTierDeductibleCommitIntent: ChangeTierDeductibleCommitIntent { __data["changeTierDeductibleCommitIntent"] }

      /// ChangeTierDeductibleCommitIntent
      ///
      /// Parent Type: `ChangeTierDeductibleCommitIntentOutput`
      nonisolated public struct ChangeTierDeductibleCommitIntent: OctopusGraphQL.SelectionSet {
        @_spi(Unsafe) public let __data: DataDict
        @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

        @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { OctopusGraphQL.Objects.ChangeTierDeductibleCommitIntentOutput }
        @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
          .field("__typename", String.self),
          .field("userError", UserError?.self),
        ] }
        @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
          ChangeTierDeductibleCommitIntentMutation.Data.ChangeTierDeductibleCommitIntent.self
        ] }

        ///  Fail case 
        public var userError: UserError? { __data["userError"] }

        /// ChangeTierDeductibleCommitIntent.UserError
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
            ChangeTierDeductibleCommitIntentMutation.Data.ChangeTierDeductibleCommitIntent.UserError.self
          ] }

          public var message: String { __data["message"] }
        }
      }
    }
  }

}