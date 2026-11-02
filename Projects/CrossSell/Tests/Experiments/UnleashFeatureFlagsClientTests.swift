import Combine
import Environment
import Foundation
import Logger
import TestDependencies
import Testing

@testable import hCore

extension CrossSellDependencySuite {
    // Nested so it is serialized with the other suites: it swaps out the global log.
    @MainActor
    final class UnleashFeatureFlagsClientTests {
        private weak var sut: UnleashFeatureFlagsClient?
        private let session = MockPollerSession()
        private var client: UnleashFeatureFlagsClient!
        /// The client's experiments each time it published feature data.
        private var publishedExperiments: [[Experiment]?] = []
        private var cancellable: AnyCancellable?
        private let logger = MockLogger()
        private let originalLog: (any Logging)!

        private let member = ["memberId": "123", "userId": "123", "market": "SE"]
        private let otherMember = ["memberId": "456", "userId": "456", "market": "SE"]
        private let nobody = ["market": "SE"]
        private let noDiscount = Experiment(name: "ACCIDENT_DISCOUNT", variant: "NO_DISCOUNT")
        /// The SDK re-fetches on a background-QoS queue, which the system holds back for seconds under load.
        private let sdkFetchTimeout: TimeInterval = 10

        /// What Unleash answers for a member bucketed into NO_DISCOUNT.
        private let memberToggles = """
            {"toggles":[{"name":"accident_discount_experiment","enabled":true,\
            "variant":{"name":"NO_DISCOUNT","enabled":true}}]}
            """
        /// What Unleash answers with no member in the context: the gradual rollout resolves to off.
        private let anonymousToggles = """
            {"toggles":[{"name":"accident_discount_experiment","enabled":false,\
            "variant":{"name":"disabled","enabled":false}}]}
            """

        /// What Unleash answers for a member the accident discount flag is on for, with the given variant.
        private func toggles(variant: String, variantEnabled: Bool = true) -> String {
            """
            {"toggles":[{"name":"accident_discount_experiment","enabled":true,\
            "variant":{"name":"\(variant)","enabled":\(variantEnabled)}}]}
            """
        }

        init() {
            originalLog = log
            log = logger
            client = UnleashFeatureFlagsClient(environment: .staging, pollerSession: session)
            sut = client
            cancellable = client.featureData.sink { [weak self] _ in
                guard let self else { return }
                self.publishedExperiments.append(self.client.experiments)
            }
        }

        /// Runs a test body, then does what the old tearDown did: restores the global log and checks the client
        /// was released. Errors are recorded rather than thrown so the log is restored even when `#require` fails.
        private func run(
            sourceLocation: SourceLocation = #_sourceLocation,
            _ body: @MainActor () async throws -> Void
        ) async {
            await recordingErrors(sourceLocation: sourceLocation, body)
            cancellable = nil
            client = nil
            log = originalLog
            await delay(0.0000001)
            #expect(sut == nil, "the client must not outlive the test", sourceLocation: sourceLocation)
        }

        @Test
        func setupFetchesWithTheMemberAsUserIdAndMemberIdProperty() async {
            await run {
                session.enqueue(.toggles(memberToggles))

                try await client.setup(with: member)

                let query = try #require(session.requestedURLs.last?.query)
                #expect(query.contains("userId=123"), "\(query)")
                #expect(query.contains("properties%5BmemberId%5D=123"), "\(query)")
            }
        }

        @Test
        func setupPublishesTheExperimentsFromTheMembersToggles() async {
            await run {
                session.enqueue(.toggles(memberToggles))

                try await client.setup(with: member)

                #expect(client.experiments == [noDiscount])
            }
        }

        @Test
        func setupWithADisabledFlagPublishesNoExperiment() async {
            await run {
                session.enqueue(.toggles(anonymousToggles))

                try await client.setup(with: nobody)

                #expect(client.experiments == [])
            }
        }

