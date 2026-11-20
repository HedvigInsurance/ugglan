// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI
@_spi(Execution) @_spi(Unsafe) import ApolloAPI

public extension OctopusGraphQL {
  nonisolated struct ClaimFollowupAnswerBinaryMutation: GraphQLMutation {
    public static let operationName: String = "ClaimFollowupAnswerBinary"
    public static let operationDocument: ApolloAPI.OperationDocument = .init(
      definition: .init(
        #"mutation ClaimFollowupAnswerBinary($followupId: ID!, $questionId: ID!, $value: String!) { claimFollowupAnswerBinary( followupId: $followupId questionId: $questionId value: $value ) { __typename ...ClaimFollowupOutputFragment } }"#,
        fragments: [ClaimFollowupFragment.self, ClaimFollowupOutputFragment.self]
      ))

    public var followupId: ID
    public var questionId: ID
    public var value: String

    public init(
      followupId: ID,
      questionId: ID,
      value: String
    ) {
      self.followupId = followupId
      self.questionId = questionId
      self.value = value
    }

    @_spi(Unsafe) public var __variables: Variables? { [
      "followupId": followupId,
      "questionId": questionId,
      "value": value
    ] }

    nonisolated public struct Data: OctopusGraphQL.SelectionSet {
      @_spi(Unsafe) public let __data: DataDict
      @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

      @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { OctopusGraphQL.Objects.Mutation }
      @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
        .field("claimFollowupAnswerBinary", ClaimFollowupAnswerBinary.self, arguments: [
          "followupId": .variable("followupId"),
          "questionId": .variable("questionId"),
          "value": .variable("value")
        ]),
      ] }
      @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
        ClaimFollowupAnswerBinaryMutation.Data.self
      ] }

      /// The value is "true" or "false".
      public var claimFollowupAnswerBinary: ClaimFollowupAnswerBinary { __data["claimFollowupAnswerBinary"] }

      /// ClaimFollowupAnswerBinary
      ///
      /// Parent Type: `ClaimFollowupOutput`
      nonisolated public struct ClaimFollowupAnswerBinary: OctopusGraphQL.SelectionSet {
        @_spi(Unsafe) public let __data: DataDict
        @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

        @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { OctopusGraphQL.Objects.ClaimFollowupOutput }
        @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
          .field("__typename", String.self),
          .fragment(ClaimFollowupOutputFragment.self),
        ] }
        @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
          ClaimFollowupAnswerBinaryMutation.Data.ClaimFollowupAnswerBinary.self,
          ClaimFollowupOutputFragment.self
        ] }

        public var followup: Followup? { __data["followup"] }
        public var userError: UserError? { __data["userError"] }

        public struct Fragments: FragmentContainer {
          @_spi(Unsafe) public let __data: DataDict
          @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

          public var claimFollowupOutputFragment: ClaimFollowupOutputFragment { _toFragment() }
        }

        public typealias Followup = ClaimFollowupOutputFragment.Followup

        public typealias UserError = ClaimFollowupOutputFragment.UserError
      }
    }
  }

}