// @generated
// This file was automatically generated and should not be edited.

@_spi(Internal) @_spi(Unsafe) import ApolloAPI

public extension OctopusGraphQL {
  nonisolated struct PersonalInformationInput: InputObject {
    @_spi(Unsafe) public private(set) var __data: InputDict

    @_spi(Unsafe) public init(_ data: InputDict) {
      __data = data
    }

    public init(
      personalNumber: String
    ) {
      __data = InputDict([
        "personalNumber": personalNumber
      ])
    }

    public var personalNumber: String {
      get { __data["personalNumber"] }
      set { __data["personalNumber"] = newValue }
    }
  }

}