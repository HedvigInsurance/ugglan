//
//  EmbarkState.swift
//  Embark
//
//  Created by sam on 15.5.20.
//  Copyright © 2020 Hedvig AB. All rights reserved.
//

import Flow
import Foundation

struct EmbarkState {
    let store = EmbarkStore()
    let passagesSignal = ReadWriteSignal<[EmbarkStoryQuery.Data.EmbarkStory.Passage]>([])
    let currentPassageSignal = ReadWriteSignal<EmbarkStoryQuery.Data.EmbarkStory.Passage?>(nil)
    let passageHistorySignal = ReadWriteSignal<[EmbarkStoryQuery.Data.EmbarkStory.Passage]>([])

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
        currentPassageSignal.value = passagesSignal.value.first(where: { passage -> Bool in
            passage.name == passageName
       })
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
