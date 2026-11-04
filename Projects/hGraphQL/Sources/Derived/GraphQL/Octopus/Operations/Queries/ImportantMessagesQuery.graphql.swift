// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI
@_spi(Execution) @_spi(Unsafe) import ApolloAPI

public extension OctopusGraphQL {
  nonisolated struct ImportantMessagesQuery: GraphQLQuery {
    public static let operationName: String = "ImportantMessages"
    public static let operationDocument: ApolloAPI.OperationDocument = .init(
      definition: .init(
        #"query ImportantMessages { currentMember { __typename importantMessages { __typename id message linkInfo { __typename buttonText url } } } }"#
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
        ImportantMessagesQuery.Data.self
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
          .field("importantMessages", [ImportantMessage].self),
        ] }
        @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
          ImportantMessagesQuery.Data.CurrentMember.self
        ] }

        /// Carries messages to be shown to a logged in member, such as possible delays
        /// in service or outage announcements.
        public var importantMessages: [ImportantMessage] { __data["importantMessages"] }

        /// CurrentMember.ImportantMessage
        ///
        /// Parent Type: `MemberImportantMessage`
        nonisolated public struct ImportantMessage: OctopusGraphQL.SelectionSet {
          @_spi(Unsafe) public let __data: DataDict
          @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

          @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { OctopusGraphQL.Objects.MemberImportantMessage }
          @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
            .field("__typename", String.self),
            .field("id", OctopusGraphQL.ID.self),
            .field("message", String.self),
            .field("linkInfo", LinkInfo?.self),
          ] }
          @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
            ImportantMessagesQuery.Data.CurrentMember.ImportantMessage.self
          ] }

          public var id: OctopusGraphQL.ID { __data["id"] }
          public var message: String { __data["message"] }
          public var linkInfo: LinkInfo? { __data["linkInfo"] }

          /// CurrentMember.ImportantMessage.LinkInfo
          ///
          /// Parent Type: `LinkInfo`
          nonisolated public struct LinkInfo: OctopusGraphQL.SelectionSet {
            @_spi(Unsafe) public let __data: DataDict
            @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

            @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { OctopusGraphQL.Objects.LinkInfo }
            @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
              .field("__typename", String.self),
              .field("buttonText", String.self),
              .field("url", OctopusGraphQL.Url.self),
            ] }
            @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
              ImportantMessagesQuery.Data.CurrentMember.ImportantMessage.LinkInfo.self
            ] }

            public var buttonText: String { __data["buttonText"] }
            public var url: OctopusGraphQL.Url { __data["url"] }
          }
        }
      }
    }
  }

}