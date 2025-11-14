import Foundation
import SwiftUI
import hCore

extension TypeOfContract {
    public var pillowType: PillowType {
        switch self {
        case .seHouse, .seHouseBas, .seHouseMax:
            return .villa
        case .seApartmentBrf, .seApartmentBrfBas, .seApartmentBrfMax:
            return .homeOwner
        case .seGroupApartmentBrf:
            return .homeOwner
        case .seApartmentRent, .seApartmentRentBas, .seApartmentRentMax:
            return .rental
        case .seApartmentStudentBrf:
            return .student
        case .seApartmentStudentRent:
            return .student
        case .seAccident:
            return .accident
        case .seAccidentStudent:
            return .accident
        case .seCarTraffic, .seCarHalf, .seCarFull, .seCarTrialFull, .seCarTrialHalf, .seCarDecommisioned:
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
        case .unknown:
            return .unknown
        }
    }
}

@MainActor
extension PillowType {
    public var bgImage: Image {
        asset.view
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
