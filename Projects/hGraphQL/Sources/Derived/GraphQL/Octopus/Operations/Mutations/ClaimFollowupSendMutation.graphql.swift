// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI
@_spi(Execution) @_spi(Unsafe) import ApolloAPI

public extension OctopusGraphQL {
  nonisolated struct ClaimFollowupSendMutation: GraphQLMutation {
    public static let operationName: String = "ClaimFollowupSend"
    public static let operationDocument: ApolloAPI.OperationDocument = .init(
      definition: .init(
        #"mutation ClaimFollowupSend($followupId: ID!) { claimFollowupSend(followupId: $followupId) { __typename ...ClaimFollowupOutputFragment } }"#,
        fragments: [ClaimFollowupFragment.self, ClaimFollowupOutputFragment.self]
      ))

    public var followupId: ID

    public init(followupId: ID) {
      self.followupId = followupId
    }

    @_spi(Unsafe) public var __variables: Variables? { ["followupId": followupId] }

    nonisolated public struct Data: OctopusGraphQL.SelectionSet {
      @_spi(Unsafe) public let __data: DataDict
      @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

      @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { OctopusGraphQL.Objects.Mutation }
      @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
        .field("claimFollowupSend", ClaimFollowupSend.self, arguments: ["followupId": .variable("followupId")]),
      ] }
      @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
        ClaimFollowupSendMutation.Data.self
      ] }

      /// Completes the follow-up and copies answered files to the claim. Refused while any question is TODO. Calling it again returns the follow-up unchanged.
      public var claimFollowupSend: ClaimFollowupSend { __data["claimFollowupSend"] }

      /// ClaimFollowupSend
      ///
      /// Parent Type: `ClaimFollowupOutput`
      nonisolated public struct ClaimFollowupSend: OctopusGraphQL.SelectionSet {
        @_spi(Unsafe) public let __data: DataDict
        @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

        @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { OctopusGraphQL.Objects.ClaimFollowupOutput }
        @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
          .field("__typename", String.self),
          .fragment(ClaimFollowupOutputFragment.self),
        ] }
        @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
          ClaimFollowupSendMutation.Data.ClaimFollowupSend.self,
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