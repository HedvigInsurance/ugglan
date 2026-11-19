import Foundation
@preconcurrency import HedvigShared
import KMPNativeCoroutinesAsync
import KMPNativeCoroutinesCore
import Logger
import hGraphQL

/// Why a Kotlin read failed, in Swift terms. Carries no member data, so every field may be logged.
struct UmbrellaReadFailure: Error, Equatable, Sendable {
    enum Kind: Equatable, Sendable {
        /// The read failed; show the general error and allow a retry.
        case general
        /// A login or logout ended the session the read ran in: drop the result and show nothing.
        case sessionEnded
    }

    /// What went wrong, for logs. The raw values are Kotlin's names, so both apps log the same reason.
    enum Reason: String, Equatable, Sendable {
        case graphqlErrors = "GRAPHQL_ERRORS"
        case network = "NETWORK"
        case http = "HTTP"
        case timeout = "TIMEOUT"
        case stuck = "STUCK"
        case sessionEnded = "SESSION_ENDED"
        case unexpected = "UNEXPECTED"
        /// Swift only: Kotlin reads are switched off.
        case disabled = "DISABLED"
    }

    let kind: Kind
    let reason: Reason
    let readName: String
    let operationName: String
}

extension UmbrellaReadFailure {
    init(_ failure: ReadFailure) {
        self.init(
            kind: Kind(failure.kind),
            reason: Reason(failure.reason),
            readName: failure.readName,
            operationName: failure.operationName
        )
    }

    /// Kotlin reads are switched off, so no holder exists to read from.
    static let disabled = UmbrellaReadFailure(kind: .general, reason: .disabled, readName: "", operationName: "")
}

/// Kotlin exports its enums as open `NS_ENUM`s, which Swift 6 cannot switch over without `@unknown default`. These two
/// mappings are the only such switches; a case Kotlin adds still warns here, and the rest of the app switches over
/// the Swift enums with no default.
extension UmbrellaReadFailure.Kind {
    init(_ kind: ReadFailureKind) {
        switch kind.nsEnum {
        case .general: self = .general
        case .sessionEnded: self = .sessionEnded
        @unknown default: self = .general
        }
    }
}

extension UmbrellaReadFailure.Reason {
    init(_ reason: ReadFailureReason) {
        switch reason.nsEnum {
        case .graphqlErrors: self = .graphqlErrors
        case .network: self = .network
        case .http: self = .http
        case .timeout: self = .timeout
        case .stuck: self = .stuck
        case .sessionEnded: self = .sessionEnded
        case .unexpected: self = .unexpected
        @unknown default: self = .unexpected
        }
    }
}

extension Umbrella {
    /// Runs one Kotlin read. Every Kotlin read goes through here: feature code passes the read, as in
    /// `try await Umbrella.read { $0.fooReads().bar() }`, and never awaits Kotlin itself.
    ///
    /// Throws `UmbrellaReadFailure` when the read failed, and `CancellationError` when the awaiting task cancelled it.
    /// Failures are reported to `graphQlLogger` with names and kinds only.
    static func read<Result>(
        _ read: (IosGraphHolder) -> NativeSuspend<Result, Error, KotlinUnit>
    ) async throws -> Result {
        guard let holder else {
            UmbrellaReadFailureLog.report(.disabled)
            throw UmbrellaReadFailure.disabled
        }
        return try await awaitRead(read(holder))
    }

    /// Awaits `call` and maps its error. `failureOf` reads the Kotlin failure out of an error; nil means a cancel.
    static func awaitRead<Result>(
        _ call: sending @escaping NativeSuspend<Result, Error, KotlinUnit>,
        failureOf: (Error) -> UmbrellaReadFailure? = { error in
            ReadFailures.shared.from(error: error as NSError).map(UmbrellaReadFailure.init)
        }
    ) async throws -> Result {
        do {
            return try await asyncFunction(for: call)
        } catch {
            guard let failure = failureOf(error) else { throw CancellationError() }
            UmbrellaReadFailureLog.report(failure)
            throw failure
        }
    }
}

/// Reports a failed Kotlin read the way Octopus reports its failures: no answer as a warning, anything else as an
/// error, and a session change, which is expected, at debug.
@MainActor
enum UmbrellaReadFailureLog {
    static func report(_ failure: UmbrellaReadFailure) {
        let operation = failure.operationName
        let attributes: [AttributeKey: AttributeValue] = [
            "readName": failure.readName,
            "operationName": operation,
            "reason": failure.reason.rawValue,
        ]
        switch failure.kind {
        case .sessionEnded:
            graphQlLogger.debug("Kotlin read session ended \(operation)", error: nil, attributes: attributes)
        case .general:
            switch failure.reason {
            case .network, .timeout:
                graphQlLogger.warn("Kotlin read network issue \(operation)", error: nil, attributes: attributes)
            case .graphqlErrors, .http, .stuck, .sessionEnded, .unexpected, .disabled:
                graphQlLogger.error("Kotlin read error \(operation)", error: nil, attributes: attributes)
            }
        }
    }
}
