import Foundation
import hCore

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
    /// Logs out the current session. With `keepingSavedSession` a session saved by `saveSessionForSwitchBack()`
    /// survives (and isn't revoked), otherwise it's dropped too.
    func logout(keepingSavedSession: Bool) async throws
    func exchange(code: String) async throws
    func exchange(refreshToken: String) async throws
    /// Who is using the app with a power of attorney, or `nil` for a normal member session. Fetched and stored when a
    /// power of attorney BankID login completes (that login fails if it can't be fetched), so this needs no network.
    func getPowerOfAttorney() async -> ActingPowerOfAttorney?
    /// Before switching from the member's own session to a power of attorney login: saves that session so the member
    /// can return to it. Does nothing in a power of attorney session, so the member's own session stays the saved one.
    func saveSessionForSwitchBack() async
    /// Whether there's a saved, still valid session of the member's own to switch back to.
    func hasSavedSession() async -> Bool
    /// Replaces the current (power of attorney) session with the saved one and revokes it. `false` if there's none.
    func restoreSavedSession() async -> Bool
}

public enum ObserveStatusResponseType {
    case started(code: String)
    case pending(qrCode: String?)
    case completed
}
