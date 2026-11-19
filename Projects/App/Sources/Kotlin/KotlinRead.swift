import Foundation
@preconcurrency import HedvigShared
import KMPNativeCoroutinesAsync
import KMPNativeCoroutinesCore
import Logger
import hGraphQL

/// Why a Kotlin read failed, in Swift terms. Carries no member data, so every field may be logged.
struct KotlinReadFailure: Error, Equatable, Sendable {
    enum Kind: Equatable, Sendable {
        /// The read failed; show the general error and allow a retry.
        case general
        /// A login or logout ended the session the read ran in: drop the result and show nothing.
        case sessionEnded
    }

    let kind: Kind
    let reason: String
    let readName: String
    let operationName: String
}

extension KotlinReadFailure {
    init(_ failure: ReadFailure) {
        self.init(
            kind: Kind(failure.kind),
            reason: failure.reason.name,
            readName: failure.readName,
            operationName: failure.operationName
        )
    }

    /// Kotlin reads are switched off, so no holder exists to read from.
    static let disabled = KotlinReadFailure(kind: .general, reason: "DISABLED", readName: "", operationName: "")
}

extension KotlinReadFailure.Kind {
    init(_ kind: ReadFailureKind) {
        switch kind.nsEnum {
        case .sessionEnded: self = .sessionEnded
        default: self = .general
        }
    }
}

/// Runs one Kotlin read. Every Kotlin read goes through here: feature code passes the read, as in
/// `try await kotlinRead { $0.fooReads().bar() }`, and never awaits Kotlin itself.
///
/// Throws `KotlinReadFailure` when the read failed, and `CancellationError` when the awaiting task cancelled it.
/// Failures are reported to `graphQlLogger` with names and kinds only.
@MainActor
func kotlinRead<Result>(
    _ read: (IosGraphHolder) -> NativeSuspend<Result, Error, KotlinUnit>
) async throws -> Result {
    guard let holder = KotlinReads.holder else {
        KotlinReadFailureLog.report(.disabled)
        throw KotlinReadFailure.disabled
    }
    return try await awaitKotlinRead(read(holder))
}

/// Awaits `call` and maps its error. `failureOf` reads the Kotlin failure out of an error; nil means a cancel.
@MainActor
func awaitKotlinRead<Result>(
    _ call: sending @escaping NativeSuspend<Result, Error, KotlinUnit>,
    failureOf: (Error) -> KotlinReadFailure? = { error in
        ReadFailures.shared.from(error: error as NSError).map(KotlinReadFailure.init)
    }
) async throws -> Result {
    do {
        return try await asyncFunction(for: call)
    } catch {
        guard let failure = failureOf(error) else { throw CancellationError() }
        KotlinReadFailureLog.report(failure)
        throw failure
    }
}

/// Reports a failed Kotlin read the way Octopus reports its failures: no answer as a warning, anything else as an
/// error, and a session change, which is expected, at debug.
@MainActor
enum KotlinReadFailureLog {
    static let networkReasons: Set<String> = ["NETWORK", "TIMEOUT"]

    static func report(_ failure: KotlinReadFailure) {
        let operation = failure.operationName
        let attributes: [AttributeKey: AttributeValue] = [
            "readName": failure.readName,
            "operationName": operation,
            "reason": failure.reason,
        ]
        switch failure.kind {
        case .sessionEnded:
            graphQlLogger.debug("Kotlin read session ended \(operation)", error: nil, attributes: attributes)
        case .general where networkReasons.contains(failure.reason):
            graphQlLogger.warn("Kotlin read network issue \(operation)", error: nil, attributes: attributes)
        case .general:
            graphQlLogger.error("Kotlin read error \(operation)", error: nil, attributes: attributes)
        }
    }
}
