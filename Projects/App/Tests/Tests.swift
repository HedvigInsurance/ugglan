import Environment
import Foundation
@preconcurrency import HedvigShared
import KMPNativeCoroutinesCore
import Logger
import Testing
import hGraphQL

@testable import Ugglan

/// The app's UI tests are the XCUITest suites in Tests/UITests, which build into the AppUITests target. These run
/// hosted by the app, against the real Kotlin framework, without a network request.
@MainActor
@Suite(.serialized)
struct KotlinReadsTests {
    @Test
    func theSwitchIsOffWithoutTheLaunchArgument() {
        #expect(!ProcessInfo.processInfo.arguments.contains(KotlinReadsSwitch.launchArgument))
        #expect(!KotlinReadsSwitch.current.isOn)
        #expect(!KotlinReads.isEnabled)
        #expect(KotlinReads.holder == nil)
    }

    /// Creates the process's one holder, which builds nothing and calls no input, so no request is sent.
    @Test
    func theHolderIsCreatedOncePerProcess() {
        let first = KotlinReads.existingOrNewHolder()
        let second = KotlinReads.existingOrNewHolder()
        #expect(first === second)
        KotlinReads.sessionStarted()
        KotlinReads.sessionEnded()
    }

    @Test
    func theRemoteFlagIsOffUntilItExists() {
        #expect(!KotlinReadsRemoteFlag.isOn)
    }

    @Test
    func theLaunchArgumentTurnsTheSwitchOnAloneOrWithAYesValue() {
        #expect(KotlinReadsSwitch.isOn(arguments: ["app", "-kotlinReads"]))
        #expect(KotlinReadsSwitch.isOn(arguments: ["app", "-kotlinReads", "YES"]))
        #expect(KotlinReadsSwitch.isOn(arguments: ["app", "-kotlinReads", "-other"]))
        #expect(!KotlinReadsSwitch.isOn(arguments: ["app", "-kotlinReads", "NO"]))
        #expect(!KotlinReadsSwitch.isOn(arguments: ["app", "-kotlinReads", "0"]))
        #expect(!KotlinReadsSwitch.isOn(arguments: ["app", "-other"]))
    }

