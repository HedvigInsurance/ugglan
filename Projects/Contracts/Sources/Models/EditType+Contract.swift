import EditStakeholders
import Foundation
import hCore

@MainActor
extension EditType {
    public static func getTypes(for contract: Contract) -> [EditType] {
        var editTypes: [EditType] = []

        if contract.supportsChangeTier {
            editTypes.append(.changeTier)
        }

        if contract.supportsCoInsured {
            editTypes.append(.coInsured)
        }

        if contract.supportsCoOwners {
            editTypes.append(.coOwners)
        }

        if contract.supportsAddonRemoval {
            editTypes.append(.removeAddons)
        }

        if contract.supportsTermination {
            editTypes.append(.cancellation)
        }

        return editTypes
    }
}

extension Contract {
    var supportsAddonRemoval: Bool {
        addonsInfo?.existingAddons.contains(where: { $0.isRemovable && $0.endDate == nil }) ?? false
    }
}
