//
//  Embark.swift
//  test
//
//  Created by Sam Pettersson on 2020-01-16.
//

import Apollo
import Flow
import Foundation
import hCore
import hCoreUI
import Presentation
import SnapKit
import UIKit

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

        let titleHedvigLogo = UIImageView()
        titleHedvigLogo.image = hCoreUIAssets.wordmark.image
        titleHedvigLogo.contentMode = .scaleAspectFit

        viewController.navigationItem.titleView = titleHedvigLogo

        titleHedvigLogo.snp.makeConstraints { make in
            make.width.equalTo(80)
        }

        let passage = Passage(
            state: state
        )
        bag += view.add(passage) { passageView in
            passageView.snp.makeConstraints { make in
                make.top.bottom.leading.trailing.equalToSuperview()
            }
        }.onValue { link in
            self.state.goTo(passageName: link.name)
        }

        let progressView = UIProgressView()
        progressView.tintColor = .brand(.primaryButtonBackgroundColor)
        view.addSubview(progressView)

        progressView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            make.width.equalToSuperview()
            make.height.equalTo(2)
            make.centerX.equalToSuperview()
        }

        bag += state.progressSignal.animated(style: .lightBounce(), animations: { progress in
            progressView.setProgress(progress, animated: false)
            progressView.setNeedsLayout()
            progressView.layoutIfNeeded()
        })

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
