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

public enum EmbarkFlowType {
    case onboarding
}

public enum EmbarkMenuRoute: CaseIterable {
    case appInformation
    case appSettings
    case login
    case restart

    var title: String {
        switch self {
        case .appInformation:
            return L10n.aboutScreenTitle
        case .appSettings:
            return L10n.Profile.AppSettingsSection.title
        case .login:
            return L10n.settingsLoginRow
        case .restart:
            return L10n.embarkRestartButton
        }
    }

    var style: MenuStyle {
        switch self {
        case .restart:
            return .destructive
        case .appInformation, .appSettings, .login:
            return .default
        }
    }

    var image: UIImage {
        switch self {
        case .appInformation:
            return hCoreUIAssets.infoLarge.image
        case .appSettings:
            return hCoreUIAssets.settingsIcon.image
        case .restart:
            return hCoreUIAssets.restart.image
        case .login:
            return hCoreUIAssets.profileCircleIcon.image
        }
    }
}

public struct Embark {
    @Inject var client: ApolloClient
    let name: String
    let flowType: EmbarkFlowType
    let state = EmbarkState()
    public let routeSignal = ReadWriteSignal<EmbarkMenuRoute?>(nil)

    public init(name: String, flowType: EmbarkFlowType) {
        self.name = name
        self.flowType = flowType
    }
}

extension Embark: Presentable {
    public func materialize() -> (UIViewController, FiniteSignal<ExternalRedirect>) {
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

        return (viewController, FiniteSignal<ExternalRedirect> { callback in
            bag += state.externalRedirectSignal.compactMap { $0 }.onValue { redirect in
                callback(.value(redirect))
            }

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
            tooltipButton.setImage(hCoreUIAssets.infoLarge.image, for: .normal)

            let didTapTooltip = tooltipButton.signal(for: .touchUpInside)

            bag += didTapTooltip
                .onValue { () in

                    let embarkTooltipsAlert = EmbarkTooltipAlert(tooltips: state.passageTooltipsSignal.value)

                    viewController.present(
                        embarkTooltipsAlert.wrappedInCloseButton(),
                        style: .detented(.preferredContentSize),
                        options: [
                            .defaults,
                            .prefersLargeTitles(true),
                        ]
                    )
                }

            let optionsButton = UIBarButtonItem(image: hCoreUIAssets.menuIcon.image, style: .plain, target: nil, action: nil)

            let routes = EmbarkMenuRoute.allCases

            func routeHandler(route: EmbarkMenuRoute) {
                if case .restart = route {
                    state.restart()
                } else {
                    routeSignal.value = route
                }
            }

            bag += optionsButton.attachSinglePressMenu(
                viewController: viewController,
                menu: Menu(
                    title: nil,
                    children:
                    routes.map { route in MenuChild.embarkChild(for: route) {
                        routeHandler(route: route)
                    }}
                )
            )

            bag += state.passageTooltipsSignal.atOnce()
                .map { tooltips in tooltips.isEmpty ? [optionsButton] : [optionsButton, UIBarButtonItem(button: tooltipButton)] }
                .onValue { items in
                    viewController.navigationItem.setRightBarButtonItems(items, animated: true)
                }

            bag += backButton.throttle(1).withLatestFrom(state.canGoBackSignal).onValue { _, canGoBack in
                if canGoBack {
                    state.goBack()
                } else {
                    callback(.end)
                }
            }

            return bag
        })
    }
}

private extension MenuChild {
    static func embarkChild(for route: EmbarkMenuRoute, handler: @escaping () -> Void) -> MenuChild {
        MenuChild(
            title: route.title,
            style: route.style,
            image: route.image,
            handler: handler
        )
    }
}
