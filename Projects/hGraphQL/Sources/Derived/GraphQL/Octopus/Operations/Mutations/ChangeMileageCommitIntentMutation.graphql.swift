// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI
@_spi(Execution) @_spi(Unsafe) import ApolloAPI

public extension OctopusGraphQL {
  nonisolated struct ChangeMileageCommitIntentMutation: GraphQLMutation {
    public static let operationName: String = "ChangeMileageCommitIntent"
    public static let operationDocument: ApolloAPI.OperationDocument = .init(
      definition: .init(
        #"mutation ChangeMileageCommitIntent($quoteId: ID!) { changeMileageCommitIntent(quoteId: $quoteId) { __typename message } }"#
      ))

    public var quoteId: ID

    public init(quoteId: ID) {
      self.quoteId = quoteId
    }

    @_spi(Unsafe) public var __variables: Variables? { ["quoteId": quoteId] }

    nonisolated public struct Data: OctopusGraphQL.SelectionSet {
      @_spi(Unsafe) public let __data: DataDict
      @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

      @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { OctopusGraphQL.Objects.Mutation }
      @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
        .field("changeMileageCommitIntent", ChangeMileageCommitIntent?.self, arguments: ["quoteId": .variable("quoteId")]),
      ] }
      @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
        ChangeMileageCommitIntentMutation.Data.self
      ] }

      /// Activates the given quote from changeMileageCreateIntent, the new mileage applies from the activation date
      /// of the intent. Returns a UserError if it failed.
      public var changeMileageCommitIntent: ChangeMileageCommitIntent? { __data["changeMileageCommitIntent"] }

      /// ChangeMileageCommitIntent
      ///
      /// Parent Type: `UserError`
      nonisolated public struct ChangeMileageCommitIntent: OctopusGraphQL.SelectionSet {
        @_spi(Unsafe) public let __data: DataDict
        @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

        @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { OctopusGraphQL.Objects.UserError }
        @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
          .field("__typename", String.self),
          .field("message", String.self),
        ] }
        @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
          ChangeMileageCommitIntentMutation.Data.ChangeMileageCommitIntent.self
        ] }

        public var message: String { __data["message"] }
      }
    }
  }

}