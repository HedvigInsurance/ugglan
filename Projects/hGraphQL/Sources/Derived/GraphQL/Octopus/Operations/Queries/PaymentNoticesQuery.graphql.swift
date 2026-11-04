// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI
@_spi(Execution) @_spi(Unsafe) import ApolloAPI

public extension OctopusGraphQL {
  nonisolated struct PaymentNoticesQuery: GraphQLQuery {
    public static let operationName: String = "PaymentNotices"
    public static let operationDocument: ApolloAPI.OperationDocument = .init(
      definition: .init(
        #"query PaymentNotices { currentMember { __typename id showPreChargeNotice showRetryChargeNotice } }"#
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
        PaymentNoticesQuery.Data.self
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
          .field("showPreChargeNotice", String?.self),
          .field("showRetryChargeNotice", String?.self),
        ] }
        @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
          PaymentNoticesQuery.Data.CurrentMember.self
        ] }

        public var id: OctopusGraphQL.ID { __data["id"] }
        /// Non null string if the app should show a notice about an upcoming charge. The returned string will be unique per
        /// occasion.
        public var showPreChargeNotice: String? { __data["showPreChargeNotice"] }
        /// Non null string if the app should show a notice about an upcoming charge retry. The returned string will be unique per
        /// occasion.
        public var showRetryChargeNotice: String? { __data["showRetryChargeNotice"] }
      }
    }
  }

}