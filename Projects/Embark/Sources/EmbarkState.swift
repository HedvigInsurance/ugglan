//
//  EmbarkState.swift
//  Embark
//
//  Created by sam on 15.5.20.
//  Copyright © 2020 Hedvig AB. All rights reserved.
//

import Foundation
import Flow

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
        passageHistorySignal.value = passageHistorySignal.value.dropLast()
    }
}
