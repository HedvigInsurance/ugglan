import Apollo
import Foundation
import PresentableStore
import SwiftUI
import hCoreUI

public struct ProfileState: StateProtocol {
    public var partnerData: PartnerData?
    public var memberDetails: MemberDetails?
    var pushNotificationStatus: Int?
    var pushNotificationsSnoozeDate: Date?

    var hasTravelCertificates: Bool = false
    var canCreateInsuranceEvidence: Bool = false
    var canCreateTravelInsurance: Bool = false

    @MainActor
    var showTravelCertificate: Bool {
        hasTravelCertificates || canCreateTravelInsurance
    }

    public init() {
        Task {
            let settings = await UNUserNotificationCenter.current().notificationSettings()
            let status = settings.authorizationStatus.rawValue
            let store: ProfileStore = await globalPresentableStoreContainer.get()
            store.send(.setPushNotificationStatus(status: status))
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
        return pushNotificationCurrentStatus() != .authorized
            && (pushNotificationsSnoozeDate ?? Date().addingTimeInterval(-(requiredTimeForSnooze + 1)))
                .distance(to: Date()) > requiredTimeForSnooze
    }
}

public struct PartnerData: Codable, Equatable, Hashable, Sendable {
    public let sas: PartnerDataSas?

    public var shouldShowEuroBonus: Bool {
        sas?.eligible ?? false
    }

    var isConnected: Bool {
        !(sas?.eurobonusNumber ?? "").isEmpty
    }

    public init(sas: PartnerDataSas?) {
        self.sas = sas
    }
}

public struct PartnerDataSas: Codable, Equatable, Hashable, Sendable {
    let eligible: Bool
    let eurobonusNumber: String?
    public init(eligible: Bool, eurobonusNumber: String?) {
        self.eligible = eligible
        self.eurobonusNumber = eurobonusNumber
    }
}

public enum ProfileLoadingState: LoadingProtocol {
    case fetchProfileState
    case fetchMemberDetails
    case updateLanguage
}
