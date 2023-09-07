import Apollo
import Flow
import Foundation
import Presentation
import UIKit
import hCore
import hCoreUI
import hGraphQL

public struct ProfileState: StateProtocol {
    var memberId: String = ""
    var memberFullName: String = ""
    var memberEmail: String = ""
    var memberPhone: String?
    public var partnerData: PartnerData?
    var openSettingsDirectly = true
    public var memberDetails: MemberDetails?
    var pushNotificationStatus: Int?
    var pushNotificationsSnoozeDate: Date?

    public init() {
        UNUserNotificationCenter.current()
            .getNotificationSettings { settings in
                let store: ProfileStore = globalPresentableStoreContainer.get()
                store.send(.setPushNotificationStatus(status: settings.authorizationStatus.rawValue))
            }
    }

    public func pushNotificationCurrentStatus() -> UNAuthorizationStatus {
        if let status = pushNotificationStatus, let status = UNAuthorizationStatus(rawValue: status) {
            return status
        }
        return .notDetermined
    }

    public var shouldShowNotificationCard: Bool {
        let requiredTimeForSnooze: Double = TimeInterval.days(numberOfDays: 30)
        return self.pushNotificationCurrentStatus() != .authorized
            && (self.pushNotificationsSnoozeDate ?? Date().addingTimeInterval(-(requiredTimeForSnooze + 1)))
                .distance(to: Date()) > requiredTimeForSnooze
    }
}

public struct PartnerData: Codable, Equatable {
    public let sas: PartnerDataSas?

    public var shouldShowEuroBonus: Bool {
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
