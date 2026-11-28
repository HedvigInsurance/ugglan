import AuthenticationCore
import Environment
import Foundation
@preconcurrency import HedvigShared
import KMPNativeCoroutinesAsync
import KMPNativeCoroutinesCore
import Logger
import Testing
import hCore
import hGraphQL

@testable import Ugglan

extension AppDependencySuite {
    @MainActor
    final class SharedKotlinTests {
        @Test
        func theGraphHolderIsRegisteredOncePerProcess() async {
            await DI.initNetworkClients()
            let first: IosGraphHolder = Dependencies.shared.resolve()
            await DI.initNetworkClients()
            let second: IosGraphHolder = Dependencies.shared.resolve()
            #expect(first === second)
        }

        @Test
        func aReadReturnsItsValue() async throws {
            let memberId = try await kotlinRead { Self.succeeding("member") }
            #expect(memberId == "member")
        }

        @Test
        func aFailedReadThrowsWhatAnOctopusClientWould() async {
            #expect(await isGraphQLError(afterFailureOf: .network) == false)
            #expect(await isGraphQLError(afterFailureOf: .unauthenticated) == true)
            #expect(await isGraphQLError(afterFailureOf: .other) == true)
        }

        private func isGraphQLError(afterFailureOf kind: ReadFailureKind) async -> Bool? {
            let kotlinError = NSError(
                domain: "KotlinException",
                code: 0,
                userInfo: ["KotlinException": ReadFailure(kind: kind, cause: nil, memberFacingMessage: nil)]
            )
            do {
                let _: String = try await kotlinRead { Self.failing(kotlinError) }
                return nil
            } catch let error as GraphQLError {
                if case .graphQLError = error { return true }
                return false
            } catch {
                return nil
            }
        }

        @Test
        func aFailureWithAMemberFacingMessageThrowsThatMessageAsItsDescription() async {
            let kotlinError = NSError(
                domain: "KotlinException",
                code: 0,
                userInfo: [
                    "KotlinException": ReadFailure(kind: .other, cause: nil, memberFacingMessage: "Your pet is too old")
                ]
            )
            do {
                let _: String = try await kotlinRead { Self.failing(kotlinError) }
                Issue.record("expected the read to throw")
            } catch {
                #expect(error is MemberFacingError)
                #expect(error.localizedDescription == "Your pet is too old")
            }
        }

        @Test
        func aCancelledReadThrowsCancellationError() async {
            do {
                let _: String = try await kotlinRead { Self.cancelled() }
                Issue.record("expected the read to throw")
            } catch {
                #expect(error is CancellationError)
            }
        }

        @Test
        func publicImportantMessagesMapToTheSwiftModel() async throws {
            let items = [
                PublicImportantMessageItem(
                    id: "error-1",
                    message: "a",
                    severity: .error,
                    linkUrl: "https://example.test/status",
                    linkButtonText: "Status"
                ),
                PublicImportantMessageItem(
                    id: "info-1",
                    message: "b",
                    severity: .info,
                    linkUrl: nil,
                    linkButtonText: nil
                ),
                PublicImportantMessageItem(
                    id: "warning-1",
                    message: "c",
                    severity: .warning,
                    linkUrl: "hedvig://chat",
                    linkButtonText: "Chat"
                ),
            ]

            let messages = try await kotlinRead { Self.succeeding(items) }.map(PublicImportantMessage.init(item:))

            #expect(
                messages == [
                    PublicImportantMessage(
                        id: "error-1",
                        message: "a",
                        severity: .error,
                        link: .init(url: URL(string: "https://example.test/status")!, text: "Status")
                    ),
                    PublicImportantMessage(id: "info-1", message: "b", severity: .info, link: nil),
                    PublicImportantMessage(id: "warning-1", message: "c", severity: .warning, link: nil),
                ]
            )
        }

