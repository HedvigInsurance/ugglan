// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI
@_spi(Execution) @_spi(Unsafe) import ApolloAPI

public extension OctopusGraphQL {
  nonisolated struct MemberDetailsQuery: GraphQLQuery {
    public static let operationName: String = "MemberDetails"
    public static let operationDocument: ApolloAPI.OperationDocument = .init(
      definition: .init(
        #"query MemberDetails { currentMember { __typename firstName lastName phoneNumber email id } }"#
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
        MemberDetailsQuery.Data.self
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
          .field("firstName", String.self),
          .field("lastName", String.self),
          .field("phoneNumber", String?.self),
          .field("email", String.self),
          .field("id", OctopusGraphQL.ID.self),
        ] }
        @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
          MemberDetailsQuery.Data.CurrentMember.self
        ] }

        public var firstName: String { __data["firstName"] }
        public var lastName: String { __data["lastName"] }
        public var phoneNumber: String? { __data["phoneNumber"] }
        public var email: String { __data["email"] }
        public var id: OctopusGraphQL.ID { __data["id"] }
      }
    }
  }

}