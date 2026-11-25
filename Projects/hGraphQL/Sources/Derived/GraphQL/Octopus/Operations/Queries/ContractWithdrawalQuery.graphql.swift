// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI
@_spi(Execution) @_spi(Unsafe) import ApolloAPI

public extension OctopusGraphQL {
  nonisolated struct ContractWithdrawalQuery: GraphQLQuery {
    public static let operationName: String = "ContractWithdrawal"
    public static let operationDocument: ApolloAPI.OperationDocument = .init(
      definition: .init(
        #"query ContractWithdrawal($contractId: UUID!) { currentMember { __typename email contractWithdrawal(contractId: $contractId) { __typename statusText action { __typename ...TerminationFlowActionFragment } } } }"#,
        fragments: [TerminationExtraCoverageItemFragment.self, TerminationFlowActionFragment.self]
      ))

    public var contractId: UUID

    public init(contractId: UUID) {
      self.contractId = contractId
    }

    @_spi(Unsafe) public var __variables: Variables? { ["contractId": contractId] }

    nonisolated public struct Data: OctopusGraphQL.SelectionSet {
      @_spi(Unsafe) public let __data: DataDict
      @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

      @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { OctopusGraphQL.Objects.Query }
      @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
        .field("currentMember", CurrentMember.self),
      ] }
      @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
        ContractWithdrawalQuery.Data.self
      ] }

      /// Gets the currently authenticated member. This is the only valid way to query a `Member` type, and it is based
      /// on the input Authorization header.
      public var currentMember: CurrentMember { __data["currentMember"] }

      /// CurrentMember
      ///
      /// Parent Type: `Member`
      nonisolated public struct CurrentMember: OctopusGraphQL.SelectionSet {
        @_spi(Unsafe) public let __data: DataDict
        @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

        @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { OctopusGraphQL.Objects.Member }
        @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
          .field("__typename", String.self),
          .field("email", String.self),
          .field("contractWithdrawal", ContractWithdrawal.self, arguments: ["contractId": .variable("contractId")]),
        ] }
        @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
          ContractWithdrawalQuery.Data.CurrentMember.self
        ] }

        public var email: String { __data["email"] }
        /// Details for withdrawing from one of the member's contracts under the right of withdrawal (within 14 days of signing).
        /// Fails if the contract does not support withdrawal, see `Contract.supportsWithdrawal`.
        public var contractWithdrawal: ContractWithdrawal { __data["contractWithdrawal"] }

        /// CurrentMember.ContractWithdrawal
        ///
        /// Parent Type: `ContractWithdrawal`
        nonisolated public struct ContractWithdrawal: OctopusGraphQL.SelectionSet {
          @_spi(Unsafe) public let __data: DataDict
          @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

          @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { OctopusGraphQL.Objects.ContractWithdrawal }
          @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
            .field("__typename", String.self),
            .field("statusText", String.self),
            .field("action", Action.self),
          ] }
          @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
            ContractWithdrawalQuery.Data.CurrentMember.ContractWithdrawal.self
          ] }

          ///  Translated text describing the state of the contract: active (with its start date), active in the future, or pending. 
          public var statusText: String { __data["statusText"] }
          /// Same action types as the termination survey. An active contract gets TerminationFlowActionTerminateWithDate
          /// with minDate = maxDate = the date it ends (today, or tomorrow if it started today). A contract that has not
          /// started yet gets TerminationFlowActionDeleteInsurance.
          public var action: Action { __data["action"] }

          /// CurrentMember.ContractWithdrawal.Action
          ///
          /// Parent Type: `TerminationFlowAction`
          nonisolated public struct Action: OctopusGraphQL.SelectionSet {
            @_spi(Unsafe) public let __data: DataDict
            @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

            @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { OctopusGraphQL.Unions.TerminationFlowAction }
            @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
              .field("__typename", String.self),
              .fragment(TerminationFlowActionFragment.self),
            ] }
            @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
              ContractWithdrawalQuery.Data.CurrentMember.ContractWithdrawal.Action.self
            ] }

            public var asTerminationFlowActionTerminateWithDate: AsTerminationFlowActionTerminateWithDate? { _asInlineFragment() }
            public var asTerminationFlowActionDeleteInsurance: AsTerminationFlowActionDeleteInsurance? { _asInlineFragment() }

            public struct Fragments: FragmentContainer {
              @_spi(Unsafe) public let __data: DataDict
              @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

              public var terminationFlowActionFragment: TerminationFlowActionFragment { _toFragment() }
            }

            /// CurrentMember.ContractWithdrawal.Action.AsTerminationFlowActionTerminateWithDate
            ///
            /// Parent Type: `TerminationFlowActionTerminateWithDate`
            nonisolated public struct AsTerminationFlowActionTerminateWithDate: OctopusGraphQL.InlineFragment, ApolloAPI.CompositeInlineFragment {
              @_spi(Unsafe) public let __data: DataDict
              @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

              public typealias RootEntityType = ContractWithdrawalQuery.Data.CurrentMember.ContractWithdrawal.Action
              @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { OctopusGraphQL.Objects.TerminationFlowActionTerminateWithDate }
              @_spi(Execution) public static var __mergedSources: [any ApolloAPI.SelectionSet.Type] { [
                ContractWithdrawalQuery.Data.CurrentMember.ContractWithdrawal.Action.self,
                TerminationFlowActionFragment.AsTerminationFlowActionTerminateWithDate.self
              ] }
              @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
                ContractWithdrawalQuery.Data.CurrentMember.ContractWithdrawal.Action.self,
                ContractWithdrawalQuery.Data.CurrentMember.ContractWithdrawal.Action.AsTerminationFlowActionTerminateWithDate.self,
                TerminationFlowActionFragment.self,
                TerminationFlowActionFragment.AsTerminationFlowActionTerminateWithDate.self
              ] }

              public var minDate: OctopusGraphQL.Date { __data["minDate"] }
              public var maxDate: OctopusGraphQL.Date { __data["maxDate"] }
              public var extraCoverage: [ExtraCoverage] { __data["extraCoverage"] }

              public struct Fragments: FragmentContainer {
                @_spi(Unsafe) public let __data: DataDict
                @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

                public var terminationFlowActionFragment: TerminationFlowActionFragment { _toFragment() }
              }

              public typealias ExtraCoverage = TerminationFlowActionFragment.AsTerminationFlowActionTerminateWithDate.ExtraCoverage
            }

            /// CurrentMember.ContractWithdrawal.Action.AsTerminationFlowActionDeleteInsurance
            ///
            /// Parent Type: `TerminationFlowActionDeleteInsurance`
            nonisolated public struct AsTerminationFlowActionDeleteInsurance: OctopusGraphQL.InlineFragment, ApolloAPI.CompositeInlineFragment {
              @_spi(Unsafe) public let __data: DataDict
              @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

              public typealias RootEntityType = ContractWithdrawalQuery.Data.CurrentMember.ContractWithdrawal.Action
              @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { OctopusGraphQL.Objects.TerminationFlowActionDeleteInsurance }
              @_spi(Execution) public static var __mergedSources: [any ApolloAPI.SelectionSet.Type] { [
                ContractWithdrawalQuery.Data.CurrentMember.ContractWithdrawal.Action.self,
                TerminationFlowActionFragment.AsTerminationFlowActionDeleteInsurance.self
              ] }
              @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
                ContractWithdrawalQuery.Data.CurrentMember.ContractWithdrawal.Action.self,
                ContractWithdrawalQuery.Data.CurrentMember.ContractWithdrawal.Action.AsTerminationFlowActionDeleteInsurance.self,
                TerminationFlowActionFragment.self,
                TerminationFlowActionFragment.AsTerminationFlowActionDeleteInsurance.self
              ] }

              public var extraCoverage: [ExtraCoverage] { __data["extraCoverage"] }

              public struct Fragments: FragmentContainer {
                @_spi(Unsafe) public let __data: DataDict
                @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

                public var terminationFlowActionFragment: TerminationFlowActionFragment { _toFragment() }
              }

              public typealias ExtraCoverage = TerminationFlowActionFragment.AsTerminationFlowActionDeleteInsurance.ExtraCoverage
            }
          }
        }
      }
    }
  }

}