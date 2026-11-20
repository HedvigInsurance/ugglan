// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI
@_spi(Execution) @_spi(Unsafe) import ApolloAPI

public extension OctopusGraphQL {
  nonisolated struct ClaimFollowupFragment: OctopusGraphQL.SelectionSet, Fragment {
    public static var fragmentDefinition: StaticString {
      #"fragment ClaimFollowupFragment on ClaimFollowup { __typename id claimId status questions { __typename id text hint cantAnswerLabel state cantAnswerComment content { __typename ... on ClaimFollowupBinary { currentValue } ... on ClaimFollowupFreeText { uploadUri minLength maxLength currentValue currentAudio { __typename id url contentType fileName relevance } } ... on ClaimFollowupDate { currentValue minDate: min maxDate: max } ... on ClaimFollowupNumber { currentValue min max } ... on ClaimFollowupPhoneNumber { currentValue } ... on ClaimFollowupFileUpload { uploadUri currentFiles { __typename id url contentType fileName relevance } } } } }"#
    }

    @_spi(Unsafe) public let __data: DataDict
    @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

    @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { OctopusGraphQL.Objects.ClaimFollowup }
    @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
      .field("__typename", String.self),
      .field("id", OctopusGraphQL.ID.self),
      .field("claimId", OctopusGraphQL.ID.self),
      .field("status", GraphQLEnum<OctopusGraphQL.ClaimFollowupStatus>.self),
      .field("questions", [Question].self),
    ] }
    @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
      ClaimFollowupFragment.self
    ] }

    public var id: OctopusGraphQL.ID { __data["id"] }
    public var claimId: OctopusGraphQL.ID { __data["claimId"] }
    public var status: GraphQLEnum<OctopusGraphQL.ClaimFollowupStatus> { __data["status"] }
    public var questions: [Question] { __data["questions"] }

    /// Question
    ///
    /// Parent Type: `ClaimFollowupQuestion`
    nonisolated public struct Question: OctopusGraphQL.SelectionSet {
      @_spi(Unsafe) public let __data: DataDict
      @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

      @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { OctopusGraphQL.Objects.ClaimFollowupQuestion }
      @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
        .field("__typename", String.self),
        .field("id", OctopusGraphQL.ID.self),
        .field("text", String.self),
        .field("hint", String?.self),
        .field("cantAnswerLabel", String?.self),
        .field("state", GraphQLEnum<OctopusGraphQL.ClaimFollowupQuestionState>.self),
        .field("cantAnswerComment", String?.self),
        .field("content", Content.self),
      ] }
      @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
        ClaimFollowupFragment.Question.self
      ] }

      public var id: OctopusGraphQL.ID { __data["id"] }
      public var text: String { __data["text"] }
      /// An optional line shown under the question, such as which forms of a document are fine.
      public var hint: String? { __data["hint"] }
      /// A short label for this question's own pass button, such as "I don't have a receipt". Null means the app shows its generic one.
      public var cantAnswerLabel: String? { __data["cantAnswerLabel"] }
      public var state: GraphQLEnum<OctopusGraphQL.ClaimFollowupQuestionState> { __data["state"] }
      /// What the member wrote when passing on the question; null unless state is CANT_ANSWER, and optional even then.
      public var cantAnswerComment: String? { __data["cantAnswerComment"] }
      /// The input for this question, carrying the current answer when there is one.
      public var content: Content { __data["content"] }

      /// Question.Content
      ///
      /// Parent Type: `ClaimFollowupQuestionContent`
      nonisolated public struct Content: OctopusGraphQL.SelectionSet {
        @_spi(Unsafe) public let __data: DataDict
        @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

        @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { OctopusGraphQL.Unions.ClaimFollowupQuestionContent }
        @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
          .field("__typename", String.self),
          .inlineFragment(AsClaimFollowupBinary.self),
          .inlineFragment(AsClaimFollowupFreeText.self),
          .inlineFragment(AsClaimFollowupDate.self),
          .inlineFragment(AsClaimFollowupNumber.self),
          .inlineFragment(AsClaimFollowupPhoneNumber.self),
          .inlineFragment(AsClaimFollowupFileUpload.self),
        ] }
        @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
          ClaimFollowupFragment.Question.Content.self
        ] }

        public var asClaimFollowupBinary: AsClaimFollowupBinary? { _asInlineFragment() }
        public var asClaimFollowupFreeText: AsClaimFollowupFreeText? { _asInlineFragment() }
        public var asClaimFollowupDate: AsClaimFollowupDate? { _asInlineFragment() }
        public var asClaimFollowupNumber: AsClaimFollowupNumber? { _asInlineFragment() }
        public var asClaimFollowupPhoneNumber: AsClaimFollowupPhoneNumber? { _asInlineFragment() }
        public var asClaimFollowupFileUpload: AsClaimFollowupFileUpload? { _asInlineFragment() }

        /// Question.Content.AsClaimFollowupBinary
        ///
        /// Parent Type: `ClaimFollowupBinary`
        nonisolated public struct AsClaimFollowupBinary: OctopusGraphQL.InlineFragment {
          @_spi(Unsafe) public let __data: DataDict
          @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

          public typealias RootEntityType = ClaimFollowupFragment.Question.Content
          @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { OctopusGraphQL.Objects.ClaimFollowupBinary }
          @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
            .field("currentValue", String?.self),
          ] }
          @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
            ClaimFollowupFragment.Question.Content.self,
            ClaimFollowupFragment.Question.Content.AsClaimFollowupBinary.self
          ] }

          /// "true" or "false".
          public var currentValue: String? { __data["currentValue"] }
        }

        /// Question.Content.AsClaimFollowupFreeText
        ///
        /// Parent Type: `ClaimFollowupFreeText`
        nonisolated public struct AsClaimFollowupFreeText: OctopusGraphQL.InlineFragment {
          @_spi(Unsafe) public let __data: DataDict
          @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

          public typealias RootEntityType = ClaimFollowupFragment.Question.Content
          @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { OctopusGraphQL.Objects.ClaimFollowupFreeText }
          @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
            .field("uploadUri", String.self),
            .field("minLength", Int.self),
            .field("maxLength", Int.self),
            .field("currentValue", String?.self),
            .field("currentAudio", CurrentAudio?.self),
          ] }
          @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
            ClaimFollowupFragment.Question.Content.self,
            ClaimFollowupFragment.Question.Content.AsClaimFollowupFreeText.self
          ] }

          /// Where to upload a recording.
          public var uploadUri: String { __data["uploadUri"] }
          public var minLength: Int { __data["minLength"] }
          public var maxLength: Int { __data["maxLength"] }
          public var currentValue: String? { __data["currentValue"] }
          /// A spoken answer; set instead of currentValue.
          public var currentAudio: CurrentAudio? { __data["currentAudio"] }

          /// Question.Content.AsClaimFollowupFreeText.CurrentAudio
          ///
          /// Parent Type: `ClaimFollowupFile`
          nonisolated public struct CurrentAudio: OctopusGraphQL.SelectionSet {
            @_spi(Unsafe) public let __data: DataDict
            @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

            @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { OctopusGraphQL.Objects.ClaimFollowupFile }
            @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
              .field("__typename", String.self),
              .field("id", OctopusGraphQL.ID.self),
              .field("url", OctopusGraphQL.Url.self),
              .field("contentType", String.self),
              .field("fileName", String.self),
              .field("relevance", GraphQLEnum<OctopusGraphQL.ClaimFollowupFileRelevance>.self),
            ] }
            @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
              ClaimFollowupFragment.Question.Content.AsClaimFollowupFreeText.CurrentAudio.self
            ] }

            public var id: OctopusGraphQL.ID { __data["id"] }
            public var url: OctopusGraphQL.Url { __data["url"] }
            public var contentType: String { __data["contentType"] }
            public var fileName: String { __data["fileName"] }
            public var relevance: GraphQLEnum<OctopusGraphQL.ClaimFollowupFileRelevance> { __data["relevance"] }
          }
        }

        /// Question.Content.AsClaimFollowupDate
        ///
        /// Parent Type: `ClaimFollowupDate`
        nonisolated public struct AsClaimFollowupDate: OctopusGraphQL.InlineFragment {
          @_spi(Unsafe) public let __data: DataDict
          @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

          public typealias RootEntityType = ClaimFollowupFragment.Question.Content
          @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { OctopusGraphQL.Objects.ClaimFollowupDate }
          @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
            .field("currentValue", String?.self),
            .field("min", alias: "minDate", String?.self),
            .field("max", alias: "maxDate", String?.self),
          ] }
          @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
            ClaimFollowupFragment.Question.Content.self,
            ClaimFollowupFragment.Question.Content.AsClaimFollowupDate.self
          ] }

          /// yyyy-MM-dd.
          public var currentValue: String? { __data["currentValue"] }
          /// Advisory earliest date as yyyy-MM-dd: the app warns before it, the server accepts any date.
          public var minDate: String? { __data["minDate"] }
          /// Advisory latest date as yyyy-MM-dd: the app warns after it, the server accepts any date.
          public var maxDate: String? { __data["maxDate"] }
        }

        /// Question.Content.AsClaimFollowupNumber
        ///
        /// Parent Type: `ClaimFollowupNumber`
        nonisolated public struct AsClaimFollowupNumber: OctopusGraphQL.InlineFragment {
          @_spi(Unsafe) public let __data: DataDict
          @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

          public typealias RootEntityType = ClaimFollowupFragment.Question.Content
          @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { OctopusGraphQL.Objects.ClaimFollowupNumber }
          @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
            .field("currentValue", String?.self),
            .field("min", Int?.self),
            .field("max", Int?.self),
          ] }
          @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
            ClaimFollowupFragment.Question.Content.self,
            ClaimFollowupFragment.Question.Content.AsClaimFollowupNumber.self
          ] }

          /// A whole number.
          public var currentValue: String? { __data["currentValue"] }
          /// Advisory lower bound: the app warns below it, the server accepts any whole number.
          public var min: Int? { __data["min"] }
          /// Advisory upper bound: the app warns above it, the server accepts any whole number.
          public var max: Int? { __data["max"] }
        }

        /// Question.Content.AsClaimFollowupPhoneNumber
        ///
        /// Parent Type: `ClaimFollowupPhoneNumber`
        nonisolated public struct AsClaimFollowupPhoneNumber: OctopusGraphQL.InlineFragment {
          @_spi(Unsafe) public let __data: DataDict
          @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

          public typealias RootEntityType = ClaimFollowupFragment.Question.Content
          @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { OctopusGraphQL.Objects.ClaimFollowupPhoneNumber }
          @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
            .field("currentValue", String?.self),
          ] }
          @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
            ClaimFollowupFragment.Question.Content.self,
            ClaimFollowupFragment.Question.Content.AsClaimFollowupPhoneNumber.self
          ] }

          public var currentValue: String? { __data["currentValue"] }
        }

        /// Question.Content.AsClaimFollowupFileUpload
        ///
        /// Parent Type: `ClaimFollowupFileUpload`
        nonisolated public struct AsClaimFollowupFileUpload: OctopusGraphQL.InlineFragment {
          @_spi(Unsafe) public let __data: DataDict
          @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

          public typealias RootEntityType = ClaimFollowupFragment.Question.Content
          @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { OctopusGraphQL.Objects.ClaimFollowupFileUpload }
          @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
            .field("uploadUri", String.self),
            .field("currentFiles", [CurrentFile].self),
          ] }
          @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
            ClaimFollowupFragment.Question.Content.self,
            ClaimFollowupFragment.Question.Content.AsClaimFollowupFileUpload.self
          ] }

          public var uploadUri: String { __data["uploadUri"] }
          public var currentFiles: [CurrentFile] { __data["currentFiles"] }

          /// Question.Content.AsClaimFollowupFileUpload.CurrentFile
          ///
          /// Parent Type: `ClaimFollowupFile`
          nonisolated public struct CurrentFile: OctopusGraphQL.SelectionSet {
            @_spi(Unsafe) public let __data: DataDict
            @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

            @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { OctopusGraphQL.Objects.ClaimFollowupFile }
            @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
              .field("__typename", String.self),
              .field("id", OctopusGraphQL.ID.self),
              .field("url", OctopusGraphQL.Url.self),
              .field("contentType", String.self),
              .field("fileName", String.self),
              .field("relevance", GraphQLEnum<OctopusGraphQL.ClaimFollowupFileRelevance>.self),
            ] }
            @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
              ClaimFollowupFragment.Question.Content.AsClaimFollowupFileUpload.CurrentFile.self
            ] }

            public var id: OctopusGraphQL.ID { __data["id"] }
            public var url: OctopusGraphQL.Url { __data["url"] }
            public var contentType: String { __data["contentType"] }
            public var fileName: String { __data["fileName"] }
            public var relevance: GraphQLEnum<OctopusGraphQL.ClaimFollowupFileRelevance> { __data["relevance"] }
          }
        }
      }
    }
  }

}