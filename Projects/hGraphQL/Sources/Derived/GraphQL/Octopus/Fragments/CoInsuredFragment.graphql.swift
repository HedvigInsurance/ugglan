// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI
@_spi(Execution) @_spi(Unsafe) import ApolloAPI

public extension OctopusGraphQL {
  nonisolated struct CoInsuredFragment: OctopusGraphQL.SelectionSet, Fragment {
    public static var fragmentDefinition: StaticString {
      #"fragment CoInsuredFragment on ContractCoInsured { __typename id birthdate firstName lastName hasMissingInfo ssn activatesOn terminatesOn }"#
    }

    @_spi(Unsafe) public let __data: DataDict
    @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

    @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { OctopusGraphQL.Objects.ContractCoInsured }
    @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
      .field("__typename", String.self),
      .field("id", OctopusGraphQL.ID?.self),
      .field("birthdate", OctopusGraphQL.Date?.self),
      .field("firstName", String?.self),
      .field("lastName", String?.self),
      .field("hasMissingInfo", Bool.self),
      .field("ssn", String?.self),
      .field("activatesOn", OctopusGraphQL.Date?.self),
      .field("terminatesOn", OctopusGraphQL.Date?.self),
    ] }
    @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
      CoInsuredFragment.self
    ] }

    /// firstName + lastName + birthDate if all are present, otherwise null
    public var id: OctopusGraphQL.ID? { __data["id"] }
    /// Co-insured birthdate.
    public var birthdate: OctopusGraphQL.Date? { __data["birthdate"] }
    /// First name.
    public var firstName: String? { __data["firstName"] }
    /// Last name.
    public var lastName: String? { __data["lastName"] }
    /// Whether or not any of firstName, lastName, ssn or birthdate is missing and needs to be added.
    public var hasMissingInfo: Bool { __data["hasMissingInfo"] }
    /// National identification number if any.
    public var ssn: String? { __data["ssn"] }
    /// The date this co-insured will be added.
    public var activatesOn: OctopusGraphQL.Date? { __data["activatesOn"] }
    /// The date this co-insured will be removed.
    public var terminatesOn: OctopusGraphQL.Date? { __data["terminatesOn"] }
  }

}