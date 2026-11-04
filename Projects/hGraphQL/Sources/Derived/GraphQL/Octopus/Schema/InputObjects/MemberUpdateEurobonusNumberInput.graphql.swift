// @generated
// This file was automatically generated and should not be edited.

@_spi(Internal) @_spi(Unsafe) import ApolloAPI

public extension OctopusGraphQL {
  nonisolated struct MemberUpdateEurobonusNumberInput: InputObject {
    @_spi(Unsafe) public private(set) var __data: InputDict

    @_spi(Unsafe) public init(_ data: InputDict) {
      __data = data
    }

    public init(
      eurobonusNumber: String
    ) {
      __data = InputDict([
        "eurobonusNumber": eurobonusNumber
      ])
    }

    public var eurobonusNumber: String {
      get { __data["eurobonusNumber"] }
      set { __data["eurobonusNumber"] = newValue }
    }
  }

}