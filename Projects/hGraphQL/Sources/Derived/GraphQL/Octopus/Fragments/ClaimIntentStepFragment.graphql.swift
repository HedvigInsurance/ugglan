// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI
@_spi(Execution) @_spi(Unsafe) import ApolloAPI

public extension OctopusGraphQL {
  nonisolated struct ClaimIntentStepFragment: OctopusGraphQL.SelectionSet, Fragment {
    public static var fragmentDefinition: StaticString {
      #"fragment ClaimIntentStepFragment on ClaimIntentStep { __typename id text isRegrettable hint content { __typename ...ClaimIntentStepContentFragment } }"#
    }

    @_spi(Unsafe) public let __data: DataDict
    @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

    @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { OctopusGraphQL.Objects.ClaimIntentStep }
    @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
      .field("__typename", String.self),
      .field("id", OctopusGraphQL.ID.self),
      .field("text", String?.self),
      .field("isRegrettable", Bool.self),
      .field("hint", String?.self),
      .field("content", Content.self),
    ] }
    @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
      ClaimIntentStepFragment.self
    ] }

    public var id: OctopusGraphQL.ID { __data["id"] }
    public var text: String? { __data["text"] }
    public var isRegrettable: Bool { __data["isRegrettable"] }
    public var hint: String? { __data["hint"] }
    public var content: Content { __data["content"] }

    /// Content
    ///
    /// Parent Type: `ClaimIntentStepContent`
    nonisolated public struct Content: OctopusGraphQL.SelectionSet {
      @_spi(Unsafe) public let __data: DataDict
      @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

      @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { OctopusGraphQL.Unions.ClaimIntentStepContent }
      @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
        .field("__typename", String.self),
        .fragment(ClaimIntentStepContentFragment.self),
      ] }
      @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
        ClaimIntentStepFragment.Content.self
      ] }

      public var asClaimIntentStepContentDeflection: AsClaimIntentStepContentDeflection? { _asInlineFragment() }
      public var asClaimIntentStepContentForm: AsClaimIntentStepContentForm? { _asInlineFragment() }
      public var asClaimIntentStepContentTask: AsClaimIntentStepContentTask? { _asInlineFragment() }
      public var asClaimIntentStepContentAudioRecording: AsClaimIntentStepContentAudioRecording? { _asInlineFragment() }
      public var asClaimIntentStepContentFileUpload: AsClaimIntentStepContentFileUpload? { _asInlineFragment() }
      public var asClaimIntentStepContentSummary: AsClaimIntentStepContentSummary? { _asInlineFragment() }
      public var asClaimIntentStepContentSelect: AsClaimIntentStepContentSelect? { _asInlineFragment() }
      public var asClaimIntentStepContentDeflectionMessage: AsClaimIntentStepContentDeflectionMessage? { _asInlineFragment() }
      public var asClaimIntentStepContentInformation: AsClaimIntentStepContentInformation? { _asInlineFragment() }

      public struct Fragments: FragmentContainer {
        @_spi(Unsafe) public let __data: DataDict
        @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

        public var claimIntentStepContentFragment: ClaimIntentStepContentFragment { _toFragment() }
      }

      /// Content.AsClaimIntentStepContentDeflection
      ///
      /// Parent Type: `ClaimIntentStepContentDeflection`
      nonisolated public struct AsClaimIntentStepContentDeflection: OctopusGraphQL.InlineFragment, ApolloAPI.CompositeInlineFragment {
        @_spi(Unsafe) public let __data: DataDict
        @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

        public typealias RootEntityType = ClaimIntentStepFragment.Content
        @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { OctopusGraphQL.Objects.ClaimIntentStepContentDeflection }
        @_spi(Execution) public static var __mergedSources: [any ApolloAPI.SelectionSet.Type] { [
          ClaimIntentStepFragment.Content.self,
          ClaimIntentStepContentFragment.AsClaimIntentStepContentDeflection.self,
          DeflectFragment.self
        ] }
        @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
          ClaimIntentStepFragment.Content.self,
          ClaimIntentStepFragment.Content.AsClaimIntentStepContentDeflection.self,
          ClaimIntentStepContentFragment.self,
          ClaimIntentStepContentFragment.AsClaimIntentStepContentDeflection.self,
          DeflectFragment.self
        ] }

        public var infoText: String? { __data["infoText"] }
        public var warningText: String? { __data["warningText"] }
        public var partnersInfo: PartnersInfo? { __data["partnersInfo"] }
        public var content: Content { __data["content"] }
        public var faq: [Faq] { __data["faq"] }
        public var title: String? { __data["title"] }
        public var partners: [Partner] { __data["partners"] }
        public var simplePartners: [SimplePartner] { __data["simplePartners"] }
        public var buttonTitle: String { __data["buttonTitle"] }

        public struct Fragments: FragmentContainer {
          @_spi(Unsafe) public let __data: DataDict
          @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

          public var claimIntentStepContentFragment: ClaimIntentStepContentFragment { _toFragment() }
          public var deflectFragment: DeflectFragment { _toFragment() }
        }

        public typealias PartnersInfo = DeflectFragment.PartnersInfo

        public typealias Content = DeflectFragment.Content

        public typealias Faq = DeflectFragment.Faq

        public typealias Partner = DeflectFragment.Partner

        public typealias SimplePartner = DeflectFragment.SimplePartner
      }

      /// Content.AsClaimIntentStepContentForm
      ///
      /// Parent Type: `ClaimIntentStepContentForm`
      nonisolated public struct AsClaimIntentStepContentForm: OctopusGraphQL.InlineFragment, ApolloAPI.CompositeInlineFragment {
        @_spi(Unsafe) public let __data: DataDict
        @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

        public typealias RootEntityType = ClaimIntentStepFragment.Content
        @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { OctopusGraphQL.Objects.ClaimIntentStepContentForm }
        @_spi(Execution) public static var __mergedSources: [any ApolloAPI.SelectionSet.Type] { [
          ClaimIntentStepFragment.Content.self,
          ClaimIntentStepContentFragment.AsClaimIntentStepContentForm.self
        ] }
        @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
          ClaimIntentStepFragment.Content.self,
          ClaimIntentStepFragment.Content.AsClaimIntentStepContentForm.self,
          ClaimIntentStepContentFragment.self,
          ClaimIntentStepContentFragment.AsClaimIntentStepContentForm.self
        ] }

        public var fields: [Field] { __data["fields"] }
        public var isSkippable: Bool { __data["isSkippable"] }

        public struct Fragments: FragmentContainer {
          @_spi(Unsafe) public let __data: DataDict
          @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

          public var claimIntentStepContentFragment: ClaimIntentStepContentFragment { _toFragment() }
        }

        public typealias Field = ClaimIntentStepContentFragment.AsClaimIntentStepContentForm.Field
      }

      /// Content.AsClaimIntentStepContentTask
      ///
      /// Parent Type: `ClaimIntentStepContentTask`
      nonisolated public struct AsClaimIntentStepContentTask: OctopusGraphQL.InlineFragment, ApolloAPI.CompositeInlineFragment {
        @_spi(Unsafe) public let __data: DataDict
        @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

        public typealias RootEntityType = ClaimIntentStepFragment.Content
        @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { OctopusGraphQL.Objects.ClaimIntentStepContentTask }
        @_spi(Execution) public static var __mergedSources: [any ApolloAPI.SelectionSet.Type] { [
          ClaimIntentStepFragment.Content.self,
          ClaimIntentStepContentFragment.AsClaimIntentStepContentTask.self
        ] }
        @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
          ClaimIntentStepFragment.Content.self,
          ClaimIntentStepFragment.Content.AsClaimIntentStepContentTask.self,
          ClaimIntentStepContentFragment.self,
          ClaimIntentStepContentFragment.AsClaimIntentStepContentTask.self
        ] }

        public var description: String { __data["description"] }
        public var isCompleted: Bool { __data["isCompleted"] }

        public struct Fragments: FragmentContainer {
          @_spi(Unsafe) public let __data: DataDict
          @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

          public var claimIntentStepContentFragment: ClaimIntentStepContentFragment { _toFragment() }
        }
      }

      /// Content.AsClaimIntentStepContentAudioRecording
      ///
      /// Parent Type: `ClaimIntentStepContentAudioRecording`
      nonisolated public struct AsClaimIntentStepContentAudioRecording: OctopusGraphQL.InlineFragment, ApolloAPI.CompositeInlineFragment {
        @_spi(Unsafe) public let __data: DataDict
        @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

        public typealias RootEntityType = ClaimIntentStepFragment.Content
        @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { OctopusGraphQL.Objects.ClaimIntentStepContentAudioRecording }
        @_spi(Execution) public static var __mergedSources: [any ApolloAPI.SelectionSet.Type] { [
          ClaimIntentStepFragment.Content.self,
          ClaimIntentStepContentFragment.AsClaimIntentStepContentAudioRecording.self
        ] }
        @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
          ClaimIntentStepFragment.Content.self,
          ClaimIntentStepFragment.Content.AsClaimIntentStepContentAudioRecording.self,
          ClaimIntentStepContentFragment.self,
          ClaimIntentStepContentFragment.AsClaimIntentStepContentAudioRecording.self
        ] }

        /// The relative URI towards where one should upload the audio recording.
        public var uploadUri: String { __data["uploadUri"] }
        public var freeTextMaxLength: Int { __data["freeTextMaxLength"] }
        public var freeTextMinLength: Int { __data["freeTextMinLength"] }
        /// URL of the audio uploaded by the user.
        public var currentAudioUrl: OctopusGraphQL.Url? { __data["currentAudioUrl"] }
        /// Free text submitted by the user.
        public var currentFreeText: String? { __data["currentFreeText"] }
        public var isSkippable: Bool { __data["isSkippable"] }

        public struct Fragments: FragmentContainer {
          @_spi(Unsafe) public let __data: DataDict
          @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

          public var claimIntentStepContentFragment: ClaimIntentStepContentFragment { _toFragment() }
        }
      }

      /// Content.AsClaimIntentStepContentFileUpload
      ///
      /// Parent Type: `ClaimIntentStepContentFileUpload`
      nonisolated public struct AsClaimIntentStepContentFileUpload: OctopusGraphQL.InlineFragment, ApolloAPI.CompositeInlineFragment {
        @_spi(Unsafe) public let __data: DataDict
        @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

        public typealias RootEntityType = ClaimIntentStepFragment.Content
        @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { OctopusGraphQL.Objects.ClaimIntentStepContentFileUpload }
        @_spi(Execution) public static var __mergedSources: [any ApolloAPI.SelectionSet.Type] { [
          ClaimIntentStepFragment.Content.self,
          ClaimIntentStepContentFragment.AsClaimIntentStepContentFileUpload.self
        ] }
        @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
          ClaimIntentStepFragment.Content.self,
          ClaimIntentStepFragment.Content.AsClaimIntentStepContentFileUpload.self,
          ClaimIntentStepContentFragment.self,
          ClaimIntentStepContentFragment.AsClaimIntentStepContentFileUpload.self
        ] }

        /// The relative URI towards where one should upload the files.
        public var uploadUri: String { __data["uploadUri"] }
        /// Current files uploaded by the user.
        public var currentFiles: [CurrentFile]? { __data["currentFiles"] }
        public var isSkippable: Bool { __data["isSkippable"] }

        public struct Fragments: FragmentContainer {
          @_spi(Unsafe) public let __data: DataDict
          @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

          public var claimIntentStepContentFragment: ClaimIntentStepContentFragment { _toFragment() }
        }

        public typealias CurrentFile = ClaimIntentStepContentFragment.AsClaimIntentStepContentFileUpload.CurrentFile
      }

      /// Content.AsClaimIntentStepContentSummary
      ///
      /// Parent Type: `ClaimIntentStepContentSummary`
      nonisolated public struct AsClaimIntentStepContentSummary: OctopusGraphQL.InlineFragment, ApolloAPI.CompositeInlineFragment {
        @_spi(Unsafe) public let __data: DataDict
        @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

        public typealias RootEntityType = ClaimIntentStepFragment.Content
        @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { OctopusGraphQL.Objects.ClaimIntentStepContentSummary }
        @_spi(Execution) public static var __mergedSources: [any ApolloAPI.SelectionSet.Type] { [
          ClaimIntentStepFragment.Content.self,
          ClaimIntentStepContentFragment.AsClaimIntentStepContentSummary.self
        ] }
        @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
          ClaimIntentStepFragment.Content.self,
          ClaimIntentStepFragment.Content.AsClaimIntentStepContentSummary.self,
          ClaimIntentStepContentFragment.self,
          ClaimIntentStepContentFragment.AsClaimIntentStepContentSummary.self
        ] }

        public var items: [Item] { __data["items"] }
        public var freeTexts: [String] { __data["freeTexts"] }
        public var audioRecordings: [AudioRecording] { __data["audioRecordings"] }
        public var fileUploads: [FileUpload] { __data["fileUploads"] }
        /// Key facts for the collapsed "Claim details" card.
        public var keyDetails: [KeyDetail] { __data["keyDetails"] }
        /// All question/answer pairs in the order they were asked.
        /// Rendered behind "Show all answers".
        public var answers: [Answer] { __data["answers"] }

        public struct Fragments: FragmentContainer {
          @_spi(Unsafe) public let __data: DataDict
          @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

          public var claimIntentStepContentFragment: ClaimIntentStepContentFragment { _toFragment() }
        }

        public typealias Item = ClaimIntentStepContentFragment.AsClaimIntentStepContentSummary.Item

        public typealias AudioRecording = ClaimIntentStepContentFragment.AsClaimIntentStepContentSummary.AudioRecording

        public typealias FileUpload = ClaimIntentStepContentFragment.AsClaimIntentStepContentSummary.FileUpload

        public typealias KeyDetail = ClaimIntentStepContentFragment.AsClaimIntentStepContentSummary.KeyDetail

        public typealias Answer = ClaimIntentStepContentFragment.AsClaimIntentStepContentSummary.Answer
      }

      /// Content.AsClaimIntentStepContentSelect
      ///
      /// Parent Type: `ClaimIntentStepContentSelect`
      nonisolated public struct AsClaimIntentStepContentSelect: OctopusGraphQL.InlineFragment, ApolloAPI.CompositeInlineFragment {
        @_spi(Unsafe) public let __data: DataDict
        @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

        public typealias RootEntityType = ClaimIntentStepFragment.Content
        @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { OctopusGraphQL.Objects.ClaimIntentStepContentSelect }
        @_spi(Execution) public static var __mergedSources: [any ApolloAPI.SelectionSet.Type] { [
          ClaimIntentStepFragment.Content.self,
          ClaimIntentStepContentFragment.AsClaimIntentStepContentSelect.self
        ] }
        @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
          ClaimIntentStepFragment.Content.self,
          ClaimIntentStepFragment.Content.AsClaimIntentStepContentSelect.self,
          ClaimIntentStepContentFragment.self,
          ClaimIntentStepContentFragment.AsClaimIntentStepContentSelect.self
        ] }

        /// Selectable options.
        public var options: [Option] { __data["options"] }
        public var isSkippable: Bool { __data["isSkippable"] }
        /// Pre-filled default value.
        public var defaultSelectedId: OctopusGraphQL.ID? { __data["defaultSelectedId"] }
        /// Currently selected value by the user.
        public var currentSelectedId: OctopusGraphQL.ID? { __data["currentSelectedId"] }
        /// Visual style of this selection.
        public var style: GraphQLEnum<OctopusGraphQL.ClaimIntentStepContentSelectStyle> { __data["style"] }

        public struct Fragments: FragmentContainer {
          @_spi(Unsafe) public let __data: DataDict
          @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

          public var claimIntentStepContentFragment: ClaimIntentStepContentFragment { _toFragment() }
        }

        public typealias Option = ClaimIntentStepContentFragment.AsClaimIntentStepContentSelect.Option
      }

      /// Content.AsClaimIntentStepContentDeflectionMessage
      ///
      /// Parent Type: `ClaimIntentStepContentDeflectionMessage`
      nonisolated public struct AsClaimIntentStepContentDeflectionMessage: OctopusGraphQL.InlineFragment, ApolloAPI.CompositeInlineFragment {
        @_spi(Unsafe) public let __data: DataDict
        @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

        public typealias RootEntityType = ClaimIntentStepFragment.Content
        @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { OctopusGraphQL.Objects.ClaimIntentStepContentDeflectionMessage }
        @_spi(Execution) public static var __mergedSources: [any ApolloAPI.SelectionSet.Type] { [
          ClaimIntentStepFragment.Content.self,
          ClaimIntentStepContentFragment.AsClaimIntentStepContentDeflectionMessage.self
        ] }
        @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
          ClaimIntentStepFragment.Content.self,
          ClaimIntentStepFragment.Content.AsClaimIntentStepContentDeflectionMessage.self,
          ClaimIntentStepContentFragment.self,
          ClaimIntentStepContentFragment.AsClaimIntentStepContentDeflectionMessage.self
        ] }

        public var message: String { __data["message"] }

        public struct Fragments: FragmentContainer {
          @_spi(Unsafe) public let __data: DataDict
          @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

          public var claimIntentStepContentFragment: ClaimIntentStepContentFragment { _toFragment() }
        }
      }

      /// Content.AsClaimIntentStepContentInformation
      ///
      /// Parent Type: `ClaimIntentStepContentInformation`
      nonisolated public struct AsClaimIntentStepContentInformation: OctopusGraphQL.InlineFragment, ApolloAPI.CompositeInlineFragment {
        @_spi(Unsafe) public let __data: DataDict
        @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

        public typealias RootEntityType = ClaimIntentStepFragment.Content
        @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { OctopusGraphQL.Objects.ClaimIntentStepContentInformation }
        @_spi(Execution) public static var __mergedSources: [any ApolloAPI.SelectionSet.Type] { [
          ClaimIntentStepFragment.Content.self,
          ClaimIntentStepContentFragment.AsClaimIntentStepContentInformation.self
        ] }
        @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
          ClaimIntentStepFragment.Content.self,
          ClaimIntentStepFragment.Content.AsClaimIntentStepContentInformation.self,
          ClaimIntentStepContentFragment.self,
          ClaimIntentStepContentFragment.AsClaimIntentStepContentInformation.self
        ] }

        public var notice: String { __data["notice"] }
        public var buttonTitle: String { __data["buttonTitle"] }

        public struct Fragments: FragmentContainer {
          @_spi(Unsafe) public let __data: DataDict
          @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

          public var claimIntentStepContentFragment: ClaimIntentStepContentFragment { _toFragment() }
        }
      }
    }
  }

}