    @Test
    func aReadWhileTheSwitchIsOffFailsWithoutCreatingAHolder() async {
        let logger = RecordingLogger()
        await withGraphQlLogger(logger) {
            await #expect(throws: KotlinReadFailure.disabled) {
                _ = try await kotlinRead { _ in Self.succeeding("unused") }
            }
        }
        #expect(logger.lines.map(\.level) == ["error"])
    }

    @Test
    func aSuccessfulReadReturnsItsValueAndLogsNothing() async throws {
        let logger = RecordingLogger()
        let value = try await withGraphQlLogger(logger) {
            try await awaitKotlinRead(Self.succeeding("value"))
        }
        #expect(value == "value")
        #expect(logger.lines.isEmpty)
    }

    @Test
    func anErrorKotlinDoesNotRecogniseAsAFailureIsACancel() async {
        let logger = RecordingLogger()
        await withGraphQlLogger(logger) {
            await #expect(throws: CancellationError.self) {
                let call: NativeSuspend<String, Error, KotlinUnit> = Self.failing(NSError(domain: "test", code: 1))
                _ = try await awaitKotlinRead(call)
            }
        }
        #expect(logger.lines.isEmpty)
    }

    @Test
    func kotlinsCancelArrivesAsACancel() async {
        let call: NativeSuspend<String, Error, KotlinUnit> = { _, _, onCancelled in
            _ = onCancelled(CancellationError(), KotlinUnit())
            return { KotlinUnit() }
        }
        await #expect(throws: CancellationError.self) {
            _ = try await awaitKotlinRead(call)
        }
    }

    @Test
    func aGeneralFailureIsThrownAndReportedAsAnError() async {
        let failure = KotlinReadFailure(
            kind: .general,
            reason: .graphqlErrors,
            readName: "example.read",
            operationName: "ExampleQuery"
        )
        let logger = RecordingLogger()
        await withGraphQlLogger(logger) {
            await #expect(throws: failure) {
                _ = try await awaitKotlinRead(
                    Self.failing(NSError(domain: "test", code: 1)) as NativeSuspend<String, Error, KotlinUnit>,
                    failureOf: { _ in failure }
                )
            }
        }
        #expect(logger.lines.map(\.level) == ["error"])
        #expect(logger.lines.first?.attributes == ["readName", "operationName", "reason"])
    }

    @Test
    func aNetworkFailureIsReportedAsAWarning() async {
        let failure = KotlinReadFailure(kind: .general, reason: .timeout, readName: "a", operationName: "A")
        let logger = RecordingLogger()
        await withGraphQlLogger(logger) {
            _ = try? await awaitKotlinRead(
                Self.failing(NSError(domain: "test", code: 1)) as NativeSuspend<String, Error, KotlinUnit>,
                failureOf: { _ in failure }
            )
        }
        #expect(logger.lines.map(\.level) == ["warn"])
    }

    @Test
    func anEndedSessionIsThrownAndReportedAtDebug() async {
        let failure = KotlinReadFailure(kind: .sessionEnded, reason: .sessionEnded, readName: "a", operationName: "A")
        let logger = RecordingLogger()
        await withGraphQlLogger(logger) {
            await #expect(throws: failure) {
                _ = try await awaitKotlinRead(
                    Self.failing(NSError(domain: "test", code: 1)) as NativeSuspend<String, Error, KotlinUnit>,
                    failureOf: { _ in failure }
                )
            }
        }
        #expect(logger.lines.map(\.level) == ["debug"])
    }

    @Test
    func kotlinsFailureKindsMapToSwiftKinds() {
        #expect(KotlinReadFailure.Kind(ReadFailureKind.general) == .general)
        #expect(KotlinReadFailure.Kind(ReadFailureKind.sessionEnded) == .sessionEnded)
    }

    @Test
    func kotlinsFailureReasonsMapToSwiftReasonsWithKotlinsNames() {
        let pairs: [(ReadFailureReason, KotlinReadFailure.Reason)] = [
            (.graphqlErrors, .graphqlErrors), (.network, .network), (.http, .http), (.timeout, .timeout),
            (.stuck, .stuck), (.sessionEnded, .sessionEnded), (.unexpected, .unexpected),
        ]
        #expect(pairs.count == ReadFailureReason.entries.count)
        for (kotlin, swift) in pairs {
            #expect(KotlinReadFailure.Reason(kotlin) == swift)
            #expect(swift.rawValue == kotlin.name)
        }
    }

    @Test
    func kotlinLinesBeforeTheLoggerIsReadyAreHeldAndWrittenInOrderOnAttach() {
        let destination = KotlinLogDestination(capacity: 10)
        destination.write(.info, "first", attributes: ["source": "kotlin"])
        destination.write(.warn, "second", attributes: ["source": "kotlin"])
        #expect(destination.pending.count == 2)

        let logger = RecordingLogger()
        destination.attach(logger)
        destination.write(.error, "third", attributes: ["source": "kotlin"])

        #expect(destination.pending.isEmpty)
        #expect(logger.lines.map(\.message) == ["first", "second", "third"])
        #expect(logger.lines.map(\.level) == ["info", "warn", "error"])
    }

    @Test
    func heldKotlinLinesAreBoundedAndTheDropIsReported() {
        let destination = KotlinLogDestination(capacity: 2)
        for message in ["a", "b", "c", "d"] {
            destination.write(.info, message, attributes: [:])
        }
        #expect(destination.pending.map(\.message) == ["c", "d"])

        let logger = RecordingLogger()
        destination.attach(logger)

        #expect(logger.lines.map(\.level) == ["warn", "info", "info"])
        #expect(logger.lines.first?.attributes == ["source", "dropped"])
        #expect(logger.lines.dropFirst().map(\.message) == ["c", "d"])
    }

    @Test
    func theFlavorFollowsTheEnvironmentAndBuild() {
        #expect(KotlinAppFlavor.flavor(for: .production, isDebugBuild: true) == .production)
        #expect(KotlinAppFlavor.flavor(for: .production, isDebugBuild: false) == .production)
        #expect(KotlinAppFlavor.flavor(for: .staging, isDebugBuild: true) == .develop)
        #expect(KotlinAppFlavor.flavor(for: .staging, isDebugBuild: false) == .staging)
    }

    @Test
    func productionLogsOnlyGraphqlErrorText() {
        let production = KotlinNetworkLogPolicy.policy(for: .production)
        #expect(!production.logsHttpBodies)
        #expect(!production.logsGraphqlData)
        #expect(production.logsGraphqlErrors)
        for flavor in [Flavor.staging, Flavor.develop] {
            let policy = KotlinNetworkLogPolicy.policy(for: flavor)
            #expect(policy.logsHttpBodies && policy.logsGraphqlData && policy.logsGraphqlErrors)
        }
    }

    @Test
    func kotlinLogPrioritiesMapToLoggerLevels() {
        #expect(KotlinLogLevel(LogPriority.verbose) == .debug)
        #expect(KotlinLogLevel(LogPriority.debug) == .debug)
        #expect(KotlinLogLevel(LogPriority.info) == .info)
        #expect(KotlinLogLevel(LogPriority.warn) == .warn)
        #expect(KotlinLogLevel(LogPriority.error) == .error)
        #expect(KotlinLogLevel(LogPriority.assert) == .critical)
    }

    @Test
    func theLanguageSourceFollowsTheAppLocale() {
        let source = KotlinLanguageSource()
        #expect(
            [Language.svSe, Language.enSe].contains(source.currentLanguage())
        )
    }

    private static func succeeding<T>(_ value: T) -> NativeSuspend<T, Error, KotlinUnit> {
        { onResult, _, _ in
            _ = onResult(value, KotlinUnit())
            return { KotlinUnit() }
        }
    }

    private static func failing<T>(_ error: Error) -> NativeSuspend<T, Error, KotlinUnit> {
        { _, onError, _ in
            _ = onError(error, KotlinUnit())
            return { KotlinUnit() }
        }
    }

    @discardableResult
    private func withGraphQlLogger<T>(_ logger: RecordingLogger, _ body: () async throws -> T) async rethrows -> T {
        let previous = graphQlLogger
        graphQlLogger = logger
        defer { graphQlLogger = previous }
        return try await body()
    }
}

