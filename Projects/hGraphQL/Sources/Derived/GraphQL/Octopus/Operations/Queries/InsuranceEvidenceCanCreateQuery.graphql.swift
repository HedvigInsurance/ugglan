// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI
@_spi(Execution) @_spi(Unsafe) import ApolloAPI

public extension OctopusGraphQL {
  nonisolated struct InsuranceEvidenceCanCreateQuery: GraphQLQuery {
    public static let operationName: String = "InsuranceEvidenceCanCreate"
    public static let operationDocument: ApolloAPI.OperationDocument = .init(
      definition: .init(
        #"query InsuranceEvidenceCanCreate { currentMember { __typename memberActions { __typename isCreatingOfInsuranceEvidenceEnabled } } }"#
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
        InsuranceEvidenceCanCreateQuery.Data.self
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
          .field("memberActions", MemberActions?.self),
        ] }
        @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
          InsuranceEvidenceCanCreateQuery.Data.CurrentMember.self
        ] }

        public var memberActions: MemberActions? { __data["memberActions"] }

        /// CurrentMember.MemberActions
        ///
        /// Parent Type: `MemberActions`
        nonisolated public struct MemberActions: OctopusGraphQL.SelectionSet {
          @_spi(Unsafe) public let __data: DataDict
          @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

          @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { OctopusGraphQL.Objects.MemberActions }
          @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
            .field("__typename", String.self),
            .field("isCreatingOfInsuranceEvidenceEnabled", Bool.self),
          ] }
          @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
            InsuranceEvidenceCanCreateQuery.Data.CurrentMember.MemberActions.self
          ] }

          /// Indicate whether the possibility to create insurance evidence should be displayed.
          public var isCreatingOfInsuranceEvidenceEnabled: Bool { __data["isCreatingOfInsuranceEvidenceEnabled"] }
        }
      }
    }
  }

}