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

struct Embark {
    @Inject var client: ApolloClient
    let name: String
    let store = EmbarkStore()
}

extension Embark: Presentable {
    func materialize() -> (UIViewController, Disposable) {
        let viewController = UIViewController()
        let bag = DisposeBag()
        
        let view = UIView()
        view.backgroundColor = .blackPurple
        viewController.view = view
        
        /*let imageBackground = UIImageView(image: Asset.embarkBackground.image)
        imageBackground.contentMode = .scaleAspectFill
        view.addSubview(imageBackground)
        imageBackground.snp.makeConstraints { make in
            make.height.width.equalToSuperview()
        }*/
        
        viewController.installChatButton()
        
        let titleHedvigLogo = UIImageView()
        titleHedvigLogo.image = Asset.wordmark.image
        titleHedvigLogo.contentMode = .scaleAspectFit

        viewController.navigationItem.titleView = titleHedvigLogo

        titleHedvigLogo.snp.makeConstraints { make in
            make.width.equalTo(80)
        }
        
        let passagesSignal = ReadWriteSignal<[EmbarkStoryQuery.Data.EmbarkStory.Passage]>([])
        let currentPassageSignal = ReadWriteSignal<EmbarkStoryQuery.Data.EmbarkStory.Passage?>(nil)
        
        let passage = Passage(
            store: store,
            dataSignal: currentPassageSignal
        )
        bag += view.add(passage) { passageView in
            passageView.snp.makeConstraints { make in
                make.top.bottom.leading.trailing.equalToSuperview()
            }
        }.onValue { link in
            currentPassageSignal.value = passagesSignal.value.first(where: { passage -> Bool in
                passage.name == link.name
            })
        }
        
        bag += client.fetch(query: EmbarkStoryQuery(name: name)).onValue { data in
            passagesSignal.value = data.data?.embarkStory?.passages ?? []
            
            let startPassageId = data.data?.embarkStory?.startPassage
            
            currentPassageSignal.value = data.data?.embarkStory?.passages.first(where: { passage -> Bool in
                passage.id == startPassageId
            })
        }
        
        return (viewController, bag)
    }
}
