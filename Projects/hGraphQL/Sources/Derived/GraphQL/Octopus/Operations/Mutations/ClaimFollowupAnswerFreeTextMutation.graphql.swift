// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI
@_spi(Execution) @_spi(Unsafe) import ApolloAPI

public extension OctopusGraphQL {
  nonisolated struct ClaimFollowupAnswerFreeTextMutation: GraphQLMutation {
    public static let operationName: String = "ClaimFollowupAnswerFreeText"
    public static let operationDocument: ApolloAPI.OperationDocument = .init(
      definition: .init(
        #"mutation ClaimFollowupAnswerFreeText($followupId: ID!, $questionId: ID!, $text: String!) { claimFollowupAnswerFreeText( followupId: $followupId questionId: $questionId text: $text ) { __typename ...ClaimFollowupOutputFragment } }"#,
        fragments: [ClaimFollowupFragment.self, ClaimFollowupOutputFragment.self]
      ))

    public var followupId: ID
    public var questionId: ID
    public var text: String

    public init(
      followupId: ID,
      questionId: ID,
      text: String
    ) {
      self.followupId = followupId
      self.questionId = questionId
      self.text = text
    }

    @_spi(Unsafe) public var __variables: Variables? { [
      "followupId": followupId,
      "questionId": questionId,
      "text": text
    ] }

    nonisolated public struct Data: OctopusGraphQL.SelectionSet {
      @_spi(Unsafe) public let __data: DataDict
      @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

      @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { OctopusGraphQL.Objects.Mutation }
      @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
        .field("claimFollowupAnswerFreeText", ClaimFollowupAnswerFreeText.self, arguments: [
          "followupId": .variable("followupId"),
          "questionId": .variable("questionId"),
          "text": .variable("text")
        ]),
      ] }
      @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
        ClaimFollowupAnswerFreeTextMutation.Data.self
      ] }

      /// A typed answer to a free-text question.
      public var claimFollowupAnswerFreeText: ClaimFollowupAnswerFreeText { __data["claimFollowupAnswerFreeText"] }

      /// ClaimFollowupAnswerFreeText
      ///
      /// Parent Type: `ClaimFollowupOutput`
      nonisolated public struct ClaimFollowupAnswerFreeText: OctopusGraphQL.SelectionSet {
        @_spi(Unsafe) public let __data: DataDict
        @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

        @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { OctopusGraphQL.Objects.ClaimFollowupOutput }
        @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
          .field("__typename", String.self),
          .fragment(ClaimFollowupOutputFragment.self),
        ] }
        @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
          ClaimFollowupAnswerFreeTextMutation.Data.ClaimFollowupAnswerFreeText.self,
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