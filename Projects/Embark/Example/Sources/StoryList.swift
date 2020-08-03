//
//  StoryList.swift
//  EmbarkExample
//
//  Created by sam on 3.8.20.
//  Copyright © 2020 Hedvig AB. All rights reserved.
//

import Foundation
import Embark
import Flow
import Presentation
import UIKit
import Form
import Apollo
import hCore
import hCoreUI

struct StoryList {
    @Inject var client: ApolloClient
}

extension StoryList: Presentable {
    func materialize() -> (UIViewController, Disposable) {
        let viewController = UIViewController()
        viewController.title = "Embark Stories"
        let bag = DisposeBag()
        
        let tableKit = TableKit<EmptySection, String>(holdIn: bag)
        bag += viewController.install(tableKit)
        
        bag += tableKit.delegate.didSelectRow.onValue { storyName in
            viewController.present(Embark(
                name: storyName, state: EmbarkState { externalRedirect in
                    print(externalRedirect)
                }
            ))
        }
        
        bag += client.fetch(query: EmbarkStoryNamesQuery()).map { $0.data?.embarkStoryNames }.valueSignal.compactMap { $0 }.onValue({ storyNames in
            tableKit.set(Table(rows: storyNames))
        })
        
        return (viewController, bag)
    }
}
