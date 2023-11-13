import Apollo
import Flow
import Presentation
import SwiftUI
import hAnalytics
import hCore
import hGraphQL

public struct ContractState: StateProtocol {

    public init() {}

    @Transient(defaultValue: false) public var hasLoadedContractBundlesOnce: Bool
    public var activeContracts: [Contract] = []
    public var terminatedContracts: [Contract] = []
    public var pendingContracts: [Contract] = []
    public var crossSells: [CrossSell] = []

    public var fetchAllCoInsured: [CoInsuredModel] {
        let upComingCoInsured =
            activeContracts.flatMap({
                $0.upcomingChangedAgreement?.coInsured ?? []
            })
            .filter({ !$0.hasMissingData })

        var uniqueUpcomingCoInsured: [CoInsuredModel] = []
        upComingCoInsured.forEach { upComing in
            if uniqueUpcomingCoInsured.first(where: {
                $0.fullName == upComing.fullName
            }) == nil {
                uniqueUpcomingCoInsured.append(upComing)
            }
        }

        let currentCoInsured =
            activeContracts.flatMap({
                $0.currentAgreement?.coInsured ?? []
            })
            .filter({ !$0.hasMissingData })

        var uniqueCoInsured: [CoInsuredModel] = []
        currentCoInsured.forEach { current in
            if uniqueCoInsured.first(where: {
                $0.fullName == current.fullName
            }) == nil {
                uniqueCoInsured.append(current)
            }
        }

        let totalCoInsured =
            uniqueCoInsured
            + uniqueUpcomingCoInsured.filter({ upComing in
                if uniqueCoInsured.count > 0 {
                    return uniqueCoInsured.first(where: {
                        return upComing.fullName == $0.fullName
                    }) == nil
                } else {
                    return true
                }
            })

        return totalCoInsured
    }

    public func contractForId(_ id: String) -> Contract? {
        let activeContracts = activeContracts.compactMap({ $0 })
        let terminatedContracts = terminatedContracts.compactMap({ $0 })
        let pendingContracts = pendingContracts.compactMap({ $0 })
        let allContracts = activeContracts + terminatedContracts + pendingContracts

        if let inBundleContract =
            allContracts
            .first(where: { contract in
                contract.id == id
            })
        {
            return inBundleContract
        }

        return nil
    }
}

extension ContractState {
    public var hasUnseenCrossSell: Bool {
        crossSells.contains(where: { crossSell in !crossSell.hasBeenSeen })
    }

    public var hasActiveContracts: Bool {
        !(activeContracts.compactMap { $0 }.isEmpty)
    }

    public var isTravelInsuranceIncluded: Bool {
        return activeContracts.compactMap({ $0 }).contains(where: { $0.hasTravelInsurance })
            && hAnalyticsExperiment.travelInsurance
    }
}
