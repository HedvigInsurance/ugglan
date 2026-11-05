// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI
@_spi(Execution) @_spi(Unsafe) import ApolloAPI

public extension OctopusGraphQL {
  nonisolated struct PersonalInformationQuery: GraphQLQuery {
    public static let operationName: String = "PersonalInformation"
    public static let operationDocument: ApolloAPI.OperationDocument = .init(
      definition: .init(
        #"query PersonalInformation($input: PersonalInformationInput!) { personalInformation(input: $input) { __typename firstName lastName streetAddress postalNumber city } }"#
      ))

    public var input: PersonalInformationInput

    public init(input: PersonalInformationInput) {
      self.input = input
    }

    @_spi(Unsafe) public var __variables: Variables? { ["input": input] }

    nonisolated public struct Data: OctopusGraphQL.SelectionSet {
      @_spi(Unsafe) public let __data: DataDict
      @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

      @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { OctopusGraphQL.Objects.Query }
      @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
        .field("personalInformation", PersonalInformation?.self, arguments: ["input": .variable("input")]),
      ] }
      @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
        PersonalInformationQuery.Data.self
      ] }

      public var personalInformation: PersonalInformation? { __data["personalInformation"] }

      /// PersonalInformation
      ///
      /// Parent Type: `PersonalInformation`
      nonisolated public struct PersonalInformation: OctopusGraphQL.SelectionSet {
        @_spi(Unsafe) public let __data: DataDict
        @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

        @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { OctopusGraphQL.Objects.PersonalInformation }
        @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
          .field("__typename", String.self),
          .field("firstName", String.self),
          .field("lastName", String.self),
          .field("streetAddress", String.self),
          .field("postalNumber", String.self),
          .field("city", String.self),
        ] }
        @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
          PersonalInformationQuery.Data.PersonalInformation.self
        ] }

        public var firstName: String { __data["firstName"] }
        public var lastName: String { __data["lastName"] }
        public var streetAddress: String { __data["streetAddress"] }
        public var postalNumber: String { __data["postalNumber"] }
        public var city: String { __data["city"] }
      }
    }
  }

}