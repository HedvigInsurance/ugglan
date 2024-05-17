import Apollo
import Contracts
import Foundation
import Presentation
import SwiftUI
import hCore
import hCoreUI
import hGraphQL

public struct ProfileState: StateProtocol {
    public var partnerData: PartnerData?
    var openSettingsDirectly = false
    public var memberDetails: MemberDetails?
    var pushNotificationStatus: Int?
    var pushNotificationsSnoozeDate: Date?

    var hasTravelCertificates: Bool = false

    public var isProfileInfoMissing: Bool = true

    var showTravelCertificate: Bool {
        let flags: FeatureFlags = Dependencies.shared.resolve()
        return flags.isTravelInsuranceEnabled && (hasTravelCertificates || canCreateTravelInsurance)
    }

    var canCreateTravelInsurance: Bool {
        let contractStore: ContractStore = globalPresentableStoreContainer.get()
        return !contractStore.state.activeContracts.filter({ $0.supportsTravelCertificate }).isEmpty
    }

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

public struct PartnerData: Codable, Equatable, Hashable {
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

public struct PartnerDataSas: Codable, Equatable, Hashable {
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
