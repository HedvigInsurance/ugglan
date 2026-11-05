// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI
@_spi(Execution) @_spi(Unsafe) import ApolloAPI

public extension OctopusGraphQL {
  nonisolated struct ClaimIntentStepContentFragment: OctopusGraphQL.SelectionSet, Fragment {
    public static var fragmentDefinition: StaticString {
      #"fragment ClaimIntentStepContentFragment on ClaimIntentStepContent { __typename ... on ClaimIntentStepContentDeflection { ...DeflectFragment } ... on ClaimIntentStepContentForm { fields { __typename ...ClaimIntentStepContentFormFieldFragment } isSkippable } ... on ClaimIntentStepContentTask { description isCompleted } ... on ClaimIntentStepContentAudioRecording { uploadUri freeTextMaxLength freeTextMinLength currentAudioUrl currentFreeText isSkippable } ... on ClaimIntentStepContentFileUpload { uploadUri currentFiles { __typename id url contentType fileName } isSkippable } ... on ClaimIntentStepContentSummary { items { __typename title value } freeTexts audioRecordings { __typename url } fileUploads { __typename url contentType fileName } keyDetails { __typename title value } answers { __typename title value { __typename ... on ClaimIntentStepContentSummaryAnswerText { text } ... on ClaimIntentStepContentSummaryAnswerAudio { url transcript } ... on ClaimIntentStepContentSummaryAnswerFiles { files { __typename url contentType fileName } } } } } ... on ClaimIntentStepContentSelect { options { __typename id title } isSkippable defaultSelectedId currentSelectedId style } ... on ClaimIntentStepContentDeflectionMessage { message } ... on ClaimIntentStepContentInformation { notice buttonTitle } }"#
    }

    @_spi(Unsafe) public let __data: DataDict
    @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

    @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { OctopusGraphQL.Unions.ClaimIntentStepContent }
    @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
      .field("__typename", String.self),
      .inlineFragment(AsClaimIntentStepContentDeflection.self),
      .inlineFragment(AsClaimIntentStepContentForm.self),
      .inlineFragment(AsClaimIntentStepContentTask.self),
      .inlineFragment(AsClaimIntentStepContentAudioRecording.self),
      .inlineFragment(AsClaimIntentStepContentFileUpload.self),
      .inlineFragment(AsClaimIntentStepContentSummary.self),
      .inlineFragment(AsClaimIntentStepContentSelect.self),
      .inlineFragment(AsClaimIntentStepContentDeflectionMessage.self),
      .inlineFragment(AsClaimIntentStepContentInformation.self),
    ] }
    @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
      ClaimIntentStepContentFragment.self
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

    /// AsClaimIntentStepContentDeflection
    ///
    /// Parent Type: `ClaimIntentStepContentDeflection`
    nonisolated public struct AsClaimIntentStepContentDeflection: OctopusGraphQL.InlineFragment {
      @_spi(Unsafe) public let __data: DataDict
      @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

      public typealias RootEntityType = ClaimIntentStepContentFragment
      @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { OctopusGraphQL.Objects.ClaimIntentStepContentDeflection }
      @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
        .fragment(DeflectFragment.self),
      ] }
      @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
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

        public var deflectFragment: DeflectFragment { _toFragment() }
      }

      public typealias PartnersInfo = DeflectFragment.PartnersInfo

      public typealias Content = DeflectFragment.Content

      public typealias Faq = DeflectFragment.Faq

      public typealias Partner = DeflectFragment.Partner

      public typealias SimplePartner = DeflectFragment.SimplePartner
    }

    /// AsClaimIntentStepContentForm
    ///
    /// Parent Type: `ClaimIntentStepContentForm`
    nonisolated public struct AsClaimIntentStepContentForm: OctopusGraphQL.InlineFragment {
      @_spi(Unsafe) public let __data: DataDict
      @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

      public typealias RootEntityType = ClaimIntentStepContentFragment
      @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { OctopusGraphQL.Objects.ClaimIntentStepContentForm }
      @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
        .field("fields", [Field].self),
        .field("isSkippable", Bool.self),
      ] }
      @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
        ClaimIntentStepContentFragment.self,
        ClaimIntentStepContentFragment.AsClaimIntentStepContentForm.self
      ] }

      public var fields: [Field] { __data["fields"] }
      public var isSkippable: Bool { __data["isSkippable"] }

      /// AsClaimIntentStepContentForm.Field
      ///
      /// Parent Type: `ClaimIntentStepContentFormField`
      nonisolated public struct Field: OctopusGraphQL.SelectionSet {
        @_spi(Unsafe) public let __data: DataDict
        @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

        @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { OctopusGraphQL.Objects.ClaimIntentStepContentFormField }
        @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
          .field("__typename", String.self),
          .fragment(ClaimIntentStepContentFormFieldFragment.self),
        ] }
        @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
          ClaimIntentStepContentFragment.AsClaimIntentStepContentForm.Field.self,
          ClaimIntentStepContentFormFieldFragment.self
        ] }

        /// Use the ID when submitting a value for this field.
        public var id: OctopusGraphQL.ID { __data["id"] }
        /// Indicates what kind of form field this is. Specific form fields can be either present or null depending on this
        /// type - such as `options` existing if type is SINGLE_SELECT.
        public var type: GraphQLEnum<OctopusGraphQL.ClaimIntentStepContentFormFieldType> { __data["type"] }
        /// Localized display title of this field.
        public var title: String { __data["title"] }
        /// Optional printed context on the side of the field. Typical value would be a currency like 'SEK'.
        public var suffix: String? { __data["suffix"] }
        /// If true, must contain a value when submitted.
        public var isRequired: Bool { __data["isRequired"] }
        /// A list of selectable options for field types such as SINGLE_SELECT.
        public var options: [Option]? { __data["options"] }
        /// If there are default values, they will show up in this array. Empty means no default value.
        public var defaultValues: [OctopusGraphQL.ClaimIntentStepContentFormFieldValue] { __data["defaultValues"] }
        /// These are the values that the user has submitted for this field.
        public var currentValues: [OctopusGraphQL.ClaimIntentStepContentFormFieldValue] { __data["currentValues"] }
        /// If type is SEARCH, then this will be present.
        public var searchData: SearchData? { __data["searchData"] }
        /// If present - the minimal value this field can hold.
        public var minValue: OctopusGraphQL.ClaimIntentStepContentFormFieldValue? { __data["minValue"] }
        /// If present - the maximal value this field can hold.
        public var maxValue: OctopusGraphQL.ClaimIntentStepContentFormFieldValue? { __data["maxValue"] }

        public struct Fragments: FragmentContainer {
          @_spi(Unsafe) public let __data: DataDict
          @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

          public var claimIntentStepContentFormFieldFragment: ClaimIntentStepContentFormFieldFragment { _toFragment() }
        }

        public typealias Option = ClaimIntentStepContentFormFieldFragment.Option

        public typealias SearchData = ClaimIntentStepContentFormFieldFragment.SearchData
      }
    }

    /// AsClaimIntentStepContentTask
    ///
    /// Parent Type: `ClaimIntentStepContentTask`
    nonisolated public struct AsClaimIntentStepContentTask: OctopusGraphQL.InlineFragment {
      @_spi(Unsafe) public let __data: DataDict
      @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

      public typealias RootEntityType = ClaimIntentStepContentFragment
      @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { OctopusGraphQL.Objects.ClaimIntentStepContentTask }
      @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
        .field("description", String.self),
        .field("isCompleted", Bool.self),
      ] }
      @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
        ClaimIntentStepContentFragment.self,
        ClaimIntentStepContentFragment.AsClaimIntentStepContentTask.self
      ] }

      public var description: String { __data["description"] }
      public var isCompleted: Bool { __data["isCompleted"] }
    }

    /// AsClaimIntentStepContentAudioRecording
    ///
    /// Parent Type: `ClaimIntentStepContentAudioRecording`
    nonisolated public struct AsClaimIntentStepContentAudioRecording: OctopusGraphQL.InlineFragment {
      @_spi(Unsafe) public let __data: DataDict
      @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

      public typealias RootEntityType = ClaimIntentStepContentFragment
      @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { OctopusGraphQL.Objects.ClaimIntentStepContentAudioRecording }
      @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
        .field("uploadUri", String.self),
        .field("freeTextMaxLength", Int.self),
        .field("freeTextMinLength", Int.self),
        .field("currentAudioUrl", OctopusGraphQL.Url?.self),
        .field("currentFreeText", String?.self),
        .field("isSkippable", Bool.self),
      ] }
      @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
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
    }

    /// AsClaimIntentStepContentFileUpload
    ///
    /// Parent Type: `ClaimIntentStepContentFileUpload`
    nonisolated public struct AsClaimIntentStepContentFileUpload: OctopusGraphQL.InlineFragment {
      @_spi(Unsafe) public let __data: DataDict
      @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

      public typealias RootEntityType = ClaimIntentStepContentFragment
      @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { OctopusGraphQL.Objects.ClaimIntentStepContentFileUpload }
      @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
        .field("uploadUri", String.self),
        .field("currentFiles", [CurrentFile]?.self),
        .field("isSkippable", Bool.self),
      ] }
      @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
        ClaimIntentStepContentFragment.self,
        ClaimIntentStepContentFragment.AsClaimIntentStepContentFileUpload.self
      ] }

      /// The relative URI towards where one should upload the files.
      public var uploadUri: String { __data["uploadUri"] }
      /// Current files uploaded by the user.
      public var currentFiles: [CurrentFile]? { __data["currentFiles"] }
      public var isSkippable: Bool { __data["isSkippable"] }

      /// AsClaimIntentStepContentFileUpload.CurrentFile
      ///
      /// Parent Type: `ClaimIntentStepContentFileUploadFile`
      nonisolated public struct CurrentFile: OctopusGraphQL.SelectionSet {
        @_spi(Unsafe) public let __data: DataDict
        @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

        @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { OctopusGraphQL.Objects.ClaimIntentStepContentFileUploadFile }
        @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
          .field("__typename", String.self),
          .field("id", OctopusGraphQL.ID.self),
          .field("url", OctopusGraphQL.Url.self),
          .field("contentType", String.self),
          .field("fileName", String.self),
        ] }
        @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
          ClaimIntentStepContentFragment.AsClaimIntentStepContentFileUpload.CurrentFile.self
        ] }

        public var id: OctopusGraphQL.ID { __data["id"] }
        public var url: OctopusGraphQL.Url { __data["url"] }
        public var contentType: String { __data["contentType"] }
        public var fileName: String { __data["fileName"] }
      }
    }

    /// AsClaimIntentStepContentSummary
    ///
    /// Parent Type: `ClaimIntentStepContentSummary`
    nonisolated public struct AsClaimIntentStepContentSummary: OctopusGraphQL.InlineFragment {
      @_spi(Unsafe) public let __data: DataDict
      @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

      public typealias RootEntityType = ClaimIntentStepContentFragment
      @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { OctopusGraphQL.Objects.ClaimIntentStepContentSummary }
      @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
        .field("items", [Item].self),
        .field("freeTexts", [String].self),
        .field("audioRecordings", [AudioRecording].self),
        .field("fileUploads", [FileUpload].self),
        .field("keyDetails", [KeyDetail].self),
        .field("answers", [Answer].self),
      ] }
      @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
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

      /// AsClaimIntentStepContentSummary.Item
      ///
      /// Parent Type: `ClaimIntentStepContentSummaryItem`
      nonisolated public struct Item: OctopusGraphQL.SelectionSet {
        @_spi(Unsafe) public let __data: DataDict
        @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

        @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { OctopusGraphQL.Objects.ClaimIntentStepContentSummaryItem }
        @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
          .field("__typename", String.self),
          .field("title", String.self),
          .field("value", String.self),
        ] }
        @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
          ClaimIntentStepContentFragment.AsClaimIntentStepContentSummary.Item.self
        ] }

        public var title: String { __data["title"] }
        public var value: String { __data["value"] }
      }

      /// AsClaimIntentStepContentSummary.AudioRecording
      ///
      /// Parent Type: `ClaimIntentStepContentSummaryAudioRecording`
      nonisolated public struct AudioRecording: OctopusGraphQL.SelectionSet {
        @_spi(Unsafe) public let __data: DataDict
        @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

        @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { OctopusGraphQL.Objects.ClaimIntentStepContentSummaryAudioRecording }
        @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
          .field("__typename", String.self),
          .field("url", OctopusGraphQL.Url.self),
        ] }
        @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
          ClaimIntentStepContentFragment.AsClaimIntentStepContentSummary.AudioRecording.self
        ] }

        public var url: OctopusGraphQL.Url { __data["url"] }
      }

      /// AsClaimIntentStepContentSummary.FileUpload
      ///
      /// Parent Type: `ClaimIntentStepContentSummaryFileUpload`
      nonisolated public struct FileUpload: OctopusGraphQL.SelectionSet {
        @_spi(Unsafe) public let __data: DataDict
        @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

        @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { OctopusGraphQL.Objects.ClaimIntentStepContentSummaryFileUpload }
        @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
          .field("__typename", String.self),
          .field("url", OctopusGraphQL.Url.self),
          .field("contentType", String.self),
          .field("fileName", String.self),
        ] }
        @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
          ClaimIntentStepContentFragment.AsClaimIntentStepContentSummary.FileUpload.self
        ] }

        public var url: OctopusGraphQL.Url { __data["url"] }
        public var contentType: String { __data["contentType"] }
        public var fileName: String { __data["fileName"] }
      }

      /// AsClaimIntentStepContentSummary.KeyDetail
      ///
      /// Parent Type: `ClaimIntentStepContentSummaryItem`
      nonisolated public struct KeyDetail: OctopusGraphQL.SelectionSet {
        @_spi(Unsafe) public let __data: DataDict
        @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

        @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { OctopusGraphQL.Objects.ClaimIntentStepContentSummaryItem }
        @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
          .field("__typename", String.self),
          .field("title", String.self),
          .field("value", String.self),
        ] }
        @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
          ClaimIntentStepContentFragment.AsClaimIntentStepContentSummary.KeyDetail.self
        ] }

        public var title: String { __data["title"] }
        public var value: String { __data["value"] }
      }

      /// AsClaimIntentStepContentSummary.Answer
      ///
      /// Parent Type: `ClaimIntentStepContentSummaryAnswer`
      nonisolated public struct Answer: OctopusGraphQL.SelectionSet {
        @_spi(Unsafe) public let __data: DataDict
        @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

        @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { OctopusGraphQL.Objects.ClaimIntentStepContentSummaryAnswer }
        @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
          .field("__typename", String.self),
          .field("title", String.self),
          .field("value", Value.self),
        ] }
        @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
          ClaimIntentStepContentFragment.AsClaimIntentStepContentSummary.Answer.self
        ] }

        /// The question as it was asked to the member.
        public var title: String { __data["title"] }
        public var value: Value { __data["value"] }

        /// AsClaimIntentStepContentSummary.Answer.Value
        ///
        /// Parent Type: `ClaimIntentStepContentSummaryAnswerValue`
        nonisolated public struct Value: OctopusGraphQL.SelectionSet {
          @_spi(Unsafe) public let __data: DataDict
          @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

          @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { OctopusGraphQL.Unions.ClaimIntentStepContentSummaryAnswerValue }
          @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
            .field("__typename", String.self),
            .inlineFragment(AsClaimIntentStepContentSummaryAnswerText.self),
            .inlineFragment(AsClaimIntentStepContentSummaryAnswerAudio.self),
            .inlineFragment(AsClaimIntentStepContentSummaryAnswerFiles.self),
          ] }
          @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
            ClaimIntentStepContentFragment.AsClaimIntentStepContentSummary.Answer.Value.self
          ] }

          public var asClaimIntentStepContentSummaryAnswerText: AsClaimIntentStepContentSummaryAnswerText? { _asInlineFragment() }
          public var asClaimIntentStepContentSummaryAnswerAudio: AsClaimIntentStepContentSummaryAnswerAudio? { _asInlineFragment() }
          public var asClaimIntentStepContentSummaryAnswerFiles: AsClaimIntentStepContentSummaryAnswerFiles? { _asInlineFragment() }

          /// AsClaimIntentStepContentSummary.Answer.Value.AsClaimIntentStepContentSummaryAnswerText
          ///
          /// Parent Type: `ClaimIntentStepContentSummaryAnswerText`
          nonisolated public struct AsClaimIntentStepContentSummaryAnswerText: OctopusGraphQL.InlineFragment {
            @_spi(Unsafe) public let __data: DataDict
            @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

            public typealias RootEntityType = ClaimIntentStepContentFragment.AsClaimIntentStepContentSummary.Answer.Value
            @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { OctopusGraphQL.Objects.ClaimIntentStepContentSummaryAnswerText }
            @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
              .field("text", String.self),
            ] }
            @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
              ClaimIntentStepContentFragment.AsClaimIntentStepContentSummary.Answer.Value.self,
              ClaimIntentStepContentFragment.AsClaimIntentStepContentSummary.Answer.Value.AsClaimIntentStepContentSummaryAnswerText.self
            ] }

            public var text: String { __data["text"] }
          }

          /// AsClaimIntentStepContentSummary.Answer.Value.AsClaimIntentStepContentSummaryAnswerAudio
          ///
          /// Parent Type: `ClaimIntentStepContentSummaryAnswerAudio`
          nonisolated public struct AsClaimIntentStepContentSummaryAnswerAudio: OctopusGraphQL.InlineFragment {
            @_spi(Unsafe) public let __data: DataDict
            @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

            public typealias RootEntityType = ClaimIntentStepContentFragment.AsClaimIntentStepContentSummary.Answer.Value
            @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { OctopusGraphQL.Objects.ClaimIntentStepContentSummaryAnswerAudio }
            @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
              .field("url", OctopusGraphQL.Url.self),
              .field("transcript", String?.self),
            ] }
            @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
              ClaimIntentStepContentFragment.AsClaimIntentStepContentSummary.Answer.Value.self,
              ClaimIntentStepContentFragment.AsClaimIntentStepContentSummary.Answer.Value.AsClaimIntentStepContentSummaryAnswerAudio.self
            ] }

            public var url: OctopusGraphQL.Url { __data["url"] }
            /// Transcript of the recording, when available.
            public var transcript: String? { __data["transcript"] }
          }

          /// AsClaimIntentStepContentSummary.Answer.Value.AsClaimIntentStepContentSummaryAnswerFiles
          ///
          /// Parent Type: `ClaimIntentStepContentSummaryAnswerFiles`
          nonisolated public struct AsClaimIntentStepContentSummaryAnswerFiles: OctopusGraphQL.InlineFragment {
            @_spi(Unsafe) public let __data: DataDict
            @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

            public typealias RootEntityType = ClaimIntentStepContentFragment.AsClaimIntentStepContentSummary.Answer.Value
            @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { OctopusGraphQL.Objects.ClaimIntentStepContentSummaryAnswerFiles }
            @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
              .field("files", [File].self),
            ] }
            @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
              ClaimIntentStepContentFragment.AsClaimIntentStepContentSummary.Answer.Value.self,
              ClaimIntentStepContentFragment.AsClaimIntentStepContentSummary.Answer.Value.AsClaimIntentStepContentSummaryAnswerFiles.self
            ] }

            public var files: [File] { __data["files"] }

            /// AsClaimIntentStepContentSummary.Answer.Value.AsClaimIntentStepContentSummaryAnswerFiles.File
            ///
            /// Parent Type: `ClaimIntentStepContentSummaryFileUpload`
            nonisolated public struct File: OctopusGraphQL.SelectionSet {
              @_spi(Unsafe) public let __data: DataDict
              @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

              @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { OctopusGraphQL.Objects.ClaimIntentStepContentSummaryFileUpload }
              @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
                .field("__typename", String.self),
                .field("url", OctopusGraphQL.Url.self),
                .field("contentType", String.self),
                .field("fileName", String.self),
              ] }
              @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
                ClaimIntentStepContentFragment.AsClaimIntentStepContentSummary.Answer.Value.AsClaimIntentStepContentSummaryAnswerFiles.File.self
              ] }

              public var url: OctopusGraphQL.Url { __data["url"] }
              public var contentType: String { __data["contentType"] }
              public var fileName: String { __data["fileName"] }
            }
          }
        }
      }
    }

    /// AsClaimIntentStepContentSelect
    ///
    /// Parent Type: `ClaimIntentStepContentSelect`
    nonisolated public struct AsClaimIntentStepContentSelect: OctopusGraphQL.InlineFragment {
      @_spi(Unsafe) public let __data: DataDict
      @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

      public typealias RootEntityType = ClaimIntentStepContentFragment
      @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { OctopusGraphQL.Objects.ClaimIntentStepContentSelect }
      @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
        .field("options", [Option].self),
        .field("isSkippable", Bool.self),
        .field("defaultSelectedId", OctopusGraphQL.ID?.self),
        .field("currentSelectedId", OctopusGraphQL.ID?.self),
        .field("style", GraphQLEnum<OctopusGraphQL.ClaimIntentStepContentSelectStyle>.self),
      ] }
      @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
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

      /// AsClaimIntentStepContentSelect.Option
      ///
      /// Parent Type: `ClaimIntentStepContentSelectOption`
      nonisolated public struct Option: OctopusGraphQL.SelectionSet {
        @_spi(Unsafe) public let __data: DataDict
        @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

        @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { OctopusGraphQL.Objects.ClaimIntentStepContentSelectOption }
        @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
          .field("__typename", String.self),
          .field("id", OctopusGraphQL.ID.self),
          .field("title", String.self),
        ] }
        @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
          ClaimIntentStepContentFragment.AsClaimIntentStepContentSelect.Option.self
        ] }

        /// The ID for this option. Used when submitting the choice
        public var id: OctopusGraphQL.ID { __data["id"] }
        /// Rendered title of the choice
        public var title: String { __data["title"] }
      }
    }

    /// AsClaimIntentStepContentDeflectionMessage
    ///
    /// Parent Type: `ClaimIntentStepContentDeflectionMessage`
    nonisolated public struct AsClaimIntentStepContentDeflectionMessage: OctopusGraphQL.InlineFragment {
      @_spi(Unsafe) public let __data: DataDict
      @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

      public typealias RootEntityType = ClaimIntentStepContentFragment
      @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { OctopusGraphQL.Objects.ClaimIntentStepContentDeflectionMessage }
      @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
        .field("message", String.self),
      ] }
      @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
        ClaimIntentStepContentFragment.self,
        ClaimIntentStepContentFragment.AsClaimIntentStepContentDeflectionMessage.self
      ] }

      public var message: String { __data["message"] }
    }

    /// AsClaimIntentStepContentInformation
    ///
    /// Parent Type: `ClaimIntentStepContentInformation`
    nonisolated public struct AsClaimIntentStepContentInformation: OctopusGraphQL.InlineFragment {
      @_spi(Unsafe) public let __data: DataDict
      @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

      public typealias RootEntityType = ClaimIntentStepContentFragment
      @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { OctopusGraphQL.Objects.ClaimIntentStepContentInformation }
      @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
        .field("notice", String.self),
        .field("buttonTitle", String.self),
      ] }
      @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
        ClaimIntentStepContentFragment.self,
        ClaimIntentStepContentFragment.AsClaimIntentStepContentInformation.self
      ] }

      public var notice: String { __data["notice"] }
      public var buttonTitle: String { __data["buttonTitle"] }
    }
  }

}