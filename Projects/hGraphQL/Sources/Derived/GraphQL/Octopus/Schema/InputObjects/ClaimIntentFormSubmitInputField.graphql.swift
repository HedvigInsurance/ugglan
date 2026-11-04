// @generated
// This file was automatically generated and should not be edited.

@_spi(Internal) @_spi(Unsafe) import ApolloAPI

public extension OctopusGraphQL {
  nonisolated struct ClaimIntentFormSubmitInputField: InputObject {
    @_spi(Unsafe) public private(set) var __data: InputDict

    @_spi(Unsafe) public init(_ data: InputDict) {
      __data = data
    }

    public init(
      fieldId: ID,
      values: [ClaimIntentStepContentFormFieldValue]
    ) {
      __data = InputDict([
        "fieldId": fieldId,
        "values": values
      ])
    }

    public var fieldId: ID {
      get { __data["fieldId"] }
      set { __data["fieldId"] = newValue }
    }

    /// For most field types, send a single value here.
    ///
    /// If `ClaimIntentStepContentFormField.isRequired == false`, this can be left empty for "no value".
    public var values: [ClaimIntentStepContentFormFieldValue] {
      get { __data["values"] }
      set { __data["values"] = newValue }
    }
  }

}