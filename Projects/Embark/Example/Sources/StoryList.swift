//
//  StoryList.swift
//  EmbarkExample
//
//  Created by sam on 3.8.20.
//  Copyright © 2020 Hedvig AB. All rights reserved.
//

import Apollo
import Embark
import Flow
import Form
import Foundation
import hCore
import hCoreUI
import Presentation
import UIKit

struct StoryList {
    @Inject var client: ApolloClient
}

extension StoryList: Presentable {
    func materialize() -> (UIViewController, Disposable) {
        let viewController = UIViewController()
        viewController.title = "Embark Stories"
        let bag = DisposeBag()

        let tableKit = TableKit<EmptySection, StringRow>(holdIn: bag)
        bag += viewController.install(tableKit)

        bag += tableKit.delegate.didSelectRow.onValue { storyName in
            viewController.present(Embark(
                name: storyName.value, state: EmbarkState { externalRedirect in
                    print(externalRedirect)
                }
            ), options: [.defaults, .largeTitleDisplayMode(.never)])
        }

        bag += client.fetch(query: EmbarkStoryNamesQuery()).valueSignal.map { $0.data?.embarkStoryNames }.compactMap { $0 }.map { $0.map { value in StringRow(value: value) } }.onValue { storyNames in
            tableKit.set(Table(rows: storyNames))
        }

        return (viewController, bag)
    }
}
