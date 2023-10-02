import Flow
import Foundation
import UIKit
import hAnalytics
import hCore
import hGraphQL

public enum ExternalRedirect {
    case mailingList
    case close
    case chat
    case menu(_ action: MenuChildAction)
}

public class EmbarkState {
    var store = EmbarkStore()
    var edgePanGestureRecognizer: UIScreenEdgePanGestureRecognizer?
    let storySignal = ReadWriteSignal<GiraffeGraphQL.EmbarkStoryQuery.Data.EmbarkStory?>(nil)
    let startPassageIDSignal = ReadWriteSignal<String?>(nil)
    let passagesSignal = ReadWriteSignal<[GiraffeGraphQL.EmbarkStoryQuery.Data.EmbarkStory.Passage]>([])
    let currentPassageSignal = ReadWriteSignal<GiraffeGraphQL.EmbarkStoryQuery.Data.EmbarkStory.Passage?>(nil)
    let passageHistorySignal = ReadWriteSignal<[GiraffeGraphQL.EmbarkStoryQuery.Data.EmbarkStory.Passage]>([])
    let externalRedirectSignal = ReadWriteSignal<ExternalRedirect?>(nil)
    let bag = DisposeBag()
    var quoteCartId: String = ""
    
    public init() {
        defer {
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
    
    func startAPIPassageHandling() {
        bag += currentPassageSignal.compactMap { $0 }
            .mapLatestToFuture { passage -> Future<GiraffeGraphQL.EmbarkLinkFragment?> in
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
                switch externalRedirect {
                case .mailingList: externalRedirectSignal.value = .mailingList
                case .offer:
                    externalRedirectSignal.value = .close
                case .close:
                    externalRedirectSignal.value = .close
                case .chat:
                    externalRedirectSignal.value = .chat
                case .__unknown: fatalError("Can't external redirect to location")
                }
            } else if let passingVariantedRedirect = resultingPassage.variantedOfferRedirects.first(where: { redirect in
                return store.passes(expression: redirect.data.expression.fragments.expressionFragment)
            }) {
            } else {
                self.isApiLoadingSignal.value = false
                currentPassageSignal.value = resultingPassage
            }
        }
    }
    
    private func handleRedirects(
        passage: GiraffeGraphQL.EmbarkStoryQuery.Data.EmbarkStory.Passage
    ) -> GiraffeGraphQL.EmbarkStoryQuery.Data.EmbarkStory.Passage? {
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
