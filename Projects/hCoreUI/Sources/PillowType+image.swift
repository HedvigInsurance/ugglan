import Foundation
import SwiftUI
import hCore
import hGraphQL

public enum TypeOfContract: String, Codable, CaseIterable, Sendable {
    case seHouse = "SE_HOUSE"
    case seApartmentBrf = "SE_APARTMENT_BRF"
    case seApartmentRent = "SE_APARTMENT_RENT"
    case seApartmentStudentBrf = "SE_APARTMENT_STUDENT_BRF"
    case seApartmentStudentRent = "SE_APARTMENT_STUDENT_RENT"
    case seAccident = "SE_ACCIDENT"
    case seAccidentStudent = "SE_ACCIDENT_STUDENT"
    case seCarTraffic = "SE_CAR_TRAFFIC"
    case seCarHalf = "SE_CAR_HALF"
    case seCarFull = "SE_CAR_FULL"
    case seCarTrialFull = "SE_CAR_TRIAL_FULL"
    case seCarTrialHalf = "SE_CAR_TRIAL_HALF"
    case seGroupApartmentBrf = "SE_GROUP_APARTMENT_BRF"
    case seGroupApartmentRent = "SE_GROUP_APARTMENT_RENT"
    case seQasaShortTermRental = "SE_QASA_SHORT_TERM_RENTAL"
    case seQasaLongTermRental = "SE_QASA_LONG_TERM_RENTAL"
    case seDogBasic = "SE_DOG_BASIC"
    case seDogStandard = "SE_DOG_STANDARD"
    case seDogPremium = "SE_DOG_PREMIUM"
    case seCatBasic = "SE_CAT_BASIC"
    case seCatStandard = "SE_CAT_STANDARD"
    case seCatPremium = "SE_CAT_PREMIUM"
    case noHouse = "NO_HOUSE"
    case noHomeContentOwn = "NO_HOME_CONTENT_OWN"
    case noHomeContentRent = "NO_HOME_CONTENT_RENT"
    case noHomeContentYouthOwn = "NO_HOME_CONTENT_YOUTH_OWN"
    case noHomeContentYouthRent = "NO_HOME_CONTENT_YOUTH_RENT"
    case noHomeContentStudentOwn = "NO_HOME_CONTENT_STUDENT_OWN"
    case noHomeContentStudentRent = "NO_HOME_CONTENT_STUDENT_RENT"
    case noTravel = "NO_TRAVEL"
    case noTravelYouth = "NO_TRAVEL_YOUTH"
    case noTravelStudent = "NO_TRAVEL_STUDENT"
    case noAccident = "NO_ACCIDENT"
    case dkHomeContentOwn = "DK_HOME_CONTENT_OWN"
    case dkHomeContentRent = "DK_HOME_CONTENT_RENT"
    case dkHomeContentStudentOwn = "DK_HOME_CONTENT_STUDENT_OWN"
    case dkHomeContentStudentRent = "DK_HOME_CONTENT_STUDENT_RENT"
    case dkHouse = "DK_HOUSE"
    case dkAccident = "DK_ACCIDENT"
    case dkAccidentStudent = "DK_ACCIDENT_STUDENT"
    case dkTravel = "DK_TRAVEL"
    case dkTravelStudent = "DK_TRAVEL_STUDENT"
    case unknown = "UNKNOWN"

    public static func resolve(for typeOfContract: String) -> Self {
        if let concreteTypeOfContract = Self(rawValue: typeOfContract) {
            return concreteTypeOfContract
        }

        if let mostLikelyTypeOfContract = TypeOfContract.allCases.first(where: {
            typeOfContract.contains($0.rawValue)
        }) {
            return mostLikelyTypeOfContract
        }
        Task { @MainActor in
            log.warn(
                "Got an unknown type of contract \(typeOfContract) that couldn't be resolved.",
                error: nil,
                attributes: nil
            )
        }
        return .unknown
    }

    public var pillowType: PillowType {
        switch self {
        case .seHouse:
            return .villa
        case .seApartmentBrf:
            return .homeOwner
        case .seGroupApartmentBrf:
            return .homeOwner
        case .seApartmentRent:
            return .rental
        case .seApartmentStudentBrf:
            return .student
        case .seApartmentStudentRent:
            return .student
        case .seAccident:
            return .accident
        case .seAccidentStudent:
            return .accident
        case .seCarTraffic:
            return .car
        case .seCarHalf:
            return .car
        case .seCarFull:
            return .car
        case .seCarTrialFull:
            return .car
        case .seCarTrialHalf:
            return .car
        case .seGroupApartmentRent:
            return .rental
        case .seQasaShortTermRental:
            return .rental
        case .seQasaLongTermRental:
            return .rental
        case .seDogBasic:
            return .dog
        case .seDogStandard:
            return .dog
        case .seDogPremium:
            return .dog
        case .seCatBasic:
            return .cat
        case .seCatStandard:
            return .cat
        case .seCatPremium:
            return .cat
        case .noHouse:
            return .villa
        case .noHomeContentOwn:
            return .homeOwner
        case .noHomeContentRent:
            return .rental
        case .noHomeContentYouthOwn:
            return .homeOwner
        case .noHomeContentYouthRent:
            return .rental
        case .noHomeContentStudentOwn:
            return .student
        case .noHomeContentStudentRent:
            return .student
        case .noTravel:
            return .travel
        case .noTravelYouth:
            return .travel
        case .noTravelStudent:
            return .travel
        case .noAccident:
            return .accident
        case .dkHomeContentOwn:
            return .homeOwner
        case .dkHomeContentRent:
            return .rental
        case .dkHomeContentStudentOwn:
            return .homeOwner
        case .dkHomeContentStudentRent:
            return .rental
        case .dkHouse:
            return .villa
        case .dkAccident:
            return .accident
        case .dkAccidentStudent:
            return .accident
        case .dkTravel:
            return .travel
        case .dkTravelStudent:
            return .travel
        case .unknown:
            return .unknown
        }
    }
}

@MainActor
extension PillowType {
    public var bgImage: UIImage {
        asset.image
    }

    private var asset: ImageAsset {
        switch self {
        case .accident:
            return hCoreUIAssets.bigPillowAccident
        case .car:
            return hCoreUIAssets.bigPillowCar
        case .cat:
            return hCoreUIAssets.bigPillowCat
        case .dog:
            return hCoreUIAssets.bigPillowDog
        case .home:
            return hCoreUIAssets.bigPillowHome
        case .homeOwner:
            return hCoreUIAssets.bigPillowHomeowner
        case .pet:
            return hCoreUIAssets.bigPillowPet
        case .rental:
            return hCoreUIAssets.bigPillowRental
        case .student:
            return hCoreUIAssets.bigPillowStudent
        case .travel:
            return hCoreUIAssets.bigPillowHome
        case .villa:
            return hCoreUIAssets.bigPillowVilla
        case .unknown:
            return hCoreUIAssets.bigPillowHome
        }
    }
}
