// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI
@_spi(Execution) @_spi(Unsafe) import ApolloAPI

public extension OctopusGraphQL {
  nonisolated struct TerminationNotificationQuery: GraphQLQuery {
    public static let operationName: String = "TerminationNotification"
    public static let operationDocument: ApolloAPI.OperationDocument = .init(
      definition: .init(
        #"query TerminationNotification($input: TerminationFlowNotificationInput!) { currentMember { __typename terminationNotification(input: $input) { __typename message type } } }"#
      ))

    public var input: TerminationFlowNotificationInput

    public init(input: TerminationFlowNotificationInput) {
      self.input = input
    }

    @_spi(Unsafe) public var __variables: Variables? { ["input": input] }

    nonisolated public struct Data: OctopusGraphQL.SelectionSet {
      @_spi(Unsafe) public let __data: DataDict
      @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

      @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { OctopusGraphQL.Objects.Query }
      @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
        .field("currentMember", CurrentMember.self),
      ] }
      @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
        TerminationNotificationQuery.Data.self
      ] }

      /// Gets the currently authenticated member. This is the only valid way to query a `Member` type, and it is based
      /// on the input Authorization header.
      public var currentMember: CurrentMember { __data["currentMember"] }

      /// CurrentMember
      ///
      /// Parent Type: `Member`
      nonisolated public struct CurrentMember: OctopusGraphQL.SelectionSet {
        @_spi(Unsafe) public let __data: DataDict
        @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

        @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { OctopusGraphQL.Objects.Member }
        @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
          .field("__typename", String.self),
          .field("terminationNotification", TerminationNotification?.self, arguments: ["input": .variable("input")]),
        ] }
        @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
          TerminationNotificationQuery.Data.CurrentMember.self
        ] }

        ///  Get contract info during termination flow. Null if no message to display. 
        public var terminationNotification: TerminationNotification? { __data["terminationNotification"] }

        /// CurrentMember.TerminationNotification
        ///
        /// Parent Type: `TerminationFlowNotification`
        nonisolated public struct TerminationNotification: OctopusGraphQL.SelectionSet {
          @_spi(Unsafe) public let __data: DataDict
          @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

          @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { OctopusGraphQL.Objects.TerminationFlowNotification }
          @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
            .field("__typename", String.self),
            .field("message", String.self),
            .field("type", GraphQLEnum<OctopusGraphQL.TerminationFlowNotificationType>.self),
          ] }
          @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
            TerminationNotificationQuery.Data.CurrentMember.TerminationNotification.self
          ] }

          public var message: String { __data["message"] }
          public var type: GraphQLEnum<OctopusGraphQL.TerminationFlowNotificationType> { __data["type"] }
        }
      }
    }
  }

}