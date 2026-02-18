public enum TypeOfContract: String, Codable, CaseIterable, Sendable {
    case seHouseBas = "SE_HOUSE_BAS"
    case seHouse = "SE_HOUSE"
    case seHouseMax = "SE_HOUSE_MAX"

    case seApartmentBrfBas = "SE_APARTMENT_BRF_BAS"
    case seApartmentBrf = "SE_APARTMENT_BRF"
    case seApartmentBrfMax = "SE_APARTMENT_BRF_MAX"

    case seApartmentRentBas = "SE_APARTMENT_RENT_BAS"
    case seApartmentRent = "SE_APARTMENT_RENT"
    case seApartmentRentMax = "SE_APARTMENT_RENT_MAX"

    case seApartmentStudentBrf = "SE_APARTMENT_STUDENT_BRF"
    case seApartmentStudentRent = "SE_APARTMENT_STUDENT_RENT"
    case seAccident = "SE_ACCIDENT"
    case seAccidentStudent = "SE_ACCIDENT_STUDENT"
    case seCarTraffic = "SE_CAR_TRAFFIC"
    case seCarHalf = "SE_CAR_HALF"
    case seCarFull = "SE_CAR_FULL"
    case seCarDecommisioned = "SE_CAR_DECOMMISSIONED"
    case seCarTrialHalf = "SE_CAR_TRIAL_HALF"
    case seCarTrialFull = "SE_CAR_TRIAL_FULL"
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
    case seVacationHome = "SE_VACATION_HOME"
    case unknown = "UNKNOWN"
}

extension TypeOfContract {
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
}

extension TypeOfContract {
    public static func isDecommisioned(for typeOfContract: String) -> Bool {
        typeOfContract.uppercased().contains("DECOMMISSIONED")
    }
}
