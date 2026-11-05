// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI
@_spi(Execution) @_spi(Unsafe) import ApolloAPI

public extension OctopusGraphQL {
  nonisolated struct ClaimIntentStartMutation: GraphQLMutation {
    public static let operationName: String = "ClaimIntentStart"
    public static let operationDocument: ApolloAPI.OperationDocument = .init(
      definition: .init(
        #"mutation ClaimIntentStart { claimIntentStart { __typename ...ClaimIntentFragment } }"#,
        fragments: [ChatMessageDisclaimerFragment.self, ChatMessageFileFragment.self, ChatMessageTextFragment.self, ClaimFragment.self, ClaimIntentFragment.self, ClaimIntentOutcomeDeflectionPartnerFragment.self, ClaimIntentOutcomeDeflectionSimplePartnerFragment.self, ClaimIntentStepContentFormFieldFragment.self, ClaimIntentStepContentFragment.self, ClaimIntentStepFragment.self, ConversationFragment.self, DeflectFragment.self, InsuranceDocumentFragment.self, MessageFragment.self, MoneyFragment.self, PerilFragment.self, ProductVariantFragment.self]
      ))

    public init() {}

    nonisolated public struct Data: OctopusGraphQL.SelectionSet {
      @_spi(Unsafe) public let __data: DataDict
      @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

      @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { OctopusGraphQL.Objects.Mutation }
      @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
        .field("claimIntentStart", ClaimIntentStart.self),
      ] }
      @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
        ClaimIntentStartMutation.Data.self
      ] }

      /// Create or (reuse and existing) unsubmitted claim intent.
      public var claimIntentStart: ClaimIntentStart { __data["claimIntentStart"] }

      /// ClaimIntentStart
      ///
      /// Parent Type: `ClaimIntent`
      nonisolated public struct ClaimIntentStart: OctopusGraphQL.SelectionSet {
        @_spi(Unsafe) public let __data: DataDict
        @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

        @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { OctopusGraphQL.Objects.ClaimIntent }
        @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
          .field("__typename", String.self),
          .fragment(ClaimIntentFragment.self),
        ] }
        @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
          ClaimIntentStartMutation.Data.ClaimIntentStart.self,
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
    }
  }

}