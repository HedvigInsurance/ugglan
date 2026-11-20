// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI
@_spi(Execution) @_spi(Unsafe) import ApolloAPI

public extension OctopusGraphQL {
  nonisolated struct ClaimFollowupAnswerFileUploadMutation: GraphQLMutation {
    public static let operationName: String = "ClaimFollowupAnswerFileUpload"
    public static let operationDocument: ApolloAPI.OperationDocument = .init(
      definition: .init(
        #"mutation ClaimFollowupAnswerFileUpload($followupId: ID!, $questionId: ID!, $fileIds: [ID!]!) { claimFollowupAnswerFileUpload( followupId: $followupId questionId: $questionId fileIds: $fileIds ) { __typename ...ClaimFollowupOutputFragment } }"#,
        fragments: [ClaimFollowupFragment.self, ClaimFollowupOutputFragment.self]
      ))

    public var followupId: ID
    public var questionId: ID
    public var fileIds: [ID]

    public init(
      followupId: ID,
      questionId: ID,
      fileIds: [ID]
    ) {
      self.followupId = followupId
      self.questionId = questionId
      self.fileIds = fileIds
    }

    @_spi(Unsafe) public var __variables: Variables? { [
      "followupId": followupId,
      "questionId": questionId,
      "fileIds": fileIds
    ] }

    nonisolated public struct Data: OctopusGraphQL.SelectionSet {
      @_spi(Unsafe) public let __data: DataDict
      @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

      @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { OctopusGraphQL.Objects.Mutation }
      @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
        .field("claimFollowupAnswerFileUpload", ClaimFollowupAnswerFileUpload.self, arguments: [
          "followupId": .variable("followupId"),
          "questionId": .variable("questionId"),
          "fileIds": .variable("fileIds")
        ]),
      ] }
      @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
        ClaimFollowupAnswerFileUploadMutation.Data.self
      ] }

      /// The files to keep as the answer; the ids come from the upload endpoint.
      public var claimFollowupAnswerFileUpload: ClaimFollowupAnswerFileUpload { __data["claimFollowupAnswerFileUpload"] }

      /// ClaimFollowupAnswerFileUpload
      ///
      /// Parent Type: `ClaimFollowupOutput`
      nonisolated public struct ClaimFollowupAnswerFileUpload: OctopusGraphQL.SelectionSet {
        @_spi(Unsafe) public let __data: DataDict
        @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

        @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { OctopusGraphQL.Objects.ClaimFollowupOutput }
        @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
          .field("__typename", String.self),
          .fragment(ClaimFollowupOutputFragment.self),
        ] }
        @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
          ClaimFollowupAnswerFileUploadMutation.Data.ClaimFollowupAnswerFileUpload.self,
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