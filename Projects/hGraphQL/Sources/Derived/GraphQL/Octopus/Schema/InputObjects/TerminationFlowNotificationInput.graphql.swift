// @generated
// This file was automatically generated and should not be edited.

@_spi(Internal) @_spi(Unsafe) import ApolloAPI

public extension OctopusGraphQL {
  nonisolated struct TerminationFlowNotificationInput: InputObject {
    @_spi(Unsafe) public private(set) var __data: InputDict

    @_spi(Unsafe) public init(_ data: InputDict) {
      __data = data
    }

    public init(
      contractId: ID,
      terminationDate: Date
    ) {
      __data = InputDict([
        "contractId": contractId,
        "terminationDate": terminationDate
      ])
    }

    public var contractId: ID {
      get { __data["contractId"] }
      set { __data["contractId"] = newValue }
    }

    public var terminationDate: Date {
      get { __data["terminationDate"] }
      set { __data["terminationDate"] = newValue }
    }
  }

}