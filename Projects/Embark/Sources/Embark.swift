import Apollo
import Flow
import Form
import Foundation
import Presentation
import SnapKit
import UIKit
import hCore
import hCoreUI
import hGraphQL

public struct Embark {
    @Inject var giraffe: hGiraffe
    let name: String
    public let menu: Menu?
    let state: EmbarkState

    public func goBack() { state.goBack() }

    public init(
        name: String,
        menu: Menu? = nil
    ) {
        self.name = name
        self.menu = menu
        self.state = EmbarkState()
    }
}

extension MenuChildAction {
    static var restart: MenuChildAction {
        MenuChildAction(identifier: "embark-restart")
    }
}

extension Embark: Presentable {
    public func materialize() -> (UIViewController, FiniteSignal<ExternalRedirect>) {
        let viewController = UIViewController()
        viewController.navigationItem.largeTitleDisplayMode = .never
        let bag = DisposeBag()

        let edgePanGestureRecognizer = UIScreenEdgePanGestureRecognizer()
        edgePanGestureRecognizer.edges = [.left]
        state.edgePanGestureRecognizer = edgePanGestureRecognizer

        let scrollView = FormScrollView()
        scrollView.backgroundColor = .brand(.primaryBackground())
        let form = FormView()

        bag += viewController.install(form, options: [], scrollView: scrollView) { scrollView in
            scrollView.alwaysBounceVertical = false

            bag += combineLatest(
                scrollView.traitCollectionSignal.atOnce(),
                scrollView.signal(for: \.contentSize).atOnce()
            )
            .onValue { _, _ in
                form.applyStyle(
                    .init(
                        insets: .init(
                            top: 0,
                            left: 0,
                            bottom: scrollView.isScrollEnabled ? 16 : 0,
                            right: 0
                        )
                    )
                )
            }
        }

        viewController.navigationItem.titleView = .titleWordmarkView

        let passage = Passage(state: state)
        bag +=
            form.append(passage) { passageView in var keyboardHeight: CGFloat = 20
                func updatePassageViewHeight() {
                    passageView.snp.updateConstraints { make in
                        make.top.bottom.leading.trailing.equalToSuperview()
                        make.height.greaterThanOrEqualTo(
                            scrollView.frame.height - scrollView.safeAreaInsets.top
                                - scrollView.safeAreaInsets.bottom - keyboardHeight
                        )
                    }
                }

                bag += form.didLayoutSignal.onValue { updatePassageViewHeight() }

                bag += NotificationCenter.default
                    .signal(forName: UIResponder.keyboardWillChangeFrameNotification)
                    .compactMap { notification in notification.keyboardInfo }
                    .animated(
                        mapStyle: { (keyboardInfo) -> AnimationStyle in
                            AnimationStyle(
                                options: keyboardInfo.animationCurve,
                                duration: keyboardInfo.animationDuration,
                                delay: 0
                            )
                        },
                        animations: { keyboardInfo in
                            scrollView.contentInset = UIEdgeInsets(
                                top: 0,
                                left: 0,
                                bottom: keyboardInfo.height - 20
                                    - scrollView.safeAreaInsets.bottom,
                                right: 0
                            )
                            scrollView.scrollIndicatorInsets = UIEdgeInsets(
                                top: 0,
                                left: 0,
                                bottom: keyboardInfo.height,
                                right: 0
                            )
                            keyboardHeight =
                                keyboardInfo.height - scrollView.safeAreaInsets.bottom
                            updatePassageViewHeight()
                            passageView.layoutIfNeeded()
                            form.layoutIfNeeded()
                            scrollView.layoutIfNeeded()
                        }
                    )

                bag += NotificationCenter.default
                    .signal(forName: UIResponder.keyboardWillHideNotification)
                    .compactMap { notification in notification.keyboardInfo }
                    .animated(
                        mapStyle: { (keyboardInfo) -> AnimationStyle in
                            AnimationStyle(
                                options: keyboardInfo.animationCurve,
                                duration: keyboardInfo.animationDuration,
                                delay: 0
                            )
                        },
                        animations: { _ in keyboardHeight = 20
                            scrollView.contentInset = .zero
                            scrollView.scrollIndicatorInsets = .zero
                            updatePassageViewHeight()
                            passageView.layoutIfNeeded()
                            form.layoutIfNeeded()
                            scrollView.layoutIfNeeded()
                        }
                    )
            }
            .onValue { link in self.state.goTo(passageName: link.name) }

        let progressView = UIProgressView()
        progressView.tintColor = .brand(.primaryText())
        progressView.progressViewStyle = .bar
        scrollView.addSubview(progressView)

        progressView.snp.makeConstraints { make in make.top.equalTo(scrollView.safeAreaLayoutGuide.snp.top)
            make.width.equalToSuperview()
            make.height.equalTo(2)
            make.centerX.equalToSuperview()
        }

        bag += state.progressSignal.animated(
            style: .lightBounce(),
            animations: { progress in
                progressView.animationSafeIsHidden = progress == 0
                progressView.setProgress(progress, animated: false)
                progressView.setNeedsLayout()
                progressView.layoutIfNeeded()
            }
        )

        let activityIndicator = UIActivityIndicatorView()
        activityIndicator.startAnimating()

        form.addSubview(activityIndicator)

        activityIndicator.snp.makeConstraints { make in make.center.equalToSuperview() }

        bag += giraffe.client
            .fetch(
                query: GiraffeGraphQL.EmbarkStoryQuery(
                    name: name,
                    locale: Localization.Locale.currentLocale.code
                ),
                cachePolicy: .fetchIgnoringCacheData
            )
            .valueSignal.compactMap { $0.embarkStory }
            .onValue { embarkStory in
                giraffe.client
                    .perform(
                        mutation: GiraffeGraphQL.CreateQuoteCartMutation(
                            input: .init(
                                market: Localization.Locale.currentLocale.market.graphQL,
                                locale: Localization.Locale.currentLocale.code
                            )
                        )
                    )
                    .onValue { quoteCartCreate in
                        activityIndicator.removeFromSuperview()
                        self.state.quoteCartId = quoteCartCreate.createQuoteCart.id
                        self.state.storySignal.value = embarkStory
                        self.state.passagesSignal.value = embarkStory.passages
                        self.state.startPassageIDSignal.value = embarkStory.startPassage
                        self.state.restart()
                    }
            }

        bag += edgePanGestureRecognizer.signal(forState: .ended)
            .withLatestFrom(state.canGoBackSignal.atOnce().plain())
            .onValue { _, canGoBack in guard canGoBack else { return }

                let translationX = edgePanGestureRecognizer.translation(in: viewController.view).x

                if translationX > (viewController.view.frame.width * 0.4) { state.goBack() }
            }

        bag += state.canGoBackSignal.atOnce()
            .onValueDisposePrevious { canGoBack in guard canGoBack else { return NilDisposer() }

                viewController.navigationController?.interactivePopGestureRecognizer?.isEnabled = false

                let innerBag = DisposeBag()

                innerBag += {
                    viewController.navigationController?.interactivePopGestureRecognizer?.isEnabled =
                        true
                }

                innerBag += viewController.view.install(edgePanGestureRecognizer)

                return innerBag
            }

        return (
            viewController,
            FiniteSignal<ExternalRedirect> { callback in
                bag += state.externalRedirectSignal.compactMap { $0 }
                    .onValue { redirect in callback(.value(redirect)) }

                let backButton = UIBarButtonItem(
                    image: hCoreUIAssets.arrowBack.image,
                    style: .plain,
                    target: nil,
                    action: nil
                )

                func createBackMenu(canGoBack: Bool) -> UIMenu {
                    let previousAction = UIAction(
                        title: L10n.embarkGoBackButton,
                        image: nil
                    ) { _ in state.goBack() }

                    let closeAction = UIAction(
                        title: L10n.embarkExitButton,
                        image: hCoreUIAssets.tinyCircledX.image,
                        attributes: .destructive
                    ) { _ in callback(.end) }

                    let menuActions = [canGoBack ? previousAction : nil, closeAction]
                        .compactMap { $0 }

                    let addNewMenu = UIMenu(title: "", children: menuActions)

                    return addNewMenu
                }

                bag += state.canGoBackSignal.atOnce().map(createBackMenu)
                    .bindTo(backButton, \.menu)

                bag += state.canGoBackSignal.atOnce()
                    .onValue { canGoBack in
                        if !canGoBack {
                            viewController.navigationItem.leftBarButtonItem = nil
                        } else {
                            viewController.navigationItem.leftBarButtonItem = backButton
                        }
                    }

                func presentRestartAlert(_ viewController: UIViewController) {
                    let alert = Alert(
                        title: L10n.Settings.alertRestartOnboardingTitle,
                        message: L10n.Settings.alertRestartOnboardingDescription,
                        tintColor: nil,
                        actions: [
                            Alert.Action(
                                title: L10n.alertOk,
                                style: UIAlertAction.Style.destructive
                            ) { true },
                            Alert.Action(
                                title: L10n.alertCancel,
                                style: UIAlertAction.Style.cancel
                            ) { false },
                        ]
                    )

                    bag += viewController.present(alert)
                        .onValue { shouldRestart in
                            if shouldRestart {
                                state.restart()
                            }
                        }
                }

                let optionsOrCloseButton = UIBarButtonItem(
                    image: hCoreUIAssets.menuIcon.image,
                    style: .plain,
                    target: nil,
                    action: nil
                )

                if let menu = menu {
                    bag += optionsOrCloseButton.attachSinglePressMenu(
                        viewController: viewController,
                        menu: Menu(
                            title: nil,
                            children: [
                                menu,
                                Menu(
                                    title: nil,
                                    children: [
                                        MenuChild(
                                            title: L10n.embarkRestartButton,
                                            style: .destructive,
                                            image: hCoreUIAssets.restart
                                                .image,
                                            action: .restart
                                        )
                                    ]
                                ),
                            ]
                            .compactMap { $0 }
                        )
                    ) { action in
                        if action == .restart {
                            presentRestartAlert(viewController)
                            return
                        }

                        callback(.value(.menu(action)))
                    }
                } else {
                    optionsOrCloseButton.image = hCoreUIAssets.close.image
                    bag += optionsOrCloseButton.onValue { _ in
                        callback(.value(.close))
                    }
                }

                let tooltipButton = UIButton()
                tooltipButton.setImage(hCoreUIAssets.infoIcon.image, for: .normal)

                let didTapTooltip = tooltipButton.signal(for: .touchUpInside)

                bag += didTapTooltip.onValue {
                    let embarkTooltips = EmbarkTooltips(tooltips: state.passageTooltipsSignal.value)

                    bag += viewController.present(
                        embarkTooltips.journey
                    )
                }

                viewController.navigationItem.setRightBarButtonItems(
                    [optionsOrCloseButton, UIBarButtonItem(button: tooltipButton)],
                    animated: false
                )

                bag += state.passageTooltipsSignal.atOnce()
                    .animated(style: .easeOut(duration: 0.25)) { tooltips in
                        tooltipButton.alpha = tooltips.isEmpty ? 0 : 1
                    }

                bag += backButton.throttle(1).withLatestFrom(state.canGoBackSignal)
                    .onValue { _, canGoBack in
                        if canGoBack { state.goBack() } else { callback(.end) }
                    }

                return DelayedDisposer(bag, delay: 2)
            }
        )
    }
}
