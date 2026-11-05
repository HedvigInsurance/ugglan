// @generated
// This file was automatically generated and should not be edited.

@_spi(Internal) @_spi(Unsafe) import ApolloAPI

public extension OctopusGraphQL {
  nonisolated struct MemberUpdateLanguageInput: InputObject {
    @_spi(Unsafe) public private(set) var __data: InputDict

    @_spi(Unsafe) public init(_ data: InputDict) {
      __data = data
    }

    public init(
      ietfLanguageTag: String
    ) {
      __data = InputDict([
        "ietfLanguageTag": ietfLanguageTag
      ])
    }

    public var ietfLanguageTag: String {
      get { __data["ietfLanguageTag"] }
      set { __data["ietfLanguageTag"] = newValue }
    }
  }

}