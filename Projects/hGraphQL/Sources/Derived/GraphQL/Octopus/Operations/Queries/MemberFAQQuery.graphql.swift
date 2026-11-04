// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI
@_spi(Execution) @_spi(Unsafe) import ApolloAPI

public extension OctopusGraphQL {
  nonisolated struct MemberFAQQuery: GraphQLQuery {
    public static let operationName: String = "MemberFAQ"
    public static let operationDocument: ApolloAPI.OperationDocument = .init(
      definition: .init(
        #"query MemberFAQ { currentMember { __typename memberFAQ { __typename commonFAQ { __typename ...FAQFragment } topics { __typename id title commonFAQ { __typename ...FAQFragment } otherFAQ { __typename ...FAQFragment } } } } }"#,
        fragments: [FAQFragment.self]
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
        MemberFAQQuery.Data.self
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
          .field("memberFAQ", MemberFAQ.self),
        ] }
        @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
          MemberFAQQuery.Data.CurrentMember.self
        ] }

        /// List of members FAQ
        public var memberFAQ: MemberFAQ { __data["memberFAQ"] }

        /// CurrentMember.MemberFAQ
        ///
        /// Parent Type: `MemberFAQ`
        nonisolated public struct MemberFAQ: OctopusGraphQL.SelectionSet {
          @_spi(Unsafe) public let __data: DataDict
          @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

          @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { OctopusGraphQL.Objects.MemberFAQ }
          @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
            .field("__typename", String.self),
            .field("commonFAQ", [CommonFAQ].self),
            .field("topics", [Topic].self),
          ] }
          @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
            MemberFAQQuery.Data.CurrentMember.MemberFAQ.self
          ] }

          public var commonFAQ: [CommonFAQ] { __data["commonFAQ"] }
          public var topics: [Topic] { __data["topics"] }

          /// CurrentMember.MemberFAQ.CommonFAQ
          ///
          /// Parent Type: `MemberFAQItem`
          nonisolated public struct CommonFAQ: OctopusGraphQL.SelectionSet {
            @_spi(Unsafe) public let __data: DataDict
            @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

            @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { OctopusGraphQL.Objects.MemberFAQItem }
            @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
              .field("__typename", String.self),
              .fragment(FAQFragment.self),
            ] }
            @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
              MemberFAQQuery.Data.CurrentMember.MemberFAQ.CommonFAQ.self,
              FAQFragment.self
            ] }

            public var id: String { __data["id"] }
            public var question: String { __data["question"] }
            public var answer: String { __data["answer"] }

            public struct Fragments: FragmentContainer {
              @_spi(Unsafe) public let __data: DataDict
              @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

              public var fAQFragment: FAQFragment { _toFragment() }
            }
          }

          /// CurrentMember.MemberFAQ.Topic
          ///
          /// Parent Type: `MemberFAQTopic`
          nonisolated public struct Topic: OctopusGraphQL.SelectionSet {
            @_spi(Unsafe) public let __data: DataDict
            @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

            @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { OctopusGraphQL.Objects.MemberFAQTopic }
            @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
              .field("__typename", String.self),
              .field("id", String.self),
              .field("title", String.self),
              .field("commonFAQ", [CommonFAQ].self),
              .field("otherFAQ", [OtherFAQ].self),
            ] }
            @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
              MemberFAQQuery.Data.CurrentMember.MemberFAQ.Topic.self
            ] }

            public var id: String { __data["id"] }
            public var title: String { __data["title"] }
            public var commonFAQ: [CommonFAQ] { __data["commonFAQ"] }
            public var otherFAQ: [OtherFAQ] { __data["otherFAQ"] }

            /// CurrentMember.MemberFAQ.Topic.CommonFAQ
            ///
            /// Parent Type: `MemberFAQItem`
            nonisolated public struct CommonFAQ: OctopusGraphQL.SelectionSet {
              @_spi(Unsafe) public let __data: DataDict
              @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

              @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { OctopusGraphQL.Objects.MemberFAQItem }
              @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
                .field("__typename", String.self),
                .fragment(FAQFragment.self),
              ] }
              @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
                MemberFAQQuery.Data.CurrentMember.MemberFAQ.Topic.CommonFAQ.self,
                FAQFragment.self
              ] }

              public var id: String { __data["id"] }
              public var question: String { __data["question"] }
              public var answer: String { __data["answer"] }

              public struct Fragments: FragmentContainer {
                @_spi(Unsafe) public let __data: DataDict
                @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

                public var fAQFragment: FAQFragment { _toFragment() }
              }
            }

            /// CurrentMember.MemberFAQ.Topic.OtherFAQ
            ///
            /// Parent Type: `MemberFAQItem`
            nonisolated public struct OtherFAQ: OctopusGraphQL.SelectionSet {
              @_spi(Unsafe) public let __data: DataDict
              @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

              @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { OctopusGraphQL.Objects.MemberFAQItem }
              @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
                .field("__typename", String.self),
                .fragment(FAQFragment.self),
              ] }
              @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
                MemberFAQQuery.Data.CurrentMember.MemberFAQ.Topic.OtherFAQ.self,
                FAQFragment.self
              ] }

              public var id: String { __data["id"] }
              public var question: String { __data["question"] }
              public var answer: String { __data["answer"] }

              public struct Fragments: FragmentContainer {
                @_spi(Unsafe) public let __data: DataDict
                @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

                public var fAQFragment: FAQFragment { _toFragment() }
              }
            }
          }
        }
      }
    }
  }

}