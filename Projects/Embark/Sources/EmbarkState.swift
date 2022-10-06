import Flow
import Foundation
import UIKit
import hAnalytics
import hCore
import hGraphQL

public enum ExternalRedirect {
    case mailingList
    case offer(allIds: [String], selectedIds: [String])
    case close
    case chat
    case quoteCartOffer(id: String, selectedInsuranceTypes: [String])
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
    var quoteCartId: String = ""

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
        store.setValue(key: "quoteCartId", value: quoteCartId)
        store.createRevision()
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
                hAnalyticsEvent.embarkExternalRedirect(location: externalRedirect.rawValue).send()
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
                let ids = offerRedirectKeys.flatMap { key in
                    store.getValues(key: key) ?? []
                }
                hAnalyticsEvent.embarkVariantedOfferRedirect(allIds: ids, selectedIds: ids).send()
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

                hAnalyticsEvent.embarkVariantedOfferRedirect(allIds: allIds, selectedIds: selectedIds).send()
                externalRedirectSignal.value = .offer(allIds: allIds, selectedIds: selectedIds)
            } else if let quoteCartOfferRedirects = resultingPassage.quoteCartOfferRedirects.first(where: {
                store.passes(expression: $0.data.expression.fragments.expressionFragment)
            }) {

                let id = quoteCartOfferRedirects.data.id
                let type = quoteCartOfferRedirects.data.selectedInsuranceTypes

                let quoteCartId = store.getValue(key: id) ?? ""

                externalRedirectSignal.value = .quoteCartOffer(id: quoteCartId, selectedInsuranceTypes: type)
            } else {
                self.isApiLoadingSignal.value = false
                currentPassageSignal.value = resultingPassage
            }
        }
    }

    private func handleRedirects(
        passage: GraphQL.EmbarkStoryQuery.Data.EmbarkStory.Passage
    ) -> GraphQL.EmbarkStoryQuery.Data.EmbarkStory.Passage? {
        guard
            let passingRedirect = passage.redirects.first(where: { redirect in
                store.shouldRedirectTo(redirect: redirect) != nil
            })
        else {
            return nil
        }

        if let binary = passingRedirect.asEmbarkRedirectBinaryExpression {
            store.setValue(key: binary.passedExpressionKey, value: binary.passedExpressionValue)
        } else if let unary = passingRedirect.asEmbarkRedirectUnaryExpression {
            store.setValue(key: unary.passedExpressionKey, value: unary.passedExpressionValue)
        } else if let multiple = passingRedirect.asEmbarkRedirectMultipleExpressions {
            store.setValue(key: multiple.passedExpressionKey, value: multiple.passedExpressionValue)
        }

        return passagesSignal.value.first(where: { passage -> Bool in
            passage.name == store.shouldRedirectTo(redirect: passingRedirect)
        })
    }

    private var totalStepsSignal = ReadWriteSignal<Int?>(nil)

    var progressSignal: ReadSignal<Float> {
        func findMaxDepth(passageName: String, previousDepth: Int = 0, visitedPassages: [String] = []) -> Int {
            if visitedPassages.contains(passageName) {
                return previousDepth
            }

            guard let passage = passagesSignal.value.first(where: { $0.name == passageName }) else {
                return previousDepth
            }

            let links = passage.allLinks
                .filter { !$0.hidden }
                .map { $0.name }

            if links.isEmpty { return previousDepth }

            let depth =
                links.map { linkPassageName in
                    findMaxDepth(
                        passageName: linkPassageName,
                        previousDepth: previousDepth + 1,
                        visitedPassages: [visitedPassages, [passageName]].flatMap { $0 }
                    )
                }
                .reduce(0) { result, current in max(result, current) }

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
