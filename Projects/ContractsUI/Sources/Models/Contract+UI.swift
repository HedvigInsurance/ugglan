import ContractsCore
import Foundation
import hCore
import hCoreUI

extension Contract {
    @MainActor
    public var pillowType: PillowType? {
        if let terminationDate = terminationDate?.localDateToDate,
            let localDate = Date().localDateString.localDateToDate
        {
            let daysBetween = terminationDate.daysBetween(start: localDate)
            if daysBetween < 0 {
                return nil
            }
        }
        return typeOfContract.pillowType
    }
}

extension Contract: @retroactive TrackingViewNameProtocol {
    public var nameForTracking: String {
        .init(describing: ContractDetail.self)
    }
}

extension ExistingAddon {
    var availableActions: [AddonAction.AddonActionType] {
        var types = [AddonAction.AddonActionType]()
        if isUpgradable {
            types.append(.upgrade)
        }
        if isRemovable {
            types.append(.removal)
        }
        return types
    }
}
