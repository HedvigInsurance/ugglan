import AutomaticLog
import Foundation
import hCore

/// A power of attorney the member has already granted.
public struct PowerOfAttorney: Equatable, Hashable, Identifiable, Sendable {
    public let id: String
    /// Name of the person the power of attorney is granted to, as the member entered it when signing.
    public let name: String
    public let ssn: String
    public let level: PowerOfAttorneyLevel
    /// Link the member shares with the person the power of attorney is granted to.
    public let shareUrl: URL?

    public init(
        id: String,
        name: String,
        ssn: String,
        level: PowerOfAttorneyLevel,
        shareUrl: URL?
    ) {
        self.id = id
        self.name = name
        self.ssn = ssn
        self.level = level
        self.shareUrl = shareUrl
    }
}

/// A power of attorney another member has granted to the member.
public struct ReceivedPowerOfAttorney: Equatable, Hashable, Identifiable, Sendable {
    public let id: String
    /// The member who granted the power of attorney.
    public let memberId: String
    /// The member's own name, as the granting member entered it when signing.
    public let name: String
    public let level: PowerOfAttorneyLevel
    /// Link that logs in with the power of attorney, the same one the granting member shares.
    public let loginUrl: URL?

    public init(
        id: String,
        memberId: String,
        name: String,
        level: PowerOfAttorneyLevel,
        loginUrl: URL?
    ) {
        self.id = id
        self.memberId = memberId
        self.name = name
        self.level = level
        self.loginUrl = loginUrl
    }
}

/// A person a power of attorney can be granted to (e.g. a co-insured).
@Loggable
public struct PowerOfAttorneyUser: Equatable, Hashable, Identifiable, Sendable {
    public let id: String
    public let firstName: String
    public let lastName: String
    @Masked public let ssn: String?

    public var fullName: String {
        firstName + " " + lastName
    }

    public init(id: String, firstName: String, lastName: String, ssn: String?) {
        self.id = id
        self.firstName = firstName
        self.lastName = lastName
        self.ssn = ssn
    }
}

/// A started BankID signing of a new power of attorney.
@Loggable
public struct PowerOfAttorneySigningSession: Equatable, Sendable {
    public let id: String
    /// Polled for the signing status.
    public let pollUrl: URL
    /// Used to open the BankID app.
    @Masked public let autoStartToken: String
    /// Initial animated BankID QR code data.
    @Masked public let liveQrCodeData: String?

    public init(id: String, pollUrl: URL, autoStartToken: String, liveQrCodeData: String?) {
        self.id = id
        self.pollUrl = pollUrl
        self.autoStartToken = autoStartToken
        self.liveQrCodeData = liveQrCodeData
    }
}

public enum PowerOfAttorneySigningStatus: Equatable, Sendable {
    /// Waiting for the member to sign. `qrCode` is the latest animated BankID QR code data (changes on every poll),
    /// `statusText` is a text from the backend to show the member.
    case pending(qrCode: String?, statusText: String?)
    /// Signing completed. `shareUrl` is the link the member shares with the co-insured.
    case success(shareUrl: URL)
    case failed(message: String)
}

public enum PowerOfAttorneyError: Error {
    case error(message: String)
    /// The BankID order lived longer than ~3 minutes (poll returned 404). Start over.
    case signingExpired
}

extension PowerOfAttorneyError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case let .error(message):
            return message
        case .signingExpired:
            // TODO: Localize via Lokalise
            return "The signing took too long. Please try again."
        }
    }
}
