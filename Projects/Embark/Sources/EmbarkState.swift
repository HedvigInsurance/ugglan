import Flow
import Foundation
import UIKit
import hCore
import hGraphQL

public enum ExternalRedirect {
    case mailingList
    case offer(allIds: [String], selectedIds: [String])
    case close
    case chat
    case dataCollection(providerID: String, providerDisplayName: String, onComplete: (_ id: UUID?, _ personalNumber: String?) -> Void)
    case menu(_ action: MenuChildAction)
}

public class EmbarkState {
    var store = EmbarkStore()
    var edgePanGestureRecognizer: UIScreenEdgePanGestureRecognizer?
    let storySignal = ReadWriteSignal<GraphQL.EmbarkStoryQuery.Data.EmbarkStory?>(nil)
    let startPassageIDSignal = ReadWriteSignal<String?>(nil)
    let passagesSignal = ReadWriteSignal<[GraphQL.EmbarkStoryQuery.Data.EmbarkStory.Passage]>([])
    let currentPassageSignal = ReadWriteSignal<GraphQL.EmbarkStoryQuery.Data.EmbarkStory.Passage?>(nil)
    let passageHistorySignal = ReadWriteSignal<[GraphQL.EmbarkStoryQuery.Data.EmbarkStory.Passage]>([])
    let externalRedirectSignal = ReadWriteSignal<ExternalRedirect?>(nil)
    let bag = DisposeBag()

    public init() {
        defer {
            startTracking()
            startAPIPassageHandling()
        }
    }

    enum AnimationDirection {
        case forwards
        case backwards
    }

    let animationDirectionSignal = ReadWriteSignal<AnimationDirection>(.forwards)
    var canGoBackSignal: ReadSignal<Bool> { passageHistorySignal.map { !$0.isEmpty } }

    var passageNameSignal: ReadSignal<String?> { currentPassageSignal.map { $0?.name } }

    var passageTooltipsSignal: ReadSignal<[Tooltip]> { currentPassageSignal.map { $0?.tooltips ?? [] } }

    var isApiLoadingSignal = ReadWriteSignal(false)

    func restart() {
        animationDirectionSignal.value = .backwards
        currentPassageSignal.value = passagesSignal.value.first(where: { passage -> Bool in
            passage.id == startPassageIDSignal.value
        })
        passageHistorySignal.value = []
        store = EmbarkStore()
        store.computedValues =
            storySignal.value?.computedStoreValues?
            .reduce([:]) { (prev, computedValue) -> [String: String] in
                var computedValues: [String: String] = prev
                computedValues[computedValue.key] = computedValue.value
                return computedValues
            } ?? [:]
    }

    func startTracking() {
        bag += currentPassageSignal.atOnce().readOnly().compactMap { $0?.tracks }
            .onValue(on: .background) { tracks in
                tracks.forEach { track in
                    track.send(
                        storyName: self.storySignal.value?.name ?? "",
                        storeValues: self.store.getAllValues()
                    )
                }
            }
    }

    func startAPIPassageHandling() {
        bag += currentPassageSignal.compactMap { $0 }
            .mapLatestToFuture { passage -> Future<GraphQL.EmbarkLinkFragment?> in
                guard let apiFragment = passage.api?.fragments.apiFragment else {
                    return Future(error: ApiError.noApi)
                }

                self.isApiLoadingSignal.value = true

                return self.handleApi(apiFragment: apiFragment)
            }
            .providedSignal.plain().readable(initial: nil).delay(by: 0.5)
            .onValue({ link in
                guard let link = link else { return }
                self.goTo(passageName: link.name, pushHistoryEntry: false)
            })
    }

    func goBack() {
        trackGoBack()
        animationDirectionSignal.value = .backwards
        currentPassageSignal.value = passageHistorySignal.value.last
        var history = passageHistorySignal.value
        history.removeLast()
        passageHistorySignal.value = history
        store.removeLastRevision()
        self.isApiLoadingSignal.value = false
    }

