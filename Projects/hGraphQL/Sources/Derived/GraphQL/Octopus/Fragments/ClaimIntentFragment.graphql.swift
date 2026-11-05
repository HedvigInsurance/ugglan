// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI
@_spi(Execution) @_spi(Unsafe) import ApolloAPI

public extension OctopusGraphQL {
  nonisolated struct ClaimIntentFragment: OctopusGraphQL.SelectionSet, Fragment {
    public static var fragmentDefinition: StaticString {
      #"fragment ClaimIntentFragment on ClaimIntent { __typename id createdAt progress currentStep { __typename ...ClaimIntentStepFragment } createdClaim { __typename ...ClaimFragment } displayName resumable }"#
    }

    @_spi(Unsafe) public let __data: DataDict
    @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

    @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { OctopusGraphQL.Objects.ClaimIntent }
    @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
      .field("__typename", String.self),
      .field("id", OctopusGraphQL.ID.self),
      .field("createdAt", OctopusGraphQL.DateTime.self),
      .field("progress", Double?.self),
      .field("currentStep", CurrentStep?.self),
      .field("createdClaim", CreatedClaim?.self),
      .field("displayName", String?.self),
      .field("resumable", Bool.self),
    ] }
    @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
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

    /// CurrentStep
    ///
    /// Parent Type: `ClaimIntentStep`
    nonisolated public struct CurrentStep: OctopusGraphQL.SelectionSet {
      @_spi(Unsafe) public let __data: DataDict
      @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

      @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { OctopusGraphQL.Objects.ClaimIntentStep }
      @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
        .field("__typename", String.self),
        .fragment(ClaimIntentStepFragment.self),
      ] }
      @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
        ClaimIntentFragment.CurrentStep.self,
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

    /// CreatedClaim
    ///
    /// Parent Type: `Claim`
    nonisolated public struct CreatedClaim: OctopusGraphQL.SelectionSet {
      @_spi(Unsafe) public let __data: DataDict
      @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

      @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { OctopusGraphQL.Objects.Claim }
      @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
        .field("__typename", String.self),
        .fragment(ClaimFragment.self),
      ] }
      @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
        ClaimIntentFragment.CreatedClaim.self,
        ClaimFragment.self
      ] }

      /// Use this relative path as the target for file uploads.
      ///
      /// This needs to be placed on top of the base URL of the API (usually `https://gateway.hedvig.com`
      /// or the staging equivalent) like so: "<baseUrl><targetFileUploadUri>".
      ///
      /// This target accepts multipart file uploads, and will automatically attach the uploaded files to the given claim.
      /// Therefore, the same claim can be refreshed in GraphQL and it should be visible in the `Claim.files` field.
      public var targetFileUploadUri: String { __data["targetFileUploadUri"] }
      public var id: OctopusGraphQL.ID { __data["id"] }
      public var outcome: GraphQLEnum<OctopusGraphQL.ClaimOutcome>? { __data["outcome"] }
      public var status: GraphQLEnum<OctopusGraphQL.ClaimStatus>? { __data["status"] }
      public var submittedAt: OctopusGraphQL.DateTime { __data["submittedAt"] }
      public var audioUrl: String? { __data["audioUrl"] }
      public var memberFreeText: String? { __data["memberFreeText"] }
      public var payoutAmount: PayoutAmount? { __data["payoutAmount"] }
      /// Terms & conditions for the claim found using claims contractId and dateOfOccurrence, otherwise null.
      public var productVariant: ProductVariant? { __data["productVariant"] }
      public var claimType: String? { __data["claimType"] }
      /// Return the relevant conversation for this claim.
      ///
      /// These conversations can be one of two kinds:
      /// - either it will be a dedicated conversation for this specific claim
      /// - or it will be the "legacy conversation", containing the entire old chat history
      ///
      /// The first one will be given for claims that are newer, created after the release of conversations.
      /// The second one for all other (older) claims.
      public var conversation: Conversation { __data["conversation"] }
      public var appealInstructionsUrl: String? { __data["appealInstructionsUrl"] }
      public var isUploadingFilesEnabled: Bool { __data["isUploadingFilesEnabled"] }
      public var showClaimClosedFlow: Bool { __data["showClaimClosedFlow"] }
      public var infoText: String? { __data["infoText"] }
      public var displayItems: [DisplayItem] { __data["displayItems"] }
      public var contractId: String? { __data["contractId"] }

      public struct Fragments: FragmentContainer {
        @_spi(Unsafe) public let __data: DataDict
        @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

        public var claimFragment: ClaimFragment { _toFragment() }
      }

      public typealias PayoutAmount = ClaimFragment.PayoutAmount

      public typealias ProductVariant = ClaimFragment.ProductVariant

      public typealias Conversation = ClaimFragment.Conversation

      public typealias DisplayItem = ClaimFragment.DisplayItem
    }
  }

}