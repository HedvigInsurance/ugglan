public struct InsurableLimits: Codable, Hashable, Identifiable, Sendable {
    public var id: String?
    public let label: String
    public let limit: String
    public let description: String
    public let type: InsurabeLimitType?

    public init(
        label: String,
        limit: String,
        description: String,
        type: InsurabeLimitType? = nil
    ) {
        self.label = label
        self.limit = limit
        self.description = description
        self.type = type
    }

    public init(
        _ data: OctopusGraphQL.ProductVariantFragment.InsurableLimit
    ) {
        label = data.label
        limit = data.limit
        description = data.description
        type = nil
    }

    public init(
        _ data: OctopusGraphQL.AddonVariantFragment.InsurableLimit
    ) {
        label = data.label
        limit = data.limit
        description = data.description
        type = data.type.asInsurableLimit
    }
}

public enum InsurabeLimitType: Sendable, Codable {
    case DEDUCTIBLE
    case DEDUCTIBLE_NATURE_DAMAGE
    case DEDUCTIBLE_ALL_RISK
    case INSURED_AMOUNT
    case GOODS_INDIVIDUAL
    case GOODS_FAMILY
    case TRAVEL_DAYS
    case MEDICAL_EXPENSES
    case LOST_LUGGAGE
    case BIKE
    case PERMANENT_INJURY
    case TREATMENT
    case DENTAL_TREATMENT
    case TRAVEL_ILLNESS_INJURY_TRANSPORTATION_HOME
    case TRAVEL_DELAYED_ON_TRIP
    case TRAVEL_DELAYED_LUGGAGE
    case TRAVEL_CANCELLATION
    case unknown
}

extension GraphQLEnum<OctopusGraphQL.InsurableLimitType> {
    var asInsurableLimit: InsurabeLimitType {
        switch self {
        case let .case(type):
            switch type {
            case .bike:
                return .BIKE
            case .deductible:
                return .DEDUCTIBLE
            case .deductibleAllRisk:
                return .DEDUCTIBLE_ALL_RISK
            case .deductibleNatureDamage:
                return .DEDUCTIBLE_NATURE_DAMAGE
            case .dentalTreatment:
                return .DENTAL_TREATMENT
            case .goodsFamily:
                return .GOODS_FAMILY
            case .goodsIndividual:
                return .GOODS_INDIVIDUAL
            case .medicalExpenses:
                return .MEDICAL_EXPENSES
            case .permanentInjury:
                return .PERMANENT_INJURY
            case .travelDelayedOnTrip:
                return .TRAVEL_DELAYED_ON_TRIP
            case .insuredAmount:
                return .INSURED_AMOUNT
            case .travelDays:
                return .TRAVEL_DAYS
            case .lostLuggage:
                return .LOST_LUGGAGE
            case .treatment:
                return .TREATMENT
            case .travelIllnessInjuryTransportationHome:
                return .TRAVEL_ILLNESS_INJURY_TRANSPORTATION_HOME
            case .travelDelayedLuggage:
                return .TRAVEL_DELAYED_LUGGAGE
            case .travelCancellation:
                return .TRAVEL_CANCELLATION
            }
        default:
            return .unknown
        }
    }
}
