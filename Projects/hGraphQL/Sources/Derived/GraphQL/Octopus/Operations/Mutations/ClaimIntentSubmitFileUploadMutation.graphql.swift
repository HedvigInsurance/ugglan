// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI
@_spi(Execution) @_spi(Unsafe) import ApolloAPI

public extension OctopusGraphQL {
  nonisolated struct ClaimIntentSubmitFileUploadMutation: GraphQLMutation {
    public static let operationName: String = "ClaimIntentSubmitFileUpload"
    public static let operationDocument: ApolloAPI.OperationDocument = .init(
      definition: .init(
        #"mutation ClaimIntentSubmitFileUpload($input: ClaimIntentSubmitFileUploadInput!) { claimIntentSubmitFileUpload(input: $input) { __typename intent { __typename ...ClaimIntentFragment } userError { __typename message } } }"#,
        fragments: [ChatMessageDisclaimerFragment.self, ChatMessageFileFragment.self, ChatMessageTextFragment.self, ClaimFragment.self, ClaimIntentFragment.self, ClaimIntentOutcomeDeflectionPartnerFragment.self, ClaimIntentOutcomeDeflectionSimplePartnerFragment.self, ClaimIntentStepContentFormFieldFragment.self, ClaimIntentStepContentFragment.self, ClaimIntentStepFragment.self, ConversationFragment.self, DeflectFragment.self, InsuranceDocumentFragment.self, MessageFragment.self, MoneyFragment.self, PerilFragment.self, ProductVariantFragment.self]
      ))

    public var input: ClaimIntentSubmitFileUploadInput

    public init(input: ClaimIntentSubmitFileUploadInput) {
      self.input = input
    }

    @_spi(Unsafe) public var __variables: Variables? { ["input": input] }

    nonisolated public struct Data: OctopusGraphQL.SelectionSet {
      @_spi(Unsafe) public let __data: DataDict
      @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

      @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { OctopusGraphQL.Objects.Mutation }
      @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
        .field("claimIntentSubmitFileUpload", ClaimIntentSubmitFileUpload.self, arguments: ["input": .variable("input")]),
      ] }
      @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
        ClaimIntentSubmitFileUploadMutation.Data.self
      ] }

      /// Submit a step containing a `ClaimIntentStepContentFileUpload`.
      public var claimIntentSubmitFileUpload: ClaimIntentSubmitFileUpload { __data["claimIntentSubmitFileUpload"] }

      /// ClaimIntentSubmitFileUpload
      ///
      /// Parent Type: `ClaimIntentMutationOutput`
      nonisolated public struct ClaimIntentSubmitFileUpload: OctopusGraphQL.SelectionSet {
        @_spi(Unsafe) public let __data: DataDict
        @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

        @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { OctopusGraphQL.Objects.ClaimIntentMutationOutput }
        @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
          .field("__typename", String.self),
          .field("intent", Intent?.self),
          .field("userError", UserError?.self),
        ] }
        @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
          ClaimIntentSubmitFileUploadMutation.Data.ClaimIntentSubmitFileUpload.self
        ] }

        public var intent: Intent? { __data["intent"] }
        public var userError: UserError? { __data["userError"] }

        /// ClaimIntentSubmitFileUpload.Intent
        ///
        /// Parent Type: `ClaimIntent`
        nonisolated public struct Intent: OctopusGraphQL.SelectionSet {
          @_spi(Unsafe) public let __data: DataDict
          @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

          @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { OctopusGraphQL.Objects.ClaimIntent }
          @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
            .field("__typename", String.self),
            .fragment(ClaimIntentFragment.self),
          ] }
          @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
            ClaimIntentSubmitFileUploadMutation.Data.ClaimIntentSubmitFileUpload.Intent.self,
            ClaimIntentFragment.self
          ] }

          public var id: OctopusGraphQL.ID { __data["id"] }
          /// The time this was started.
          public var createdAt: OctopusGraphQL.DateTime { __data["createdAt"] }
          /// A value between 0.0 and 1.0 that indicates roughly how far along the submission
          /// flow the user has progressed.
          public var progress: Double? { __data["progress"] }
          /// The current step.
          public var currentStep: CurrentStep? { __data["currentStep"] }
          /// The created claim of this intent.
          ///
          /// Once this value is returned, the intent is effectively over, and no steps
          /// can be produced or interacted with.
          public var createdClaim: CreatedClaim? { __data["createdClaim"] }
          /// A short summary of the contents of this flow. Null when the flow is completely new (typically pre triage).
          public var displayName: String? { __data["displayName"] }
          /// Whether this draft is resumable by the member. A draft that has been deleted (see `claimIntentDeleteDraft`)
          /// is no longer resumable.
          public var resumable: Bool { __data["resumable"] }

          public struct Fragments: FragmentContainer {
            @_spi(Unsafe) public let __data: DataDict
            @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

            public var claimIntentFragment: ClaimIntentFragment { _toFragment() }
          }

          public typealias CurrentStep = ClaimIntentFragment.CurrentStep

          public typealias CreatedClaim = ClaimIntentFragment.CreatedClaim
        }

        /// ClaimIntentSubmitFileUpload.UserError
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
            ClaimIntentSubmitFileUploadMutation.Data.ClaimIntentSubmitFileUpload.UserError.self
          ] }

          public var message: String { __data["message"] }
        }
      }
    }
  }

}