@MainActor
private final class RecordingLogger: Logging {
    struct Line {
        let level: String
        let message: String
        let attributes: Set<String>
    }

    var lines: [Line] = []

    private func record(_ level: String, _ message: String, _ keys: Set<String>) {
        lines.append(Line(level: level, message: message, attributes: keys))
    }

    private nonisolated static func keys(_ attributes: [AttributeKey: AttributeValue]?) -> Set<String> {
        Set(attributes?.keys.map { $0 } ?? [])
    }

    nonisolated func debug(_ message: String, error _: Error?, attributes: [AttributeKey: AttributeValue]?) {
        let keys = Self.keys(attributes)
        MainActor.assumeIsolated { record("debug", message, keys) }
    }

    nonisolated func info(_ message: String, error _: Error?, attributes: [AttributeKey: AttributeValue]?) {
        let keys = Self.keys(attributes)
        MainActor.assumeIsolated { record("info", message, keys) }
    }

    nonisolated func notice(_ message: String, error _: Error?, attributes: [AttributeKey: AttributeValue]?) {
        let keys = Self.keys(attributes)
        MainActor.assumeIsolated { record("notice", message, keys) }
    }

    nonisolated func warn(_ message: String, error _: Error?, attributes: [AttributeKey: AttributeValue]?) {
        let keys = Self.keys(attributes)
        MainActor.assumeIsolated { record("warn", message, keys) }
    }

    nonisolated func error(_ message: String, error _: Error?, attributes: [AttributeKey: AttributeValue]?) {
        let keys = Self.keys(attributes)
        MainActor.assumeIsolated { record("error", message, keys) }
    }

    nonisolated func critical(_ message: String, error _: Error?, attributes: [AttributeKey: AttributeValue]?) {
        let keys = Self.keys(attributes)
        MainActor.assumeIsolated { record("critical", message, keys) }
    }

    nonisolated func addUserAction(
        type _: LoggingAction,
        name _: String,
        error _: Error?,
        attributes _: [AttributeKey: AttributeValue]?
    ) {}

    nonisolated func addError(error _: Error, type _: ErrorSource, attributes _: [AttributeKey: AttributeValue]?) {}
}
