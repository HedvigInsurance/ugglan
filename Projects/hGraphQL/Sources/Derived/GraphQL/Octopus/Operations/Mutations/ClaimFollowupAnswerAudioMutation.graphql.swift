// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI
@_spi(Execution) @_spi(Unsafe) import ApolloAPI

public extension OctopusGraphQL {
  nonisolated struct ClaimFollowupAnswerAudioMutation: GraphQLMutation {
    public static let operationName: String = "ClaimFollowupAnswerAudio"
    public static let operationDocument: ApolloAPI.OperationDocument = .init(
      definition: .init(
        #"mutation ClaimFollowupAnswerAudio($followupId: ID!, $questionId: ID!, $audioFileId: ID!) { claimFollowupAnswerAudio( followupId: $followupId questionId: $questionId audioFileId: $audioFileId ) { __typename ...ClaimFollowupOutputFragment } }"#,
        fragments: [ClaimFollowupFragment.self, ClaimFollowupOutputFragment.self]
      ))

    public var followupId: ID
    public var questionId: ID
    public var audioFileId: ID

    public init(
      followupId: ID,
      questionId: ID,
      audioFileId: ID
    ) {
      self.followupId = followupId
      self.questionId = questionId
      self.audioFileId = audioFileId
    }

    @_spi(Unsafe) public var __variables: Variables? { [
      "followupId": followupId,
      "questionId": questionId,
      "audioFileId": audioFileId
    ] }

    nonisolated public struct Data: OctopusGraphQL.SelectionSet {
      @_spi(Unsafe) public let __data: DataDict
      @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

      @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { OctopusGraphQL.Objects.Mutation }
      @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
        .field("claimFollowupAnswerAudio", ClaimFollowupAnswerAudio.self, arguments: [
          "followupId": .variable("followupId"),
          "questionId": .variable("questionId"),
          "audioFileId": .variable("audioFileId")
        ]),
      ] }
      @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
        ClaimFollowupAnswerAudioMutation.Data.self
      ] }

      /// A spoken answer to a free-text question; audioFileId comes from the upload endpoint.
      public var claimFollowupAnswerAudio: ClaimFollowupAnswerAudio { __data["claimFollowupAnswerAudio"] }

      /// ClaimFollowupAnswerAudio
      ///
      /// Parent Type: `ClaimFollowupOutput`
      nonisolated public struct ClaimFollowupAnswerAudio: OctopusGraphQL.SelectionSet {
        @_spi(Unsafe) public let __data: DataDict
        @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

        @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { OctopusGraphQL.Objects.ClaimFollowupOutput }
        @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
          .field("__typename", String.self),
          .fragment(ClaimFollowupOutputFragment.self),
        ] }
        @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
          ClaimFollowupAnswerAudioMutation.Data.ClaimFollowupAnswerAudio.self,
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