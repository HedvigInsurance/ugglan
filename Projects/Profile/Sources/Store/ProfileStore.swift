import AppStateContainer
import Foundation
import UserNotifications
import hCore

@MainActor
@PersistableStore
public final class ProfileStore: AppStore {
    @Inject private var profileService: ProfileClient

    @Published public private(set) var partnerData: PartnerData?
    @Published public private(set) var memberDetails: MemberDetails?
    @Published public private(set) var pushNotificationStatus: Int?
    @Published public private(set) var pushNotificationsSnoozeDate: Date?
    @Published public private(set) var hasTravelCertificates: Bool = false
    @Published public private(set) var canCreateInsuranceEvidence: Bool = false
    @Published public private(set) var canCreateTravelInsurance: Bool = false

    @Transient @Published public private(set) var fetchProfileStateError: String?
    @Transient @Published public private(set) var fetchMemberDetailsError: String?
    @Transient @Published public private(set) var updateLanguageError: String?

    public init() {
        Task { [weak self] in
            let settings = await UNUserNotificationCenter.current().notificationSettings()
            self?.pushNotificationStatus = settings.authorizationStatus.rawValue
        }
    }

    public var showTravelCertificate: Bool {
        hasTravelCertificates || canCreateTravelInsurance
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

    public func fetchProfileState() async {
        do {
            let (member, partner, canCreateInsuranceEvidence, hasTravelInsurances) =
                try await profileService.getProfileState()
            partnerData = partner
            self.canCreateInsuranceEvidence = canCreateInsuranceEvidence
            memberDetails = member
            canCreateTravelInsurance = member.isTravelCertificateEnabled
            hasTravelCertificates = hasTravelInsurances
            fetchProfileStateError = nil
        } catch {
            fetchProfileStateError = error.localizedDescription
        }
    }

    public func fetchMemberDetails() async {
        do {
            memberDetails = try await profileService.getMemberDetails()
            fetchMemberDetailsError = nil
        } catch {
            fetchMemberDetailsError = error.localizedDescription
        }
    }

    public func updateLanguage() async {
        do {
            try await profileService.updateLanguage()
            updateLanguageError = nil
        } catch {
            updateLanguageError = error.localizedDescription
        }
    }

    public func setMember(memberData: MemberDetails) {
        memberDetails = memberData
    }

    public func setMemberDetails(_ details: MemberDetails) {
        memberDetails = details
    }

    public func setMemberEmail(_ email: String) {
        memberDetails?.email = email
    }

    public func setMemberPhone(_ phone: String) {
        memberDetails?.phone = phone
    }

    public func setEurobonusNumber(partnerData: PartnerData?) {
        self.partnerData = partnerData
    }

    public func setPushNotificationStatus(_ status: Int?) {
        pushNotificationStatus = status
    }

    public func setPushNotificationsTo(date: Date?) {
        pushNotificationsSnoozeDate = date
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
