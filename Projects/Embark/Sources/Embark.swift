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
import Form

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
        
        let form = FormView()
        bag += viewController.install(form)

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
        bag += form.append(passage) { passageView in
            passageView.snp.makeConstraints { make in
                make.top.bottom.leading.trailing.equalToSuperview()
                make.height.equalTo(viewController.view.safeAreaLayoutGuide.snp.height)
            }
        }.onValue { link in
            self.state.goTo(passageName: link.name)
        }

        let progressView = UIProgressView()
        progressView.tintColor = .brand(.primaryButtonBackgroundColor)
        form.addSubview(progressView)

        progressView.snp.makeConstraints { make in
            make.top.equalTo(form.safeAreaLayoutGuide.snp.top)
            make.width.equalToSuperview()
            make.height.equalTo(2)
            make.centerX.equalToSuperview()
        }

        bag += state.progressSignal.animated(style: .lightBounce(), animations: { progress in
            progressView.setProgress(progress, animated: false)
            progressView.setNeedsLayout()
            progressView.layoutIfNeeded()
        })

        let activityIndicator = UIActivityIndicatorView()
        activityIndicator.startAnimating()

        form.addSubview(activityIndicator)

        activityIndicator.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }

        bag += client.fetch(query: EmbarkStoryQuery(name: name)).valueSignal.compactMap { $0.data?.embarkStory }.onValue { embarkStory in
            activityIndicator.removeFromSuperview()

            self.state.storySignal.value = embarkStory

            self.state.passagesSignal.value = embarkStory.passages

            let startPassageId = embarkStory.startPassage

            self.state.currentPassageSignal.value = embarkStory.passages.first(where: { passage -> Bool in
                passage.id == startPassageId
            })
        }

        return (viewController, bag)
    }
}
