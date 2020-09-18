import Apollo
import Flow
import Form
import Foundation
import hCore
import hGraphQL
import Presentation
import UIKit

extension PresentationStyle {
    public static var autoDismissOnClose: PresentationStyle {
        PresentationStyle(name: "autoDismissOnClose") { (viewController, from, options) -> Result in

            PresentationStyle.default.present(viewController, from: from, options: options)
        }
    }
}

public struct Pager {
    public var title: String
    public var buttonContinueTitle: String
    public var buttonDoneTitle: String
    @ReadWriteState public var pages: [PagerItem]
    public var onEnd: (_ viewController: UIViewController) -> Future<Void>

    public init(
        title: String,
        buttonContinueTitle: String,
        buttonDoneTitle: String,
        pages: [PagerItem],
        onEnd: @escaping (_ viewController: UIViewController) -> Future<Void>
    ) {
        self.title = title
        self.pages = pages
        self.buttonContinueTitle = buttonContinueTitle
        self.buttonDoneTitle = buttonDoneTitle
        self.onEnd = onEnd
    }
}

extension Pager: Presentable {
    public func materialize() -> (UIViewController, Future<Void>) {
        let bag = DisposeBag()

        let viewController = UIViewController()
        viewController.title = title
        viewController.preferredPresentationStyle = .detented(.large)

        let closeButton = CloseButton()

        let item = UIBarButtonItem(viewable: closeButton)
        viewController.navigationItem.rightBarButtonItem = item

        let view = UIView()
        view.backgroundColor = .brand(.secondaryBackground())

        let containerView = UIStackView()
        containerView.axis = .vertical
        containerView.alignment = .center
        containerView.isLayoutMarginsRelativeArrangement = true
        view.addSubview(containerView)

        containerView.snp.makeConstraints { make in
            make.width.centerX.centerY.equalToSuperview()
            make.height.equalToSuperview().inset(20)
        }

        let scrollToNextCallbacker = Callbacker<Void>()
        let scrolledToPageIndexCallbacker = Callbacker<Int>()
        let scrolledToEndCallbacker = Callbacker<Void>()

        let pager = PagerCollection(
            pages: [],
            scrollToNextSignal: scrollToNextCallbacker.providedSignal,
            scrolledToPageIndexCallbacker: scrolledToPageIndexCallbacker
        )

        bag += containerView.addArranged(pager) { pagerView in
            pagerView.snp.makeConstraints { make in
                make.width.centerX.equalToSuperview()
            }
        }

        let controlsWrapper = UIStackView()
        controlsWrapper.axis = .vertical
        controlsWrapper.spacing = 16
        controlsWrapper.distribution = .equalSpacing
        controlsWrapper.isLayoutMarginsRelativeArrangement = true
        controlsWrapper.edgeInsets = UIEdgeInsets(top: 20, left: 20, bottom: 0, right: 20)

        containerView.addArrangedSubview(controlsWrapper)

        controlsWrapper.snp.makeConstraints { make in
            make.width.equalToSuperview()
        }

        let pagerDots = PagerDots()

        bag += controlsWrapper.addArranged(pagerDots) { pagerDotsView in
            pagerDotsView.snp.makeConstraints { make in
                make.centerX.equalToSuperview()
                make.height.equalTo(20)
            }
        }

        let proceedButton = PagerProceedButton(
            buttonContinueTitle: buttonContinueTitle,
            buttonDoneTitle: buttonDoneTitle,
            button: Button(title: "", type: .standard(backgroundColor: .brand(.secondaryButtonBackgroundColor), textColor: .brand(.secondaryButtonTextColor)))
        )

        bag += controlsWrapper.addArranged(proceedButton)

        bag += $pages.atOnce().onValueDisposePrevious { pages -> Disposable? in
            let innerBag = DisposeBag()

            if pages.isEmpty {
                let activityIndicator = UIActivityIndicatorView()
                activityIndicator.startAnimating()
                view.addSubview(activityIndicator)

                activityIndicator.snp.makeConstraints { make in
                    make.center.equalToSuperview()
                }

                innerBag += Disposer {
                    bag += Signal(after: 0).animated(style: .easeOut(duration: 0.25)) { _ in
                        activityIndicator.alpha = 0
                    }.onValue {
                        activityIndicator.removeFromSuperview()
                    }
                }
            }

            return innerBag
        }

        bag += $pages.atOnce().onValue { pages in
            controlsWrapper.animationSafeIsHidden = pages.isEmpty
        }
        bag += $pages.atOnce().bindTo(pager.$pages)
        bag += $pages.atOnce().compactMap { $0.count }.bindTo(proceedButton.pageAmountSignal)
        bag += $pages.atOnce().compactMap { $0.count }.bindTo(pagerDots.pageAmountSignal)

        bag += pager.scrolledToPageIndexCallbacker.bindTo(pagerDots.pageIndexSignal)
        bag += pager.scrolledToPageIndexCallbacker.bindTo(proceedButton.onScrolledToPageIndexSignal)

        bag += combineLatest(proceedButton.onScrolledToPageIndexSignal, $pages).driven(by: proceedButton.onTapSignal).onValue { index, pages in
            if index == (pages.count - 1) {
                scrolledToEndCallbacker.callAll()
            } else {
                scrollToNextCallbacker.callAll()
            }
        }

        viewController.view = view

        return (viewController, Future { completion in
            bag += closeButton.onTapSignal.onValue {
                completion(.success)
            }

            bag += scrolledToEndCallbacker.providedSignal.onValue {
                self.onEnd(viewController).onResult(completion)
            }

            return DelayedDisposer(bag, delay: 2)
        })
    }
}
