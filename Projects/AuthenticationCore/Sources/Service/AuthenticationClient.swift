import Foundation

@MainActor
public protocol AuthenticationClient {
    func submit(otpState: OTPState) async throws -> String
    func start(with otpState: OTPState) async throws -> (verifyUrl: URL, resendUrl: URL, maskedEmail: String?)
    func resend(otp otpState: OTPState) async throws
    /// Starts a BankID login. With a `powerOfAttorneyId` (from a power of attorney link) the person named in that
    /// power of attorney logs in to the member's account; the personal number comes from the power of attorney.
    func startSeBankId(
        powerOfAttorneyId: String?,
        updateStatusTo: @escaping (_: ObserveStatusResponseType) -> Void
    ) async throws
    func logout() async throws
    func exchange(code: String) async throws
    func exchange(refreshToken: String) async throws
    /// Who is using the app with a power of attorney, or `nil` for a normal member session. Fetched and stored when a
    /// power of attorney BankID login completes (that login fails if it can't be fetched), so this needs no network.
    func getPowerOfAttorney() async -> PowerOfAttorneyClaim?
}

public struct PowerOfAttorneyClaim: Codable, Equatable, Sendable {
    /// Personal number of the person using the power of attorney
    public let ssn: String
    /// Name of the person using the power of attorney
    public let name: String
    /// What the person is allowed to do, as sent by the backend (`Full`, `CoInsured`, ...)
    public let level: String

    /// Only `Full` grants the whole app, any other (or unknown) level is treated as the most limited one.
    public var hasFullAccess: Bool { level == "Full" }

    public init(ssn: String, name: String, level: String) {
        self.ssn = ssn
        self.name = name
        self.level = level
    }
}

public enum ObserveStatusResponseType {
    case started(code: String)
    case pending(qrCode: String?)
    case completed
}