    func goTo(passageName: String, pushHistoryEntry: Bool = true) {
        animationDirectionSignal.value = .forwards
        store.createRevision()

        if let newPassage = passagesSignal.value.first(where: { passage -> Bool in passage.name == passageName }
        ) {
            let resultingPassage = handleRedirects(passage: newPassage) ?? newPassage

            if let resultingPassage = currentPassageSignal.value, pushHistoryEntry {
                passageHistorySignal.value.append(resultingPassage)
            }

            if let externalRedirect = resultingPassage.externalRedirect?.data.location {
                Analytics.track(
                    "External Redirect",
                    properties: [
                        "location": externalRedirect.rawValue
                    ]
                )
                switch externalRedirect {
                case .mailingList: externalRedirectSignal.value = .mailingList
                case .offer:

                    let ids = [store.getValue(key: "quoteId")].compactMap { $0 }

                    externalRedirectSignal.value = .offer(
                        allIds: ids,
                        selectedIds: ids
                    )
                case .close:
                    externalRedirectSignal.value = .close
                case .chat:
                    externalRedirectSignal.value = .chat
                case .__unknown: fatalError("Can't external redirect to location")
                }
            } else if let offerRedirectKeys = resultingPassage.offerRedirect?.data.keys.compactMap({ $0 }) {
                Analytics.track("Offer Redirect", properties: [:])
                let ids = offerRedirectKeys.flatMap { key in
                    store.getValues(key: key) ?? []
                }
                externalRedirectSignal.value = .offer(
                    allIds: ids,
                    selectedIds: ids
                )
            } else if let passingVariantedRedirect = resultingPassage.variantedOfferRedirects.first(where: { redirect in
                return store.passes(expression: redirect.data.expression.fragments.expressionFragment)
            }) {
                let allIds = passingVariantedRedirect.data.allKeys.flatMap { key in
                    store.getValues(key: key) ?? []
                }

                let selectedIds = passingVariantedRedirect.data.selectedKeys.flatMap { key in
                    store.getValues(key: key) ?? []
                }

                Analytics.track(
                    "Varianted Offer Redirect",
                    properties: [
                        "allIds": allIds,
                        "selectedIds": selectedIds,
                    ]
                )
                externalRedirectSignal.value = .offer(allIds: allIds, selectedIds: selectedIds)
            } else {
                self.isApiLoadingSignal.value = false
                currentPassageSignal.value = resultingPassage
            }
        }
    }

    private func handleRedirects(
        passage: GraphQL.EmbarkStoryQuery.Data.EmbarkStory.Passage
    ) -> GraphQL.EmbarkStoryQuery.Data.EmbarkStory.Passage? {
        passage.redirects.map { redirect in store.shouldRedirectTo(redirect: redirect) }
            .map { redirectTo in
                passagesSignal.value.first(where: { passage -> Bool in passage.name == redirectTo })
            }
            .compactMap { $0 }.first
    }

    private var totalStepsSignal = ReadWriteSignal<Int?>(nil)

    var progressSignal: ReadSignal<Float> {
        var visitedPassageDepths: [String: Int] = [:]

        func findMaxDepth(passageName: String, previousDepth: Int = 0) -> Int {
            if let depth = visitedPassageDepths[passageName] {
                return depth
            }

            guard let passage = passagesSignal.value.first(where: { $0.name == passageName }) else {
                visitedPassageDepths[passageName] = 0
                return 0
            }

            let links = passage.allLinks.map { $0.name }

            if links.isEmpty { return previousDepth }

            visitedPassageDepths[passageName] = previousDepth

            let depth =
                links.map { linkPassageName in
                    findMaxDepth(passageName: linkPassageName, previousDepth: previousDepth + 1)
                }
                .reduce(0) { result, current in max(result, current) }

            visitedPassageDepths[passageName] = depth

            return depth
        }

        return
            currentPassageSignal.map { currentPassage in
                guard let currentPassage = currentPassage else { return 0 }

                let passagesLeft = currentPassage.allLinks.map { findMaxDepth(passageName: $0.name) }
                    .reduce(0) { result, current in max(result, current) }

                if self.totalStepsSignal.value == nil { self.totalStepsSignal.value = passagesLeft }

                guard let totalSteps = self.totalStepsSignal.value else { return 0 }

                if totalSteps == 0 || self.passageHistorySignal.value.isEmpty {
                    return 0
                }

                return (Float(totalSteps - passagesLeft) / Float(totalSteps))
            }
            .latestTwo()
            .delay { lhs, rhs -> TimeInterval? in if lhs > rhs { return 0 }
                return 0.25
            }
            .map { _, rhs in rhs }.readable(initial: 0)
    }
}
