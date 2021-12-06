import Apollo
import Flow
import Form
import Foundation
import Presentation
import UIKit
import hCore
import hCoreUI
import hGraphQL

public enum OfferOption {
    case menuToTrailing
    case shouldPreserveState
}

public struct Offer {
    let menu: hCore.Menu?
    let options: Set<OfferOption>

    public init(
        menu: hCore.Menu?,
        options: Set<OfferOption> = []
    ) {
        self.menu = menu
        self.options = options
    }
}

extension Offer {
    public func setIds(_ ids: [String]) -> Self {
        let store: OfferStore = globalPresentableStoreContainer.get()
        store.send(.setIds(ids: ids, selectedIds: ids))
        return self
    }

    public func setIds(_ ids: [String], selectedIds: [String]) -> Self {
        let store: OfferStore = globalPresentableStoreContainer.get()
        store.send(.setIds(ids: ids, selectedIds: selectedIds))
        return self
    }
}

public enum OfferResult {
    case signed(ids: [String], startDates: [String: Date?])
    case close
    case chat
    case menu(_ action: MenuChildAction)
}

extension Offer: Presentable {
    public func materialize() -> (UIViewController, FiniteSignal<OfferResult>) {
        let viewController = UIViewController()

        let store: OfferStore = self.get()

        if options.contains(.shouldPreserveState) {
            ApplicationState.preserveState(.offer)
        }

        if #available(iOS 13.0, *) {
            let appearance = UINavigationBarAppearance()
            appearance.configureWithTransparentBackground()
            DefaultStyling.applyCommonNavigationBarStyling(appearance)
            viewController.navigationItem.standardAppearance = appearance
            viewController.navigationItem.compactAppearance = appearance
        }

        let bag = DisposeBag()
        bag += store.stateSignal.compactMap { $0.currentVariant?.bundle.appConfiguration.title }
            .distinct()
            .delay(by: 0.1)
            .onValue { title in
                viewController.navigationItem.titleView = nil
                viewController.title = nil

                if let navigationBar = viewController.navigationController?.navigationBar,
                    navigationBar.layer.animation(forKey: "fadeText") == nil
                {

                    let fadeTextAnimation = CATransition()
                    fadeTextAnimation.duration = 0.25
                    fadeTextAnimation.type = .fade
                    fadeTextAnimation.fillMode = .both

                    navigationBar.layer
                        .add(fadeTextAnimation, forKey: "fadeText")
                }

                switch title {
                case .logo:
                    viewController.navigationItem.titleView = .titleWordmarkView
                case .updateSummary:
                    viewController.title = L10n.offerUpdateSummaryTitle
                case .unknown:
                    break
                }
            }

        let optionsOrCloseButton = UIBarButtonItem(
            image: hCoreUIAssets.menuIcon.image,
            style: .plain,
            target: nil,
            action: nil
        )

        if options.contains(.menuToTrailing) {
            viewController.navigationItem.rightBarButtonItem = optionsOrCloseButton
        } else {
            viewController.navigationItem.leftBarButtonItem = optionsOrCloseButton
        }

        let scrollView = FormScrollView(
            frame: .zero,
            appliesGradient: false
        )
        scrollView.backgroundColor = .brand(.primaryBackground())

        let form = FormView()
        form.allowTouchesOfViewsOutsideBounds = true
        form.dynamicStyle = DynamicFormStyle { _ in
            .init(insets: .zero)
        }
        bag += viewController.install(form, scrollView: scrollView)

        bag += form.append(Header(scrollView: scrollView))
        bag += form.append(MainContentForm(scrollView: scrollView))

        let navigationBarBackgroundView = UIView()
        navigationBarBackgroundView.backgroundColor = .brand(.secondaryBackground())
        navigationBarBackgroundView.alpha = 0
        scrollView.addSubview(navigationBarBackgroundView)

        navigationBarBackgroundView.snp.makeConstraints { make in
            make.top.equalTo(scrollView.frameLayoutGuide.snp.top)
            make.width.equalToSuperview()
            make.height.equalTo(0)
        }

        let navigationBarBorderView = UIView()
        navigationBarBorderView.backgroundColor = .brand(.primaryBorderColor)
        navigationBarBackgroundView.addSubview(navigationBarBorderView)

        navigationBarBorderView.snp.makeConstraints { make in
            make.width.equalToSuperview()
            make.bottom.equalToSuperview()
            make.height.equalTo(CGFloat.hairlineWidth)
        }

        bag += scrollView.signal(for: \.contentOffset)
            .atOnce()
            .onValue { contentOffset in
                navigationBarBackgroundView.alpha =
                    (contentOffset.y + scrollView.safeAreaInsets.top) / (Header.insetTop)
                navigationBarBackgroundView.snp.updateConstraints { make in
                    if let navigationBar = viewController.navigationController?.navigationBar,
                        let insetTop = viewController.navigationController?.view.safeAreaInsets
                            .top
                    {
                        make.height.equalTo(navigationBar.frame.height + insetTop)
                    }
                }
            }

        return (
            viewController,
            FiniteSignal { callback in
                store.send(.query)

                bag += store.onAction(.openChat) {
                    callback(.value(.chat))
                }

                bag += store.onAction(.sign(event: .done)) {
                    callback(.value(.signed(ids: store.state.ids, startDates: store.state.startDates)))
                }

                if let menu = menu {
                    bag += optionsOrCloseButton.attachSinglePressMenu(
                        viewController: viewController,
                        menu: menu
                    ) { action in
                        callback(.value(.menu(action)))
                    }
                } else {
                    optionsOrCloseButton.image = hCoreUIAssets.close.image
                    bag += optionsOrCloseButton.onValue {
                        callback(.value(.close))
                    }
                }

                return DelayedDisposer(bag, delay: 2)
            }
        )
    }
}
