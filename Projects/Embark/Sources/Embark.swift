import Apollo
import Flow
import Form
import Foundation
import hCore
import hCoreUI
import hGraphQL
import Presentation
import SnapKit
import UIKit

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
    public func materialize() -> (UIViewController, Future<Void>) {
        let viewController = UIViewController()
        let bag = DisposeBag()

        let scrollView = FormScrollView()
        scrollView.backgroundColor = .brand(.primaryBackground())
        let form = FormView()
        form.dynamicStyle = DynamicFormStyle.default.restyled { (style: inout FormStyle) in
            style.insets = .zero
        }
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

        bag += client.fetch(
            query: GraphQL.EmbarkStoryQuery(
                name: name,
                locale: Localization.Locale.currentLocale.code
            )
        ).valueSignal.compactMap { $0.embarkStory }.onValue { embarkStory in
            activityIndicator.removeFromSuperview()

            self.state.storySignal.value = embarkStory
            self.state.passagesSignal.value = embarkStory.passages
            self.state.startPassageIDSignal.value = embarkStory.startPassage
            self.state.restart()
        }

        return (viewController, Future { completion in
            let backButton = UIBarButtonItem(image: hCoreUIAssets.backButton.image, style: .plain, target: nil, action: nil)

            if #available(iOS 14.0, *) {
                func createBackMenu(canGoBack: Bool) -> UIMenu {
                    let previousAction = UIAction(
                        title: L10n.embarkGoBackButton,
                        image: nil
                    ) { _ in
                        state.goBack()
                    }

                    let closeAction = UIAction(
                        title: L10n.embarkExitButton,
                        image: hCoreUIAssets.tinyCircledX.image,
                        attributes: .destructive
                    ) { _ in
                        completion(.success)
                    }

                    let menuActions = [canGoBack ? previousAction : nil, closeAction].compactMap { $0 }

                    let addNewMenu = UIMenu(
                        title: "",
                        children: menuActions
                    )

                    return addNewMenu
                }

                bag += state.canGoBackSignal.atOnce().map(createBackMenu).bindTo(backButton, \.menu)
            }

            viewController.navigationItem.leftBarButtonItem = backButton
            
            let tooltipButton = UIButton()
            tooltipButton.isHidden = true
            tooltipButton.setImage(hCoreUIAssets.infoLarge.image, for: .normal)
            
            bag += state.passageTooltipSignal.atOnce().onValue({ (shouldShow) in
                tooltipButton.isHidden = !shouldShow
            })
            
            let didTapTooltip = tooltipButton.signal(for: .touchUpInside)
            
            bag += didTapTooltip
                .withLatestFrom(state.currentPassageSignal.atOnce().plain())
                .map { tuple in return tuple.1 }
                .onValue({ (passage) in
                    
                    guard let tooltip = passage?.tooltips.first else { return }
                    
                    let alert = EmbarkAlert(tooltip: tooltip)
                    
                    viewController.present(
                        alert.wrappedInCloseButton(),
                        style: .detented(.preferredContentSize),
                        options: [
                            .defaults,
                            .prefersLargeTitles(false),
                        ])
                })
            

            let optionsButton = UIBarButtonItem(image: hCoreUIAssets.menuIcon.image, style: .plain, target: nil, action: nil)

            bag += optionsButton.attachSinglePressMenu(
                viewController: viewController,
                menu: Menu(
                    title: nil,
                    children: [
                        MenuChild(
                            title: "Restart questions",
                            style: .destructive,
                            image: hCoreUIAssets.restart.image
                        ) {
                            state.restart()
                        },
                    ]
                )
            )

            viewController.navigationItem.rightBarButtonItems = [optionsButton, UIBarButtonItem(button: tooltipButton)]

            bag += backButton.throttle(1).withLatestFrom(state.canGoBackSignal).onValue { _, canGoBack in
                if canGoBack {
                    state.goBack()
                } else {
                    completion(.success)
                }
            }

            return bag
        })
    }
}
