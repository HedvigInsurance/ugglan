import Foundation
import hCore

public typealias ExtraBuildingType = String
public struct HouseInformationModel: Codable, Equatable, Hashable {
    let yearOfConstruction: Int
    let ancillaryArea: Int
    let numberOfBathrooms: Int
    let isSubleted: Bool
    var extraBuildings: [ExtraBuilding]
    init(
        yearOfConstruction: Int,
        ancillaryArea: Int,
        numberOfBathrooms: Int,
        isSubleted: Bool,
        extraBuildings: [ExtraBuilding]
    ) {
        self.yearOfConstruction = yearOfConstruction
        self.ancillaryArea = ancillaryArea
        self.numberOfBathrooms = numberOfBathrooms
        self.isSubleted = isSubleted
        self.extraBuildings = extraBuildings
    }

    init() {
        yearOfConstruction = 0
        ancillaryArea = 0
        numberOfBathrooms = 0
        isSubleted = false
        extraBuildings = []
    }

    mutating func removeExtraBuilding(_ extraBuilding: ExtraBuilding) {
        extraBuildings.removeAll(where: { $0.id == extraBuilding.id })
    }

    public struct ExtraBuilding: Codable, Equatable, Hashable {
        let id: String
        let type: ExtraBuildingType
        let livingArea: Int
        let connectedToWater: Bool

        var descriptionText: String {
            var elements: [String] = []
            elements.append("\(self.livingArea) \(L10n.changeAddressSizeSuffix)")
            if connectedToWater {
                elements.append(L10n.changeAddressExtraBuildingWaterConnectedLabel)
            }
            return elements.joined(separator: " ∙ ")
        }
    }
}

extension ExtraBuildingType {
    var translatedValue: String {
        let key = "FIELD_EXTRA_BUIDLINGS_\(self.uppercased())_LABEL"
        let translatedValue = L10nDerivation.init(table: "", key: key, args: []).render()
        return key == translatedValue ? self : translatedValue
    }
}
