// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI
@_spi(Execution) @_spi(Unsafe) import ApolloAPI

public extension OctopusGraphQL {
  nonisolated struct TerminationSurveyQuery: GraphQLQuery {
    public static let operationName: String = "TerminationSurvey"
    public static let operationDocument: ApolloAPI.OperationDocument = .init(
      definition: .init(
        #"query TerminationSurvey($contractId: UUID!, $redirectionEnabled: Boolean!) { terminationSurvey( contractId: $contractId redirectionEnabled: $redirectionEnabled ) { __typename options { __typename ...TerminationSurveyOptionFragment subOptions { __typename ...TerminationSurveyOptionFragment subOptions { __typename ...TerminationSurveyOptionFragment subOptions { __typename ...TerminationSurveyOptionFragment } } } } action { __typename ... on TerminationFlowActionTerminateWithDate { minDate maxDate extraCoverage { __typename ...TerminationExtraCoverageItemFragment } } ... on TerminationFlowActionDeleteInsurance { extraCoverage { __typename ...TerminationExtraCoverageItemFragment } } } } }"#,
        fragments: [TerminationExtraCoverageItemFragment.self, TerminationSurveyOptionFragment.self, TerminationSurveyOptionRedirectionFragment.self, TerminationSurveyOptionSuggestionFragment.self]
      ))

    public var contractId: UUID
    public var redirectionEnabled: Bool

    public init(
      contractId: UUID,
      redirectionEnabled: Bool
    ) {
      self.contractId = contractId
      self.redirectionEnabled = redirectionEnabled
    }

    @_spi(Unsafe) public var __variables: Variables? { [
      "contractId": contractId,
      "redirectionEnabled": redirectionEnabled
    ] }

    nonisolated public struct Data: OctopusGraphQL.SelectionSet {
      @_spi(Unsafe) public let __data: DataDict
      @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

      @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { OctopusGraphQL.Objects.Query }
      @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
        .field("terminationSurvey", TerminationSurvey.self, arguments: [
          "contractId": .variable("contractId"),
          "redirectionEnabled": .variable("redirectionEnabled")
        ]),
      ] }
      @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
        TerminationSurveyQuery.Data.self
      ] }

      public var terminationSurvey: TerminationSurvey { __data["terminationSurvey"] }

      /// TerminationSurvey
      ///
      /// Parent Type: `TerminationFlowSurvey`
      nonisolated public struct TerminationSurvey: OctopusGraphQL.SelectionSet {
        @_spi(Unsafe) public let __data: DataDict
        @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

        @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { OctopusGraphQL.Objects.TerminationFlowSurvey }
        @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
          .field("__typename", String.self),
          .field("options", [Option].self),
          .field("action", Action.self),
        ] }
        @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
          TerminationSurveyQuery.Data.TerminationSurvey.self
        ] }

        public var options: [Option] { __data["options"] }
        public var action: Action { __data["action"] }

        /// TerminationSurvey.Option
        ///
        /// Parent Type: `TerminationFlowSurveyOption`
        nonisolated public struct Option: OctopusGraphQL.SelectionSet {
          @_spi(Unsafe) public let __data: DataDict
          @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

          @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { OctopusGraphQL.Objects.TerminationFlowSurveyOption }
          @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
            .field("__typename", String.self),
            .field("subOptions", [SubOption].self),
            .fragment(TerminationSurveyOptionFragment.self),
          ] }
          @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
            TerminationSurveyQuery.Data.TerminationSurvey.Option.self,
            TerminationSurveyOptionFragment.self
          ] }

          public var subOptions: [SubOption] { __data["subOptions"] }
          public var id: OctopusGraphQL.ID { __data["id"] }
          public var title: String { __data["title"] }
          public var feedbackRequired: Bool { __data["feedbackRequired"] }
          public var suggestion: Suggestion? { __data["suggestion"] }
          ///  Redirection to an alternative flow, replacing the sub option it was derived from. Only set when the query is sent with redirectionEnabled: true 
          public var redirection: Redirection? { __data["redirection"] }

          public struct Fragments: FragmentContainer {
            @_spi(Unsafe) public let __data: DataDict
            @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

            public var terminationSurveyOptionFragment: TerminationSurveyOptionFragment { _toFragment() }
          }

          /// TerminationSurvey.Option.SubOption
          ///
          /// Parent Type: `TerminationFlowSurveyOption`
          nonisolated public struct SubOption: OctopusGraphQL.SelectionSet {
            @_spi(Unsafe) public let __data: DataDict
            @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

            @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { OctopusGraphQL.Objects.TerminationFlowSurveyOption }
            @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
              .field("__typename", String.self),
              .field("subOptions", [SubOption].self),
              .fragment(TerminationSurveyOptionFragment.self),
            ] }
            @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
              TerminationSurveyQuery.Data.TerminationSurvey.Option.SubOption.self,
              TerminationSurveyOptionFragment.self
            ] }

            public var subOptions: [SubOption] { __data["subOptions"] }
            public var id: OctopusGraphQL.ID { __data["id"] }
            public var title: String { __data["title"] }
            public var feedbackRequired: Bool { __data["feedbackRequired"] }
            public var suggestion: Suggestion? { __data["suggestion"] }
            ///  Redirection to an alternative flow, replacing the sub option it was derived from. Only set when the query is sent with redirectionEnabled: true 
            public var redirection: Redirection? { __data["redirection"] }

            public struct Fragments: FragmentContainer {
              @_spi(Unsafe) public let __data: DataDict
              @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

              public var terminationSurveyOptionFragment: TerminationSurveyOptionFragment { _toFragment() }
            }

            /// TerminationSurvey.Option.SubOption.SubOption
            ///
            /// Parent Type: `TerminationFlowSurveyOption`
            nonisolated public struct SubOption: OctopusGraphQL.SelectionSet {
              @_spi(Unsafe) public let __data: DataDict
              @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

              @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { OctopusGraphQL.Objects.TerminationFlowSurveyOption }
              @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
                .field("__typename", String.self),
                .field("subOptions", [SubOption].self),
                .fragment(TerminationSurveyOptionFragment.self),
              ] }
              @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
                TerminationSurveyQuery.Data.TerminationSurvey.Option.SubOption.SubOption.self,
                TerminationSurveyOptionFragment.self
              ] }

              public var subOptions: [SubOption] { __data["subOptions"] }
              public var id: OctopusGraphQL.ID { __data["id"] }
              public var title: String { __data["title"] }
              public var feedbackRequired: Bool { __data["feedbackRequired"] }
              public var suggestion: Suggestion? { __data["suggestion"] }
              ///  Redirection to an alternative flow, replacing the sub option it was derived from. Only set when the query is sent with redirectionEnabled: true 
              public var redirection: Redirection? { __data["redirection"] }

              public struct Fragments: FragmentContainer {
                @_spi(Unsafe) public let __data: DataDict
                @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

                public var terminationSurveyOptionFragment: TerminationSurveyOptionFragment { _toFragment() }
              }

              /// TerminationSurvey.Option.SubOption.SubOption.SubOption
              ///
              /// Parent Type: `TerminationFlowSurveyOption`
              nonisolated public struct SubOption: OctopusGraphQL.SelectionSet {
                @_spi(Unsafe) public let __data: DataDict
                @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

                @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { OctopusGraphQL.Objects.TerminationFlowSurveyOption }
                @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
                  .field("__typename", String.self),
                  .fragment(TerminationSurveyOptionFragment.self),
                ] }
                @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
                  TerminationSurveyQuery.Data.TerminationSurvey.Option.SubOption.SubOption.SubOption.self,
                  TerminationSurveyOptionFragment.self
                ] }

                public var id: OctopusGraphQL.ID { __data["id"] }
                public var title: String { __data["title"] }
                public var feedbackRequired: Bool { __data["feedbackRequired"] }
                public var suggestion: Suggestion? { __data["suggestion"] }
                ///  Redirection to an alternative flow, replacing the sub option it was derived from. Only set when the query is sent with redirectionEnabled: true 
                public var redirection: Redirection? { __data["redirection"] }

                public struct Fragments: FragmentContainer {
                  @_spi(Unsafe) public let __data: DataDict
                  @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

                  public var terminationSurveyOptionFragment: TerminationSurveyOptionFragment { _toFragment() }
                }

                public typealias Suggestion = TerminationSurveyOptionFragment.Suggestion

                public typealias Redirection = TerminationSurveyOptionFragment.Redirection
              }

              public typealias Suggestion = TerminationSurveyOptionFragment.Suggestion

              public typealias Redirection = TerminationSurveyOptionFragment.Redirection
            }

            public typealias Suggestion = TerminationSurveyOptionFragment.Suggestion

            public typealias Redirection = TerminationSurveyOptionFragment.Redirection
          }

          public typealias Suggestion = TerminationSurveyOptionFragment.Suggestion

          public typealias Redirection = TerminationSurveyOptionFragment.Redirection
        }

        /// TerminationSurvey.Action
        ///
        /// Parent Type: `TerminationFlowAction`
        nonisolated public struct Action: OctopusGraphQL.SelectionSet {
          @_spi(Unsafe) public let __data: DataDict
          @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

          @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { OctopusGraphQL.Unions.TerminationFlowAction }
          @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
            .field("__typename", String.self),
            .inlineFragment(AsTerminationFlowActionTerminateWithDate.self),
            .inlineFragment(AsTerminationFlowActionDeleteInsurance.self),
          ] }
          @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
            TerminationSurveyQuery.Data.TerminationSurvey.Action.self
          ] }

          public var asTerminationFlowActionTerminateWithDate: AsTerminationFlowActionTerminateWithDate? { _asInlineFragment() }
          public var asTerminationFlowActionDeleteInsurance: AsTerminationFlowActionDeleteInsurance? { _asInlineFragment() }

          /// TerminationSurvey.Action.AsTerminationFlowActionTerminateWithDate
          ///
          /// Parent Type: `TerminationFlowActionTerminateWithDate`
          nonisolated public struct AsTerminationFlowActionTerminateWithDate: OctopusGraphQL.InlineFragment {
            @_spi(Unsafe) public let __data: DataDict
            @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

            public typealias RootEntityType = TerminationSurveyQuery.Data.TerminationSurvey.Action
            @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { OctopusGraphQL.Objects.TerminationFlowActionTerminateWithDate }
            @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
              .field("minDate", OctopusGraphQL.Date.self),
              .field("maxDate", OctopusGraphQL.Date.self),
              .field("extraCoverage", [ExtraCoverage].self),
            ] }
            @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
              TerminationSurveyQuery.Data.TerminationSurvey.Action.self,
              TerminationSurveyQuery.Data.TerminationSurvey.Action.AsTerminationFlowActionTerminateWithDate.self
            ] }

            public var minDate: OctopusGraphQL.Date { __data["minDate"] }
            public var maxDate: OctopusGraphQL.Date { __data["maxDate"] }
            public var extraCoverage: [ExtraCoverage] { __data["extraCoverage"] }

            /// TerminationSurvey.Action.AsTerminationFlowActionTerminateWithDate.ExtraCoverage
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
                TerminationSurveyQuery.Data.TerminationSurvey.Action.AsTerminationFlowActionTerminateWithDate.ExtraCoverage.self,
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

          /// TerminationSurvey.Action.AsTerminationFlowActionDeleteInsurance
          ///
          /// Parent Type: `TerminationFlowActionDeleteInsurance`
          nonisolated public struct AsTerminationFlowActionDeleteInsurance: OctopusGraphQL.InlineFragment {
            @_spi(Unsafe) public let __data: DataDict
            @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

            public typealias RootEntityType = TerminationSurveyQuery.Data.TerminationSurvey.Action
            @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { OctopusGraphQL.Objects.TerminationFlowActionDeleteInsurance }
            @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
              .field("extraCoverage", [ExtraCoverage].self),
            ] }
            @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
              TerminationSurveyQuery.Data.TerminationSurvey.Action.self,
              TerminationSurveyQuery.Data.TerminationSurvey.Action.AsTerminationFlowActionDeleteInsurance.self
            ] }

            public var extraCoverage: [ExtraCoverage] { __data["extraCoverage"] }

            /// TerminationSurvey.Action.AsTerminationFlowActionDeleteInsurance.ExtraCoverage
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
                TerminationSurveyQuery.Data.TerminationSurvey.Action.AsTerminationFlowActionDeleteInsurance.ExtraCoverage.self,
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
    }
  }

}