//
//  Embark.swift
//  test
//
//  Created by Sam Pettersson on 2020-01-16.
//

import Foundation
import Flow
import Presentation
import UIKit
import Apollo
import hCore
import hCoreUI

public struct Embark {
    @Inject var client: ApolloClient
    let name: String
    let state = EmbarkState()
    
    public init(name: String) {
        self.name = name
    }
}

extension Embark: Presentable {
    public func materialize() -> (UIViewController, Disposable) {
        let viewController = UIViewController()
        let bag = DisposeBag()
        
        let view = UIView()
        view.backgroundColor = .brand(.primaryBackground())
        viewController.view = view
        
        let blurEffect = UIBlurEffect(style: UIBlurEffect.Style.light)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        view.addSubview(blurEffectView)
        blurEffectView.snp.makeConstraints { make in
            make.height.width.equalToSuperview()
        }
        
        // viewController.installChatButton()
        
        let titleHedvigLogo = UIImageView()
        titleHedvigLogo.image = hCoreUIAssets.wordmark.image
        titleHedvigLogo.contentMode = .scaleAspectFit

        viewController.navigationItem.titleView = titleHedvigLogo

        titleHedvigLogo.snp.makeConstraints { make in
            make.width.equalTo(80)
        }
        
        let passage = Passage(
            state: self.state
        )
        bag += view.add(passage) { passageView in
            passageView.snp.makeConstraints { make in
                make.top.bottom.leading.trailing.equalToSuperview()
            }
        }.onValue { link in
            if let currentPassage = self.state.currentPassageSignal.value {
                self.state.passageHistorySignal.value.append(currentPassage)
            }
            self.state.currentPassageSignal.value = self.state.passagesSignal.value.first(where: { passage -> Bool in
                passage.name == link.name
            })
        }
        
        bag += client.fetch(query: EmbarkStoryQuery(name: name)).onValue { data in
            self.state.passagesSignal.value = data.data?.embarkStory?.passages ?? []
            
            let startPassageId = data.data?.embarkStory?.startPassage
            
            self.state.currentPassageSignal.value = data.data?.embarkStory?.passages.first(where: { passage -> Bool in
                passage.id == startPassageId
            })
        }
        
        return (viewController, bag)
    }
}
