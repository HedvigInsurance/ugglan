// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI
@_spi(Execution) @_spi(Unsafe) import ApolloAPI

public extension OctopusGraphQL {
  nonisolated struct ClaimIntentStartWithPreviousStepsQuery: GraphQLQuery {
    public static let operationName: String = "ClaimIntentStartWithPreviousSteps"
    public static let operationDocument: ApolloAPI.OperationDocument = .init(
      definition: .init(
        #"query ClaimIntentStartWithPreviousSteps($resume: Boolean!) { currentMember { __typename resumableClaimIntent(resume: $resume) { __typename ...ClaimIntentFragment previousSteps { __typename ...ClaimIntentStepFragment } } } }"#,
        fragments: [ChatMessageDisclaimerFragment.self, ChatMessageFileFragment.self, ChatMessageTextFragment.self, ClaimFragment.self, ClaimIntentFragment.self, ClaimIntentOutcomeDeflectionPartnerFragment.self, ClaimIntentOutcomeDeflectionSimplePartnerFragment.self, ClaimIntentStepContentFormFieldFragment.self, ClaimIntentStepContentFragment.self, ClaimIntentStepFragment.self, ConversationFragment.self, DeflectFragment.self, InsuranceDocumentFragment.self, MessageFragment.self, MoneyFragment.self, PerilFragment.self, ProductVariantFragment.self]
      ))

    public var resume: Bool

    public init(resume: Bool) {
      self.resume = resume
    }

    @_spi(Unsafe) public var __variables: Variables? { ["resume": resume] }

    nonisolated public struct Data: OctopusGraphQL.SelectionSet {
      @_spi(Unsafe) public let __data: DataDict
      @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

      @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { OctopusGraphQL.Objects.Query }
      @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
        .field("currentMember", CurrentMember.self),
      ] }
      @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
        ClaimIntentStartWithPreviousStepsQuery.Data.self
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
          .field("resumableClaimIntent", ResumableClaimIntent?.self, arguments: ["resume": .variable("resume")]),
        ] }
        @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
          ClaimIntentStartWithPreviousStepsQuery.Data.CurrentMember.self
        ] }

        /// Returns the most recent claim intent for this member, that can be "resumed" by querying `ClaimIntent.previousSteps`.
        ///
        /// Will return `null` if the server considers it too old to be resumed.
        ///
        /// Pass `resume: true` when the member actually continues the draft, rather than only being shown that one
        /// exists. Doing so records the moment as the current step's start, so the time the draft sat untouched is
        /// not counted as time the member spent answering it.
        public var resumableClaimIntent: ResumableClaimIntent? { __data["resumableClaimIntent"] }

        /// CurrentMember.ResumableClaimIntent
        ///
        /// Parent Type: `ClaimIntent`
        nonisolated public struct ResumableClaimIntent: OctopusGraphQL.SelectionSet {
          @_spi(Unsafe) public let __data: DataDict
          @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

          @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { OctopusGraphQL.Objects.ClaimIntent }
          @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
            .field("__typename", String.self),
            .field("previousSteps", [PreviousStep].self),
            .fragment(ClaimIntentFragment.self),
          ] }
          @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
            ClaimIntentStartWithPreviousStepsQuery.Data.CurrentMember.ResumableClaimIntent.self,
            ClaimIntentFragment.self
          ] }

          /// All steps that have been taken before the current step. These typically include "current value" data.
          ///
          /// WARNING: Only query these once when resuming an old intent, as they can be quite expensive to compute.
          /// They effectively need to perform all the work of rendering every previous step all at once, which we should
          /// generally avoid when going through the flow normally.
          public var previousSteps: [PreviousStep] { __data["previousSteps"] }
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

          /// CurrentMember.ResumableClaimIntent.PreviousStep
          ///
          /// Parent Type: `ClaimIntentStep`
          nonisolated public struct PreviousStep: OctopusGraphQL.SelectionSet {
            @_spi(Unsafe) public let __data: DataDict
            @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

            @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { OctopusGraphQL.Objects.ClaimIntentStep }
            @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
              .field("__typename", String.self),
              .fragment(ClaimIntentStepFragment.self),
            ] }
            @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
              ClaimIntentStartWithPreviousStepsQuery.Data.CurrentMember.ResumableClaimIntent.PreviousStep.self,
              ClaimIntentStepFragment.self
            ] }

            public var id: OctopusGraphQL.ID { __data["id"] }
            public var text: String? { __data["text"] }
            public var isRegrettable: Bool { __data["isRegrettable"] }
            public var hint: String? { __data["hint"] }
            public var content: Content { __data["content"] }

            public struct Fragments: FragmentContainer {
              @_spi(Unsafe) public let __data: DataDict
              @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

              public var claimIntentStepFragment: ClaimIntentStepFragment { _toFragment() }
            }

            public typealias Content = ClaimIntentStepFragment.Content
          }

          public typealias CurrentStep = ClaimIntentFragment.CurrentStep

          public typealias CreatedClaim = ClaimIntentFragment.CreatedClaim
        }
      }
    }
  }

}