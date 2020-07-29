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
    let state: EmbarkState

    public init(name: String, state: EmbarkState) {
        self.name = name
        self.state = state
    }
}

extension Embark: Presentable {
    public func materialize() -> (UIViewController, Disposable) {
        let viewController = UIViewController()
        let bag = DisposeBag()
        
        let scrollView = FormScrollView()
        scrollView.backgroundColor = .brand(.primaryBackground())
        let form = FormView()
        bag += viewController.install(form, options: [], scrollView: scrollView) { scrollView in
            scrollView.alwaysBounceVertical = false
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
        bag += form.append(passage) { passageView in
            var keyboardHeight: CGFloat = 20
            
            func updatePassageViewHeight() {
                passageView.snp.updateConstraints { make in
                    make.top.bottom.leading.trailing.equalToSuperview()
                    make.height.greaterThanOrEqualTo(
                        scrollView.frame.height -
                        scrollView.safeAreaInsets.top -
                        scrollView.safeAreaInsets.bottom -
                        keyboardHeight
                    )
                }
            }
            
            bag += form.didLayoutSignal.onValue {
                updatePassageViewHeight()
            }
            
            bag += NotificationCenter.default
            .signal(forName: UIResponder.keyboardWillChangeFrameNotification)
            .compactMap { notification in notification.keyboardInfo }
            .animated(mapStyle: { (keyboardInfo) -> AnimationStyle in
                AnimationStyle(options: keyboardInfo.animationCurve, duration: keyboardInfo.animationDuration, delay: 0)
            }, animations: { keyboardInfo in
                scrollView.contentInset = UIEdgeInsets(
                    top: 0,
                    left: 0,
                    bottom: keyboardInfo.height - 20 - scrollView.safeAreaInsets.bottom,
                    right: 0
                )
                scrollView.scrollIndicatorInsets = UIEdgeInsets(
                    top: 0,
                    left: 0,
                    bottom: keyboardInfo.height,
                    right: 0
                )
                keyboardHeight = keyboardInfo.height - scrollView.safeAreaInsets.bottom
                updatePassageViewHeight()
                passageView.layoutIfNeeded()
                form.layoutIfNeeded()
                scrollView.layoutIfNeeded()
            })
            
            bag += NotificationCenter.default
                .signal(forName: UIResponder.keyboardWillHideNotification)
                .compactMap { notification in notification.keyboardInfo }
                .animated(mapStyle: { (keyboardInfo) -> AnimationStyle in
                    AnimationStyle(options: keyboardInfo.animationCurve, duration: keyboardInfo.animationDuration, delay: 0)
                }, animations: { _ in
                    keyboardHeight = 20
                    scrollView.contentInset = .zero
                    scrollView.scrollIndicatorInsets = .zero
                    updatePassageViewHeight()
                    passageView.layoutIfNeeded()
                    form.layoutIfNeeded()
                    scrollView.layoutIfNeeded()
            })
        }.onValue { link in
            self.state.goTo(passageName: link.name)
        }

        let progressView = UIProgressView()
        progressView.tintColor = .brand(.primaryButtonBackgroundColor)
        scrollView.addSubview(progressView)

        progressView.snp.makeConstraints { make in
            make.top.equalTo(scrollView.safeAreaLayoutGuide.snp.top)
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