        @Test
        func updateContextLeavesExperimentsUnknownUntilTheNewMembersFetchLands() async {
            await run {
                session.enqueue(.toggles(anonymousToggles))
                try await client.setup(with: nobody)
                session.enqueue(.toggles(memberToggles))

                client.updateContext(context: member)

                let beforeTheFetch = try #require(publishedExperiments.last)
                #expect(beforeTheFetch == nil)
                await waitUntil(description: "the member's toggles arrive", timeout: sdkFetchTimeout) {
                    client.experiments == [noDiscount]
                }
            }
        }

        @Test
        func setupForANewMemberLeavesExperimentsUnknownUntilItsFetchLands() async {
            await run {
                session.enqueue(.toggles(anonymousToggles))
                try await client.setup(with: nobody)
                session.enqueue(.toggles(memberToggles))

                // Login runs setup again with the member in the context, while Home already queries cross-sells.
                try await client.setup(with: member)

                #expect(Array(publishedExperiments.suffix(3)) == [[], nil, [noDiscount]])
            }
        }

        @Test
        func updateContextTakesANotModifiedAnswerAsTheNewMembersState() async {
            await run {
                session.enqueue(.toggles(memberToggles))
                try await client.setup(with: member)
                // The SDK keeps one ETag across contexts, so a member with the same toggles gets a 304 and no event.
                session.enqueue(.notModified)

                client.updateContext(context: otherMember)

                await waitUntil(
                    description: "the 304 is taken as the other member's state",
                    timeout: sdkFetchTimeout
                ) {
                    client.experiments == [noDiscount]
                }
                #expect(session.requestedURLs.count == 2)
            }
        }

        @Test
        func updateContextKeepsExperimentsUnknownWhenTheMembersFetchFails() async {
            await run {
                session.enqueue(.toggles(anonymousToggles))
                try await client.setup(with: nobody)
                // Nothing enqueued: the member's fetch fails.

                client.updateContext(context: member)

                await waitUntil(description: "the member's fetch was attempted", timeout: sdkFetchTimeout) {
                    session.requestedURLs.count == 2
                }
                await delay(0.1)
                #expect(client.experiments == nil)
            }
        }

        @Test
        func updateContextWithoutAMemberFetchesForNobody() async {
            await run {
                session.enqueue(.toggles(memberToggles))
                try await client.setup(with: member)
                session.enqueue(.toggles(anonymousToggles))

                client.updateContext(context: nobody)

                await waitUntil(description: "nobody's toggles arrive", timeout: sdkFetchTimeout) {
                    client.experiments == []
                }
                let query = try #require(session.requestedURLs.last?.query)
                #expect(!query.contains("userId"), "\(query)")
                #expect(!query.contains("memberId"), "\(query)")
            }
        }

        @Test
        func updateContextWithTheSameContextDoesNotFetchAgain() async {
            await run {
                session.enqueue(.toggles(memberToggles))
                try await client.setup(with: member)

                client.updateContext(context: member)

                await delay(0.1)
                #expect(session.requestedURLs.count == 1)
                #expect(client.experiments == [noDiscount])
            }
        }

        @Test
        func setupWithADisabledVariantPublishesNoExperiment() async {
            await run {
                session.enqueue(.toggles(toggles(variant: "NO_DISCOUNT", variantEnabled: false)))

                try await client.setup(with: member)

                #expect(client.experiments == [])
            }
        }

        @Test(arguments: ["no-discount", "NoDiscount", "NO DISCOUNT", ""])
        func setupDropsAndWarnsAboutAVariantThatIsNotScreamingSnakeCase(variant: String) async {
            await run {
                session.enqueue(.toggles(toggles(variant: variant)))

                try await client.setup(with: member)

                #expect(client.experiments == [])
                #expect(
                    logger.warnings == ["Ignoring ACCIDENT_DISCOUNT variant '\(variant)': not SCREAMING_SNAKE_CASE"]
                )
            }
        }

