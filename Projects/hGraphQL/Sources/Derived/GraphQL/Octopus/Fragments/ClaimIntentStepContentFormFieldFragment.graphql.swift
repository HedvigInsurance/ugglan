// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI
@_spi(Execution) @_spi(Unsafe) import ApolloAPI

public extension OctopusGraphQL {
  nonisolated struct ClaimIntentStepContentFormFieldFragment: OctopusGraphQL.SelectionSet, Fragment {
    public static var fragmentDefinition: StaticString {
      #"fragment ClaimIntentStepContentFormFieldFragment on ClaimIntentStepContentFormField { __typename id type title suffix isRequired options { __typename title subtitle value imageUrl selectedTitle } defaultValues currentValues searchData { __typename suggestedQuery modalTitle modalSubtitle } minValue maxValue }"#
    }

    @_spi(Unsafe) public let __data: DataDict
    @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

    @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { OctopusGraphQL.Objects.ClaimIntentStepContentFormField }
    @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
      .field("__typename", String.self),
      .field("id", OctopusGraphQL.ID.self),
      .field("type", GraphQLEnum<OctopusGraphQL.ClaimIntentStepContentFormFieldType>.self),
      .field("title", String.self),
      .field("suffix", String?.self),
      .field("isRequired", Bool.self),
      .field("options", [Option]?.self),
      .field("defaultValues", [OctopusGraphQL.ClaimIntentStepContentFormFieldValue].self),
      .field("currentValues", [OctopusGraphQL.ClaimIntentStepContentFormFieldValue].self),
      .field("searchData", SearchData?.self),
      .field("minValue", OctopusGraphQL.ClaimIntentStepContentFormFieldValue?.self),
      .field("maxValue", OctopusGraphQL.ClaimIntentStepContentFormFieldValue?.self),
    ] }
    @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
      ClaimIntentStepContentFormFieldFragment.self
    ] }

    /// Use the ID when submitting a value for this field.
    public var id: OctopusGraphQL.ID { __data["id"] }
    /// Indicates what kind of form field this is. Specific form fields can be either present or null depending on this
    /// type - such as `options` existing if type is SINGLE_SELECT.
    public var type: GraphQLEnum<OctopusGraphQL.ClaimIntentStepContentFormFieldType> { __data["type"] }
    /// Localized display title of this field.
    public var title: String { __data["title"] }
    /// Optional printed context on the side of the field. Typical value would be a currency like 'SEK'.
    public var suffix: String? { __data["suffix"] }
    /// If true, must contain a value when submitted.
    public var isRequired: Bool { __data["isRequired"] }
    /// A list of selectable options for field types such as SINGLE_SELECT.
    public var options: [Option]? { __data["options"] }
    /// If there are default values, they will show up in this array. Empty means no default value.
    public var defaultValues: [OctopusGraphQL.ClaimIntentStepContentFormFieldValue] { __data["defaultValues"] }
    /// These are the values that the user has submitted for this field.
    public var currentValues: [OctopusGraphQL.ClaimIntentStepContentFormFieldValue] { __data["currentValues"] }
    /// If type is SEARCH, then this will be present.
    public var searchData: SearchData? { __data["searchData"] }
    /// If present - the minimal value this field can hold.
    public var minValue: OctopusGraphQL.ClaimIntentStepContentFormFieldValue? { __data["minValue"] }
    /// If present - the maximal value this field can hold.
    public var maxValue: OctopusGraphQL.ClaimIntentStepContentFormFieldValue? { __data["maxValue"] }

    /// Option
    ///
    /// Parent Type: `ClaimIntentStepContentFormFieldOption`
    nonisolated public struct Option: OctopusGraphQL.SelectionSet {
      @_spi(Unsafe) public let __data: DataDict
      @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

      @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { OctopusGraphQL.Objects.ClaimIntentStepContentFormFieldOption }
      @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
        .field("__typename", String.self),
        .field("title", String.self),
        .field("subtitle", String?.self),
        .field("value", OctopusGraphQL.ClaimIntentStepContentFormFieldValue.self),
        .field("imageUrl", String?.self),
        .field("selectedTitle", String?.self),
      ] }
      @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
        ClaimIntentStepContentFormFieldFragment.Option.self
      ] }

      public var title: String { __data["title"] }
      public var subtitle: String? { __data["subtitle"] }
      public var value: OctopusGraphQL.ClaimIntentStepContentFormFieldValue { __data["value"] }
      public var imageUrl: String? { __data["imageUrl"] }
      /// Outside the picker, where the picked option stands alone, display this instead of `title`.
      public var selectedTitle: String? { __data["selectedTitle"] }
    }

    /// SearchData
    ///
    /// Parent Type: `ClaimIntentStepContentFormFieldSearchData`
    nonisolated public struct SearchData: OctopusGraphQL.SelectionSet {
      @_spi(Unsafe) public let __data: DataDict
      @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

      @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { OctopusGraphQL.Objects.ClaimIntentStepContentFormFieldSearchData }
      @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
        .field("__typename", String.self),
        .field("suggestedQuery", String?.self),
        .field("modalTitle", String.self),
        .field("modalSubtitle", String.self),
      ] }
      @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
        ClaimIntentStepContentFormFieldFragment.SearchData.self
      ] }

      /// Can be auto-inserted into the search bar.
      public var suggestedQuery: String? { __data["suggestedQuery"] }
      /// Title of the search modal.
      public var modalTitle: String { __data["modalTitle"] }
      /// Subtitle of the search modal.
      public var modalSubtitle: String { __data["modalSubtitle"] }
    }
  }

}