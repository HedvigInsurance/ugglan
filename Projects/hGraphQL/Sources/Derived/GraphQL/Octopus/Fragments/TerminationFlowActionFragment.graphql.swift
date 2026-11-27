// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI
@_spi(Execution) @_spi(Unsafe) import ApolloAPI

public extension OctopusGraphQL {
  nonisolated struct TerminationFlowActionFragment: OctopusGraphQL.SelectionSet, Fragment {
    public static var fragmentDefinition: StaticString {
      #"fragment TerminationFlowActionFragment on TerminationFlowAction { __typename ... on TerminationFlowActionTerminateWithDate { minDate maxDate extraCoverage { __typename ...TerminationExtraCoverageItemFragment } } ... on TerminationFlowActionDeleteInsurance { extraCoverage { __typename ...TerminationExtraCoverageItemFragment } } }"#
    }

    @_spi(Unsafe) public let __data: DataDict
    @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

    @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { OctopusGraphQL.Unions.TerminationFlowAction }
    @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
      .field("__typename", String.self),
      .inlineFragment(AsTerminationFlowActionTerminateWithDate.self),
      .inlineFragment(AsTerminationFlowActionDeleteInsurance.self),
    ] }
    @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
      TerminationFlowActionFragment.self
    ] }

    public var asTerminationFlowActionTerminateWithDate: AsTerminationFlowActionTerminateWithDate? { _asInlineFragment() }
    public var asTerminationFlowActionDeleteInsurance: AsTerminationFlowActionDeleteInsurance? { _asInlineFragment() }

    /// AsTerminationFlowActionTerminateWithDate
    ///
    /// Parent Type: `TerminationFlowActionTerminateWithDate`
    nonisolated public struct AsTerminationFlowActionTerminateWithDate: OctopusGraphQL.InlineFragment {
      @_spi(Unsafe) public let __data: DataDict
      @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

      public typealias RootEntityType = TerminationFlowActionFragment
      @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { OctopusGraphQL.Objects.TerminationFlowActionTerminateWithDate }
      @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
        .field("minDate", OctopusGraphQL.Date.self),
        .field("maxDate", OctopusGraphQL.Date.self),
        .field("extraCoverage", [ExtraCoverage].self),
      ] }
      @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
        TerminationFlowActionFragment.self,
        TerminationFlowActionFragment.AsTerminationFlowActionTerminateWithDate.self
      ] }

      public var minDate: OctopusGraphQL.Date { __data["minDate"] }
      public var maxDate: OctopusGraphQL.Date { __data["maxDate"] }
      public var extraCoverage: [ExtraCoverage] { __data["extraCoverage"] }

      /// AsTerminationFlowActionTerminateWithDate.ExtraCoverage
      ///
      /// Parent Type: `TerminationFlowExtraCoverageItem`
      nonisolated public struct ExtraCoverage: OctopusGraphQL.SelectionSet {
        @_spi(Unsafe) public let __data: DataDict
        @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

        @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { OctopusGraphQL.Objects.TerminationFlowExtraCoverageItem }
        @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
          .field("__typename", String.self),
          .fragment(TerminationExtraCoverageItemFragment.self),
        ] }
        @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
          TerminationFlowActionFragment.AsTerminationFlowActionTerminateWithDate.ExtraCoverage.self,
          TerminationExtraCoverageItemFragment.self
        ] }

        public var displayName: String { __data["displayName"] }
        public var displayValue: String? { __data["displayValue"] }

        public struct Fragments: FragmentContainer {
          @_spi(Unsafe) public let __data: DataDict
          @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

          public var terminationExtraCoverageItemFragment: TerminationExtraCoverageItemFragment { _toFragment() }
        }
      }
    }

    /// AsTerminationFlowActionDeleteInsurance
    ///
    /// Parent Type: `TerminationFlowActionDeleteInsurance`
    nonisolated public struct AsTerminationFlowActionDeleteInsurance: OctopusGraphQL.InlineFragment {
      @_spi(Unsafe) public let __data: DataDict
      @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

      public typealias RootEntityType = TerminationFlowActionFragment
      @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { OctopusGraphQL.Objects.TerminationFlowActionDeleteInsurance }
      @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
        .field("extraCoverage", [ExtraCoverage].self),
      ] }
      @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
        TerminationFlowActionFragment.self,
        TerminationFlowActionFragment.AsTerminationFlowActionDeleteInsurance.self
      ] }

      public var extraCoverage: [ExtraCoverage] { __data["extraCoverage"] }

      /// AsTerminationFlowActionDeleteInsurance.ExtraCoverage
      ///
      /// Parent Type: `TerminationFlowExtraCoverageItem`
      nonisolated public struct ExtraCoverage: OctopusGraphQL.SelectionSet {
        @_spi(Unsafe) public let __data: DataDict
        @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

        @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { OctopusGraphQL.Objects.TerminationFlowExtraCoverageItem }
        @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
          .field("__typename", String.self),
          .fragment(TerminationExtraCoverageItemFragment.self),
        ] }
        @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
          TerminationFlowActionFragment.AsTerminationFlowActionDeleteInsurance.ExtraCoverage.self,
          TerminationExtraCoverageItemFragment.self
        ] }

        public var displayName: String { __data["displayName"] }
        public var displayValue: String? { __data["displayValue"] }

        public struct Fragments: FragmentContainer {
          @_spi(Unsafe) public let __data: DataDict
          @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

          public var terminationExtraCoverageItemFragment: TerminationExtraCoverageItemFragment { _toFragment() }
        }
      }
    }
  }

}