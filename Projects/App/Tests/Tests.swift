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
            reason: "GRAPHQL_ERRORS",
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
        let failure = KotlinReadFailure(kind: .general, reason: "TIMEOUT", readName: "a", operationName: "A")
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
        let failure = KotlinReadFailure(kind: .sessionEnded, reason: "SESSION_ENDED", readName: "a", operationName: "A")
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
        let attributes: Set<String>
    }

    var lines: [Line] = []

    private func record(_ level: String, _ keys: Set<String>) {
        lines.append(Line(level: level, attributes: keys))
    }

    private nonisolated static func keys(_ attributes: [AttributeKey: AttributeValue]?) -> Set<String> {
        Set(attributes?.keys.map { $0 } ?? [])
    }

    nonisolated func debug(_: String, error _: Error?, attributes: [AttributeKey: AttributeValue]?) {
        let keys = Self.keys(attributes)
        MainActor.assumeIsolated { record("debug", keys) }
    }

    nonisolated func info(_: String, error _: Error?, attributes: [AttributeKey: AttributeValue]?) {
        let keys = Self.keys(attributes)
        MainActor.assumeIsolated { record("info", keys) }
    }

    nonisolated func notice(_: String, error _: Error?, attributes: [AttributeKey: AttributeValue]?) {
        let keys = Self.keys(attributes)
        MainActor.assumeIsolated { record("notice", keys) }
    }

    nonisolated func warn(_: String, error _: Error?, attributes: [AttributeKey: AttributeValue]?) {
        let keys = Self.keys(attributes)
        MainActor.assumeIsolated { record("warn", keys) }
    }

    nonisolated func error(_: String, error _: Error?, attributes: [AttributeKey: AttributeValue]?) {
        let keys = Self.keys(attributes)
        MainActor.assumeIsolated { record("error", keys) }
    }

    nonisolated func critical(_: String, error _: Error?, attributes: [AttributeKey: AttributeValue]?) {
        let keys = Self.keys(attributes)
        MainActor.assumeIsolated { record("critical", keys) }
    }

    nonisolated func addUserAction(
        type _: LoggingAction,
        name _: String,
        error _: Error?,
        attributes _: [AttributeKey: AttributeValue]?
    ) {}

    nonisolated func addError(error _: Error, type _: ErrorSource, attributes _: [AttributeKey: AttributeValue]?) {}
}