        /// Replaces the client under test with one that waits `memberStateTimeout` for the member's experiments.
        private func makeClient(memberStateTimeout: TimeInterval) -> UnleashFeatureFlagsClient {
            let client = UnleashFeatureFlagsClient(
                environment: .staging,
                pollerSession: session,
                memberStateTimeout: memberStateTimeout
            )
            self.client = client
            sut = client
            return client
        }

        @Test
        func activeExperimentsWithTheMembersTogglesInHandAnswersAtOnce() async {
            await run {
                let client = makeClient(memberStateTimeout: 3)
                session.enqueue(.toggles(memberToggles))
                try await client.setup(with: member)

                let clock = ContinuousClock()
                let start = clock.now
                let experiments = await client.activeExperiments()

                #expect(experiments == [noDiscount])
                #expect(clock.now - start < .seconds(1))
            }
        }

        @Test
        func activeExperimentsWaitsForTheMembersToggles() async {
            await run {
                let client = makeClient(memberStateTimeout: sdkFetchTimeout)
                session.enqueue(.toggles(anonymousToggles))
                try await client.setup(with: nobody)
                session.enqueue(.toggles(memberToggles))

                client.updateContext(context: member)
                let experiments = await client.activeExperiments()

                #expect(experiments == [noDiscount])
                #expect(logger.warnings.isEmpty)
            }
        }

        @Test
        func activeExperimentsAfterAMemberChangeWaitsForTheNewMembersToggles() async {
            await run {
                let client = makeClient(memberStateTimeout: sdkFetchTimeout)
                session.enqueue(.toggles(toggles(variant: "NO_DISCOUNT", variantEnabled: false)))
                try await client.setup(with: member)
                session.enqueue(.toggles(memberToggles))

                client.updateContext(context: otherMember)
                let experiments = await client.activeExperiments()

                #expect(experiments == [noDiscount])
            }
        }

        @Test
        func activeExperimentsAfterATimeoutAnswersAtOnceUntilTheContextChanges() async {
            await run {
                let client = makeClient(memberStateTimeout: 0.2)
                session.enqueue(.toggles(anonymousToggles))
                try await client.setup(with: nobody)
                // Nothing enqueued: the member's fetch fails.
                client.updateContext(context: member)
                let clock = ContinuousClock()

                var start = clock.now
                let firstAnswer = await client.activeExperiments()
                #expect(firstAnswer == [])
                #expect(clock.now - start >= .milliseconds(200))

                start = clock.now
                let secondAnswer = await client.activeExperiments()
                #expect(secondAnswer == [])
                #expect(clock.now - start < .milliseconds(100))

                // Another member's toggles may be on their way, so it is worth waiting again.
                client.updateContext(context: otherMember)
                start = clock.now
                let thirdAnswer = await client.activeExperiments()
                #expect(thirdAnswer == [])
                #expect(clock.now - start >= .milliseconds(200))
            }
        }

        @Test
        func activeExperimentsAfterATimeoutDoesNotWaitAgainForTheSameContextSetUpAgain() async {
            await run {
                let client = makeClient(memberStateTimeout: 0.2)
                // Nothing enqueued: Unleash is unreachable.
                try? await client.setup(with: member)
                _ = await client.activeExperiments()

                // While Unleash is unreachable the app sets the flags up again every second, with the same context.
                try? await client.setup(with: member)
                let clock = ContinuousClock()
                let start = clock.now
                let answer = await client.activeExperiments()

                #expect(answer == [])
                #expect(clock.now - start < .milliseconds(100))
            }
        }

        @Test
        func activeExperimentsLogsAWarningEachTimeItGivesUpWaiting() async {
            await run {
                let client = makeClient(memberStateTimeout: 0.2)
                try? await client.setup(with: member)

                _ = await client.activeExperiments()
                _ = await client.activeExperiments()
                #expect(logger.warnings.count == 1, "the second call answered at once without waiting")

                client.updateContext(context: otherMember)
                _ = await client.activeExperiments()
                #expect(logger.warnings.count == 2)
            }
        }
    }
}
