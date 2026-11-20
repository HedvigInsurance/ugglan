// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI
@_spi(Execution) @_spi(Unsafe) import ApolloAPI

public extension OctopusGraphQL {
  nonisolated struct ClaimFollowupCantAnswerMutation: GraphQLMutation {
    public static let operationName: String = "ClaimFollowupCantAnswer"
    public static let operationDocument: ApolloAPI.OperationDocument = .init(
      definition: .init(
        #"mutation ClaimFollowupCantAnswer($followupId: ID!, $questionId: ID!, $comment: String) { claimFollowupCantAnswer( followupId: $followupId questionId: $questionId comment: $comment ) { __typename ...ClaimFollowupOutputFragment } }"#,
        fragments: [ClaimFollowupFragment.self, ClaimFollowupOutputFragment.self]
      ))

    public var followupId: ID
    public var questionId: ID
    public var comment: GraphQLNullable<String>

    public init(
      followupId: ID,
      questionId: ID,
      comment: GraphQLNullable<String>
    ) {
      self.followupId = followupId
      self.questionId = questionId
      self.comment = comment
    }

    @_spi(Unsafe) public var __variables: Variables? { [
      "followupId": followupId,
      "questionId": questionId,
      "comment": comment
    ] }

    nonisolated public struct Data: OctopusGraphQL.SelectionSet {
      @_spi(Unsafe) public let __data: DataDict
      @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

      @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { OctopusGraphQL.Objects.Mutation }
      @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
        .field("claimFollowupCantAnswer", ClaimFollowupCantAnswer.self, arguments: [
          "followupId": .variable("followupId"),
          "questionId": .variable("questionId"),
          "comment": .variable("comment")
        ]),
      ] }
      @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
        ClaimFollowupCantAnswerMutation.Data.self
      ] }

      /// The member cannot answer this question; the comment says why and may be left out.
      public var claimFollowupCantAnswer: ClaimFollowupCantAnswer { __data["claimFollowupCantAnswer"] }

      /// ClaimFollowupCantAnswer
      ///
      /// Parent Type: `ClaimFollowupOutput`
      nonisolated public struct ClaimFollowupCantAnswer: OctopusGraphQL.SelectionSet {
        @_spi(Unsafe) public let __data: DataDict
        @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

        @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { OctopusGraphQL.Objects.ClaimFollowupOutput }
        @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
          .field("__typename", String.self),
          .fragment(ClaimFollowupOutputFragment.self),
        ] }
        @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
          ClaimFollowupCantAnswerMutation.Data.ClaimFollowupCantAnswer.self,
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