import Apollo
import Flow
import Presentation
import hCore
import hCoreUI
import hGraphQL

import Foundation
import UIKit

public struct ProfileState: StateProtocol {
    var memberId: String = ""
    var memberFullName: String = ""
    var memberEmail: String = ""
    var memberPhone: String?
    var partnerData: PartnerData?
    var openSettingsDirectly = true
    public init() {}
    
    public var shouldShowNotificationCard: Bool {
        let requiredTimeForSnooze: Double = TimeInterval.days(numberOfDays: 30)
//        return self.pushNotificationCurrentStatus() != .authorized
//            && (self.pushNotificationsSnoozeDate ?? Date().addingTimeInterval(-(requiredTimeForSnooze + 1)))
//                .distance(to: Date()) > requiredTimeForSnooze
        return true /* TODO: FIX */
    }
}





public struct PartnerData: Codable, Equatable {
    let sas: PartnerDataSas?

    var shouldShowEuroBonus: Bool {
        return sas?.eligible ?? false
    }

    var isConnected: Bool {
        return !(sas?.eurobonusNumber ?? "").isEmpty
    }
    init?(with data: OctopusGraphQL.PartnerDataFragment) {
        guard let sasData = data.partnerData?.sas else { return nil }
        self.sas = PartnerDataSas(with: sasData)
    }
}

public struct PartnerDataSas: Codable, Equatable {
    let eligible: Bool
    let eurobonusNumber: String?

    init(with data: OctopusGraphQL.PartnerDataFragment.PartnerDatum.Sa) {
        self.eligible = data.eligible
        self.eurobonusNumber = data.eurobonusNumber
    }
}
