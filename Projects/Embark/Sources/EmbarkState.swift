//
//  EmbarkState.swift
//  Embark
//
//  Created by sam on 15.5.20.
//  Copyright © 2020 Hedvig AB. All rights reserved.
//

import Apollo
import Flow
import Foundation
import hCore

public enum ExternalRedirect {
    case mailingList
    case offer
}

public struct EmbarkState {
    @Inject var client: ApolloClient
    @Inject var urlSessionClient: URLSessionClient
    @Inject var apolloEnvironment: ApolloEnvironmentConfig

    let store = EmbarkStore()
    let storySignal = ReadWriteSignal<EmbarkStoryQuery.Data.EmbarkStory?>(nil)
    let passagesSignal = ReadWriteSignal<[EmbarkStoryQuery.Data.EmbarkStory.Passage]>([])
    let currentPassageSignal = ReadWriteSignal<EmbarkStoryQuery.Data.EmbarkStory.Passage?>(nil)
    let passageHistorySignal = ReadWriteSignal<[EmbarkStoryQuery.Data.EmbarkStory.Passage]>([])
    let externalRedirectHandler: (_ externalRedirect: ExternalRedirect) -> Void

    public init(externalRedirectHandler: @escaping (_ externalRedirect: ExternalRedirect) -> Void) {
        self.externalRedirectHandler = externalRedirectHandler
    }

    enum AnimationDirection {
        case forwards
        case backwards
    }

    let animationDirectionSignal = ReadWriteSignal<AnimationDirection>(.forwards)
    var canGoBackSignal: ReadSignal<Bool> {
        passageHistorySignal.map { $0.count != 0 }
    }

    var passageNameSignal: ReadSignal<String?> {
        currentPassageSignal.map { $0?.name }
    }

    func goBack() {
        animationDirectionSignal.value = .backwards
        currentPassageSignal.value = passageHistorySignal.value.last
        var history = passageHistorySignal.value
        history.removeLast()
        passageHistorySignal.value = history
        store.removeLastRevision()
    }

    func goTo(passageName: String) {
        animationDirectionSignal.value = .forwards
        store.createRevision()
        if let currentPassage = currentPassageSignal.value {
            passageHistorySignal.value.append(currentPassage)
        }

        if let newPassage = passagesSignal.value.first(where: { passage -> Bool in
            passage.name == passageName
        }) {
            let resultingPassage = handleRedirects(passage: newPassage) ?? newPassage
            if let externalRedirect = resultingPassage.externalRedirect {
                switch externalRedirect {
                case .mailingList:
                    externalRedirectHandler(ExternalRedirect.mailingList)
                case .offer:
                    externalRedirectHandler(ExternalRedirect.offer)
                case .__unknown:
                    fatalError("Can't external redirect to location")
                }
            } else {
                currentPassageSignal.value = resultingPassage
            }
        }
    }

    private func handleRedirects(passage: EmbarkStoryQuery.Data.EmbarkStory.Passage) -> EmbarkStoryQuery.Data.EmbarkStory.Passage? {
        passage.redirects.map { redirect in
            store.shouldRedirectTo(redirect: redirect)
        }.map { redirectTo in
            passagesSignal.value.first(where: { passage -> Bool in
                passage.name == redirectTo
            })
        }.compactMap { $0 }.first
    }

    private var totalStepsSignal = ReadWriteSignal<Int?>(nil)

    var progressSignal: ReadSignal<Float> {
        func findMaxDepth(passageName: String, previousDepth: Int = 0) -> Int {
            guard let passage = passagesSignal.value.first(where: { $0.name == passageName }) else {
                return 0
            }

            let links = passage.allLinks.map { $0.name }

            if links.count == 0 {
                return previousDepth
            }

            return links.map { linkPassageName in
                findMaxDepth(passageName: linkPassageName, previousDepth: previousDepth + 1)
            }.reduce(0) { result, current in
                max(result, current)
            }
        }

        return currentPassageSignal.map { currentPassage in
            guard let currentPassage = currentPassage else {
                return 0
            }

            let passagesLeft = currentPassage.allLinks
                .map { findMaxDepth(passageName: $0.name) }
                .reduce(0) { result, current in
                    max(result, current)
                }

            if self.totalStepsSignal.value == nil {
                self.totalStepsSignal.value = passagesLeft
            }

            guard let totalSteps = self.totalStepsSignal.value else {
                return 0
            }

            return (Float(totalSteps - passagesLeft) / Float(totalSteps))
        }.latestTwo().delay { lhs, rhs -> TimeInterval? in
            if lhs > rhs {
                return 0
            }

            return 0.25
        }.map { _, rhs in rhs }.readable(initial: 0)
    }
}
