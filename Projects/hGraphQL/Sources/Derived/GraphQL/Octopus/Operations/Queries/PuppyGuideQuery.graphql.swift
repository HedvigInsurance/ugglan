// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI
@_spi(Execution) @_spi(Unsafe) import ApolloAPI

public extension OctopusGraphQL {
  nonisolated struct PuppyGuideQuery: GraphQLQuery {
    public static let operationName: String = "PuppyGuide"
    public static let operationDocument: ApolloAPI.OperationDocument = .init(
      definition: .init(
        #"query PuppyGuide { currentMember { __typename puppyGuide { __typename forYoungDog stories { __typename categories content image name rating read subtitle title } } } }"#
      ))

    public init() {}

    nonisolated public struct Data: OctopusGraphQL.SelectionSet {
      @_spi(Unsafe) public let __data: DataDict
      @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

      @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { OctopusGraphQL.Objects.Query }
      @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
        .field("currentMember", CurrentMember.self),
      ] }
      @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
        PuppyGuideQuery.Data.self
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
          .field("puppyGuide", PuppyGuide?.self),
        ] }
        @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
          PuppyGuideQuery.Data.CurrentMember.self
        ] }

        /// Young Pet Guide content for the member.
        /// Returns the educational content stories plus an indicator of whether the audience
        /// is a young dog. Returns null when the member has no active dog contracts.
        public var puppyGuide: PuppyGuide? { __data["puppyGuide"] }

        /// CurrentMember.PuppyGuide
        ///
        /// Parent Type: `PuppyGuide`
        nonisolated public struct PuppyGuide: OctopusGraphQL.SelectionSet {
          @_spi(Unsafe) public let __data: DataDict
          @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

          @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { OctopusGraphQL.Objects.PuppyGuide }
          @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
            .field("__typename", String.self),
            .field("forYoungDog", Bool?.self),
            .field("stories", [Story]?.self),
          ] }
          @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
            PuppyGuideQuery.Data.CurrentMember.PuppyGuide.self
          ] }

          /// True if the member has at least one active dog contract for a dog under 2 years old.
          /// Clients should use this to render the content appropriately for the audience —
          /// content tailored to puppies will be a better fit when this is true.
          /// [null] assumes it's not a young dog, as we do not have this info
          public var forYoungDog: Bool? { __data["forYoungDog"] }
          /// Educational content stories for dog owners. The same set is served regardless of dog age.
          public var stories: [Story]? { __data["stories"] }

          /// CurrentMember.PuppyGuide.Story
          ///
          /// Parent Type: `PuppyGuideStory`
          nonisolated public struct Story: OctopusGraphQL.SelectionSet {
            @_spi(Unsafe) public let __data: DataDict
            @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

            @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { OctopusGraphQL.Objects.PuppyGuideStory }
            @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
              .field("__typename", String.self),
              .field("categories", [String].self),
              .field("content", String.self),
              .field("image", String.self),
              .field("name", String.self),
              .field("rating", Int?.self),
              .field("read", Bool.self),
              .field("subtitle", String.self),
              .field("title", String.self),
            ] }
            @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
              PuppyGuideQuery.Data.CurrentMember.PuppyGuide.Story.self
            ] }

            /// Categories this story belongs to.
            public var categories: [String] { __data["categories"] }
            /// The main content of the story.
            public var content: String { __data["content"] }
            /// The image associated with this story.
            public var image: String { __data["image"] }
            /// The unique name/identifier of the story.
            public var name: String { __data["name"] }
            ///  The user's rating of the story.
            public var rating: Int? { __data["rating"] }
            /// The date when the story was marked as read by the user.
            public var read: Bool { __data["read"] }
            /// The subtitle or description of the story.
            public var subtitle: String { __data["subtitle"] }
            /// The display title of the story.
            public var title: String { __data["title"] }
          }
        }
      }
    }
  }

}