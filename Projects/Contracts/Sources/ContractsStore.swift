import Flow
import Presentation
import Apollo
import hGraphQL
import hCore


public struct ContractState: StateProtocol {
    public init() {}
    
    var contractBundles: [ActiveContractBundle] = []
}

public enum ContractAction: ActionProtocol {
    case fetchContractBundles
    case setContractBundles(activeContractBundles: [ActiveContractBundle])
    case goToMovingFlow
    
    #if compiler(<5.5)
        public func encode(to encoder: Encoder) throws {
            #warning("Waiting for automatic codable conformance from Swift 5.5, remove this when we have upgraded XCode")
            fatalError()
        }

        public init(
            from decoder: Decoder
        ) throws {
            #warning("Waiting for automatic codable conformance from Swift 5.5, remove this when we have upgraded XCode")
            fatalError()
        }
    #endif
}


public final class ContractStore: StateStore<ContractState, ContractAction> {
    @Inject var client: ApolloClient

    public override func effects(
        _ getState: () -> ContractState,
        _ action: ContractAction
    ) -> FiniteSignal<ContractAction>? {
        switch action {
        case .fetchContractBundles:
            return client.fetch(query: GraphQL.ActiveContractBundlesQuery()).map { data in
                data.activeContractBundles.map { ActiveContractBundle(bundle: $0) }
            }.map { activeContractBundles in
                ContractAction.setContractBundles(activeContractBundles: activeContractBundles)
            }.valueThenEndSignal
        case .setContractBundles(activeContractBundles: let activeContractBundles):
            break
        case .goToMovingFlow:
            break
        }
        return nil
    }
    
    public override func reduce(_ state: ContractState, _ action: ContractAction) -> ContractState {
        var newState = state
        switch action {
        case .fetchContractBundles:
            break
        case .setContractBundles(let activeContractBundles):
            newState.contractBundles = activeContractBundles
        case .goToMovingFlow:
            break
        }
        
        return newState
    }
}

public struct ActiveContractBundle: Codable {
    public let contracts: [Contract]
    public let id: String
    public let movingFlowEmbarkId: String?
    
    init(bundle: GraphQL.ActiveContractBundlesQuery.Data.ActiveContractBundle) {
        contracts = bundle.contracts.map { .init(contract: $0) }
        movingFlowEmbarkId = bundle.angelStories.addressChange
        id = bundle.id
    }
    
    public struct Contract: Codable {
        public let upcomingAgreementsTable: DetailAgreementsTable
        public let currentAgreementsTable: DetailAgreementsTable
        public let displayName: String
        public let switchedFromInsuranceProvider: String?
        public let upcomingRenewal: UpcomingRenewal
        public let perils: [Perils]
        public let insurableLimits: [InsurableLimits]
        public let termsAndConditions: TermsAndConditions
        public let currentAgreement: CurrentAgreement
   
        init(contract: GraphQL.ActiveContractBundlesQuery.Data.ActiveContractBundle.Contract) {
            upcomingAgreementsTable = .init(fragment: contract.upcomingAgreementDetailsTable.fragments.detailsTableFragment)
            currentAgreementsTable = .init(fragment: contract.currentAgreementDetailsTable.fragments.detailsTableFragment)
            upcomingRenewal = .init(upcomingRenewal: contract.upcomingRenewal)
            perils = contract.perils.map { .init(fragment: $0.fragments.perilFragment) }
            insurableLimits = contract.insurableLimits.map { .init(fragment: $0.fragments.insurableLimitFragment) }
            termsAndConditions = .init(displayName: contract.termsAndConditions.displayName, url: contract.termsAndConditions.url)
            currentAgreement = .init(currentAgreement: contract.currentAgreement)
            displayName = contract.displayName
            switchedFromInsuranceProvider = contract.switchedFromInsuranceProvider
        }
    }
    
    public struct UpcomingRenewal: Codable {
        public let renewalDate: String?
        public let draftCertificateUrl: String?
        
        init(upcomingRenewal: GraphQL.ActiveContractBundlesQuery.Data.ActiveContractBundle.Contract.UpcomingRenewal?) {
            renewalDate = upcomingRenewal?.renewalDate
            draftCertificateUrl = upcomingRenewal?.draftCertificateUrl
        }
    }
    
    public struct TermsAndConditions: Codable {
        public let displayName: String
        public let url: String
    }
    
    public struct AngelStories: Codable {
        public let addressChange: String
    }
    
    public struct DetailAgreementsTable: Codable {
        public let sections: [Section]
        public let title: String
        init(fragment: GraphQL.DetailsTableFragment) {
            sections = fragment.sections.map { .init(section: $0) }
            title = fragment.title
        }
        
        public struct Section: Codable {
            public let title: String
            public let rows: [Row]
            
            init(section: GraphQL.DetailsTableFragment.Section) {
                title = section.title
                rows = section.rows.map { .init(row: $0) }
            }
        }
        
        public struct Row: Codable {
            public let title: String
            public let subtitle: String?
            public let value: String
            init(row: GraphQL.DetailsTableFragment.Section.Row) {
                title = row.title
                subtitle = row.subtitle
                value = row.value
            }
        }
    }
    
    public struct Perils: Codable {
        public let title: String
        public let description: String
        public let icon: Icon
        public let covered: [String]
        public let exceptions: [String]
        public let info: String
        
        init(fragment: GraphQL.PerilFragment) {
            title = fragment.title
            description = fragment.description
            icon = .init(fragment: fragment.icon.fragments.iconFragment)
            covered = fragment.covered
            exceptions = fragment.exceptions
            info = fragment.info
        }
    }
    
    public struct InsurableLimits: Codable {
        public let label: String
        public let limit: String
        public let description: String
        
        init(fragment: GraphQL.InsurableLimitFragment) {
            label = fragment.label
            limit = fragment.limit
            description = fragment.description
        }
    }
    
    public struct CurrentAgreement: Codable {
        public let certificateUrl: String?
        public let activeFrom: String?
        public let activeTo: String?
        public let premium: MonetaryAmount
        
        init(currentAgreement: GraphQL.ActiveContractBundlesQuery.Data.ActiveContractBundle.Contract.CurrentAgreement) {
            certificateUrl = currentAgreement.certificateUrl
            activeFrom = currentAgreement.activeFrom
            activeTo = currentAgreement.activeTo
            premium = .init(fragment: currentAgreement.premium.fragments.monetaryAmountFragment)
        }
    }
}

public struct Icon: Codable {
    public let dark: String
    public let light: String
    init(fragment: GraphQL.IconFragment) {
        dark = fragment.variants.dark.pdfUrl
        light = fragment.variants.light.pdfUrl
    }
}

public struct MonetaryAmount: Codable {
    public let amount: String
    public let currency: String
    init(fragment: GraphQL.MonetaryAmountFragment) {
        amount = fragment.amount
        currency = fragment.currency
    }
}

extension ActiveContractBundle: Equatable {
    public static func == (lhs: ActiveContractBundle, rhs: ActiveContractBundle) -> Bool {
        return lhs.id == rhs.id
    }
}
