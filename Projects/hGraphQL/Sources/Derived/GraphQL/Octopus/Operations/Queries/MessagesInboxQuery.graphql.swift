// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI
@_spi(Execution) @_spi(Unsafe) import ApolloAPI

public extension OctopusGraphQL {
  nonisolated struct MessagesInboxQuery: GraphQLQuery {
    public static let operationName: String = "MessagesInbox"
    public static let operationDocument: ApolloAPI.OperationDocument = .init(
      definition: .init(
        #"query MessagesInbox { currentMember { __typename cioMessages { __typename externalMessageId messageType subject preheader sender timestamp } } }"#
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
        MessagesInboxQuery.Data.self
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
          .field("cioMessages", [CioMessage].self),
        ] }
        @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
          MessagesInboxQuery.Data.CurrentMember.self
        ] }

        /// The member's email and SMS deliveries from Customer.io, newest first. Push and other delivery
        /// types are excluded. Details beyond the list fields are filled in for the most recent few only.
        public var cioMessages: [CioMessage] { __data["cioMessages"] }

        /// CurrentMember.CioMessage
        ///
        /// Parent Type: `CioMessageDetails`
        nonisolated public struct CioMessage: OctopusGraphQL.SelectionSet {
          @_spi(Unsafe) public let __data: DataDict
          @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

          @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { OctopusGraphQL.Objects.CioMessageDetails }
          @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
            .field("__typename", String.self),
            .field("externalMessageId", String.self),
            .field("messageType", GraphQLEnum<OctopusGraphQL.CioMessageType>?.self),
            .field("subject", String?.self),
            .field("preheader", String?.self),
            .field("sender", String?.self),
            .field("timestamp", String.self),
          ] }
          @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
            MessagesInboxQuery.Data.CurrentMember.CioMessage.self
          ] }

          /// The Customer.io delivery id. Pass this to `Member.cioMessageContent`.
          public var externalMessageId: String { __data["externalMessageId"] }
          /// The channel the message was sent over. Null for types we don't surface, such as push.
          public var messageType: GraphQLEnum<OctopusGraphQL.CioMessageType>? { __data["messageType"] }
          public var subject: String? { __data["subject"] }
          /// Email "preview text". Only emails have one, and only when the template sets it.
          public var preheader: String? { __data["preheader"] }
          /// The address the message was sent from.
          public var sender: String? { __data["sender"] }
          /// ISO-8601 instant for when Customer.io created the delivery.
          public var timestamp: String { __data["timestamp"] }
        }
      }
    }
  }

}