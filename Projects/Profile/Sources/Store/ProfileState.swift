import Apollo
import Contracts
import Foundation
import PresentableStore
import SwiftUI
import hCore
import hCoreUI
import hGraphQL

public struct ProfileState: StateProtocol {
    public var partnerData: PartnerData?
    public var memberDetails: MemberDetails?
    var pushNotificationStatus: Int?
    var pushNotificationsSnoozeDate: Date?

    var hasTravelCertificates: Bool = false

    @MainActor
    var showTravelCertificate: Bool {
        let flags: FeatureFlags = Dependencies.shared.resolve()
        return flags.isTravelInsuranceEnabled && (hasTravelCertificates || canCreateTravelInsurance)
    }

    @MainActor
    public var canCreateTravelInsurance: Bool {
        let store: ContractStore = globalPresentableStoreContainer.get()
        return store.state.activeContracts.filter({ $0.supportsTravelCertificate }).isEmpty
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
        return self.pushNotificationCurrentStatus() != .authorized
            && (self.pushNotificationsSnoozeDate ?? Date().addingTimeInterval(-(requiredTimeForSnooze + 1)))
                .distance(to: Date()) > requiredTimeForSnooze
    }
}

public struct PartnerData: Codable, Equatable, Hashable, Sendable {
    public let sas: PartnerDataSas?

    public var shouldShowEuroBonus: Bool {
        return sas?.eligible ?? false
    }

    var isConnected: Bool {
        return !(sas?.eurobonusNumber ?? "").isEmpty
    }

    init(sas: PartnerDataSas?) {
        self.sas = sas
    }
}

public struct PartnerDataSas: Codable, Equatable, Hashable, Sendable {
    let eligible: Bool
    let eurobonusNumber: String?
    init(eligible: Bool, eurobonusNumber: String?) {
        self.eligible = eligible
        self.eurobonusNumber = eurobonusNumber
    }
}

public enum ProfileLoadingState: LoadingProtocol {
    case fetchProfileState
    case fetchMemberDetails
    case updateLanguage
}
