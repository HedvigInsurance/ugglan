// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI
@_spi(Execution) @_spi(Unsafe) import ApolloAPI

public extension OctopusGraphQL {
  nonisolated struct YearInReviewQuery: GraphQLQuery {
    public static let operationName: String = "YearInReview"
    public static let operationDocument: ApolloAPI.OperationDocument = .init(
      definition: .init(
        #"query YearInReview { currentMember { __typename id yearInReview { __typename title description fileUrl action { __typename title url } } } }"#
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
        YearInReviewQuery.Data.self
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
          .field("id", OctopusGraphQL.ID.self),
          .field("yearInReview", [YearInReview].self),
        ] }
        @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
          YearInReviewQuery.Data.CurrentMember.self
        ] }

        public var id: OctopusGraphQL.ID { __data["id"] }
        /// Year in review articles, in the language of the request locale (Swedish or English).
        /// If the member has been insured with us for at least one day, the first article shows how many days that is.
        /// The remaining articles come from Storyblok, sorted by their configured order, and are picked by the member's
        /// active insurances: pet articles for pet members, otherwise car articles for car members, otherwise fallback articles.
        public var yearInReview: [YearInReview] { __data["yearInReview"] }

        /// CurrentMember.YearInReview
        ///
        /// Parent Type: `YearInReviewArticle`
        nonisolated public struct YearInReview: OctopusGraphQL.SelectionSet {
          @_spi(Unsafe) public let __data: DataDict
          @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

          @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { OctopusGraphQL.Objects.YearInReviewArticle }
          @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
            .field("__typename", String.self),
            .field("title", String.self),
            .field("description", String.self),
            .field("fileUrl", String?.self),
            .field("action", Action?.self),
          ] }
          @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
            YearInReviewQuery.Data.CurrentMember.YearInReview.self
          ] }

          /// The display title of the article.
          public var title: String { __data["title"] }
          /// The body text of the article.
          public var description: String { __data["description"] }
          /// URL of the file (image) attached to the article. Null when the article has no file.
          public var fileUrl: String? { __data["fileUrl"] }
          /// Call to action for the article, for example shown as a button. Null when the article has no action.
          public var action: Action? { __data["action"] }

          /// CurrentMember.YearInReview.Action
          ///
          /// Parent Type: `YearInReviewAction`
          nonisolated public struct Action: OctopusGraphQL.SelectionSet {
            @_spi(Unsafe) public let __data: DataDict
            @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

            @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { OctopusGraphQL.Objects.YearInReviewAction }
            @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
              .field("__typename", String.self),
              .field("title", String.self),
              .field("url", String.self),
            ] }
            @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
              YearInReviewQuery.Data.CurrentMember.YearInReview.Action.self
            ] }

            /// The display title of the action.
            public var title: String { __data["title"] }
            /// The URL to open when the action is used.
            public var url: String { __data["url"] }
          }
        }
      }
    }
  }

}