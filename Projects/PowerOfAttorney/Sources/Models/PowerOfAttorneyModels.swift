import AutomaticLog
import Foundation

/// A power of attorney the member has already granted.
public struct PowerOfAttorney: Equatable, Hashable, Identifiable, Sendable {
    public let id: String
    /// Name of the person the power of attorney is granted to, as the member entered it when signing.
    public let name: String
    public let ssn: String
    public let status: Status
    public let level: Level
    /// Link the member shares with the person the power of attorney is granted to.
    public let shareUrl: URL?

    public init(
        id: String,
        name: String,
        ssn: String,
        status: Status,
        level: Level,
        shareUrl: URL?
    ) {
        self.id = id
        self.name = name
        self.ssn = ssn
        self.status = status
        self.level = level
        self.shareUrl = shareUrl
    }

    public enum Status: String, Codable, Hashable, Sendable {
        case active
        case revoked

        // TODO: Localize via Lokalise
        var displayName: String {
            switch self {
            case .active: "Active"
            case .revoked: "Revoked"
            }
        }
    }

    /// Raw values are the API values (`level` in `POST /power-of-attorney`).
    public enum Level: String, CaseIterable, Codable, Hashable, Sendable {
        case full = "Full"
        case partial = "CoInsured"

        // TODO: Localize via Lokalise
        var displayName: String {
            switch self {
            case .full: "Full"
            case .partial: "Partial"
            }
        }
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