        @Test
        func aFailedPublicImportantMessagesReadThrowsAGraphQLError() async {
            let networkFailure = NSError(
                domain: "KotlinException",
                code: 0,
                userInfo: ["KotlinException": ReadFailure(kind: .network, cause: nil, memberFacingMessage: nil)]
            )
            do {
                let _: [PublicImportantMessageItem] = try await kotlinRead { Self.failing(networkFailure) }
                Issue.record("expected the read to throw")
            } catch let error as GraphQLError {
                guard case .otherError = error else {
                    Issue.record("expected .otherError for a network failure")
                    return
                }
            } catch {
                Issue.record("expected a GraphQLError")
            }
        }

        @Test
        func anErrorThatIsNotAReadFailureIsAnOtherError() {
            let cancel = CancellationError()
            guard case let .otherError(error) = GraphQLError(readError: cancel) else {
                Issue.record("expected .otherError")
                return
            }
            #expect(error is CancellationError)
        }

        @Test
        func kotlinLinesAreHeldUntilTheLoggerIsReadyThenWrittenInOrder() async {
            let logger = RecordingLogger()
            let sink = AppLogSink(logger: { logger })

            sink.log(priority: .info, tag: "T", message: "first")
            sink.log(priority: .warn, tag: nil, message: "second")
            await Self.drainMainQueue()
            #expect(logger.lines.isEmpty)

            sink.logIsReady()
            sink.log(priority: .verbose, tag: nil, message: "third")
            sink.log(priority: .error, tag: nil, message: "fourth")
            sink.log(priority: .assert, tag: nil, message: "fifth")
            await Self.drainMainQueue()

            #expect(logger.lines.map(\.message) == ["first", "second", "third", "fourth", "fifth"])
            #expect(logger.lines.map(\.level) == ["info", "warn", "debug", "error", "critical"])
        }

        @Test
        func productionNeverLogsMemberData() {
            #expect(Environment.production.flavor == .production)
            #expect(Environment.staging.flavor == .staging)
            let production = NetworkLogPolicy(flavor: .production)
            #expect(!production.logsHttpBodies && !production.logsGraphqlData && production.logsGraphqlErrors)
            let staging = NetworkLogPolicy(flavor: .staging)
            #expect(staging.logsHttpBodies && staging.logsGraphqlData && staging.logsGraphqlErrors)
            #expect(LogPriority.minimumForKotlin(flavor: .production) == .info)
            #expect(LogPriority.minimumForKotlin(flavor: .staging) == .verbose)
        }

        @Test
        func theLanguageFollowsTheAppLocale() {
            let expected: Language = Localization.Locale.currentLocale.value == .sv_SE ? .svSe : .enSe
            #expect(CurrentLocaleLanguageSource().currentLanguage() == expected)
        }

        @Test
        func theAccessTokenFetcherIsNilOnlyWhenLoggedOutAndOtherwiseRethrows() async throws {
            let token = OAuthorizationToken(
                accessToken: "access",
                accessTokenExpirationDate: .distantFuture,
                refreshToken: "refresh",
                refreshTokenExpirationDate: .distantFuture
            )
            let refreshed = KeychainAccessTokenFetcher(retrieveToken: { token }, refreshIfNeeded: {})
            let loggedOut = KeychainAccessTokenFetcher(
                retrieveToken: { nil },
                refreshIfNeeded: { Issue.record("a logged-out fetch must not refresh") }
            )
            let refreshFailed = KeychainAccessTokenFetcher(
                retrieveToken: { token },
                refreshIfNeeded: { throw AuthError.refreshFailed }
            )
            let keychainFailed = KeychainAccessTokenFetcher(retrieveToken: { throw AuthError.networkIssue })

            #expect(try await refreshed.fetch() == "access")
            #expect(try await loggedOut.fetch() == nil)
            await #expect(throws: AuthError.refreshFailed) { try await refreshFailed.fetch() }
            await #expect(throws: AuthError.networkIssue) { try await keychainFailed.fetch() }
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

        private static func cancelled<T>() -> NativeSuspend<T, Error, KotlinUnit> {
            { _, _, onCancelled in
                _ = onCancelled(NSError(domain: "KotlinException", code: 0), KotlinUnit())
                return { KotlinUnit() }
            }
        }

        private static func drainMainQueue() async {
            await withCheckedContinuation { continuation in
                DispatchQueue.main.async { continuation.resume() }
            }
        }
    }
}
