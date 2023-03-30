import Flow
import Form
import Foundation
import Presentation
import UIKit

extension JourneyPresentation {
    public var withDismissButton: Self {
        addConfiguration { presenter in
            let viewController = presenter.viewController
            // move over any barButtonItems to the other side
            if viewController.navigationItem.rightBarButtonItems != nil {
                viewController.navigationItem.leftBarButtonItems =
                    viewController.navigationItem.rightBarButtonItems
            }

            let closeButtonItem = UIBarButtonItem(
                image: hCoreUIAssets.close.image,
                style: .plain,
                target: nil,
                action: nil
            )

            presenter.bag += closeButtonItem.onValue { _ in
                presenter.dismisser(JourneyError.cancelled)
            }

            viewController.navigationItem.rightBarButtonItem = closeButtonItem
        }
    }

    public var scrollEdgeNavigationItemHandler: Self {
        addConfiguration { presenter in
            let viewController = presenter.viewController

            if #available(iOS 15, *) {
                presenter.bag += viewController.view.didLayoutSignal.onValueDisposePrevious { _ in
                    let innerBag = DisposeBag()

                    if let scrollView = viewController.view.allDescendants(ofType: UIScrollView.self)
                        .first(where: { _ in true })
                    {
                        innerBag += scrollView.signal(for: \.contentOffset)
                            .onValue { offset in
                                let endColor = UIColor(dynamic: { trait in
                                    trait.userInterfaceStyle == .dark ? .white : .black
                                })

                                let fraction = (offset.y + scrollView.adjustedContentInset.top) / 5

                                let interpolatedColor: UIColor = .white.interpolateColorTo(
                                    end: endColor,
                                    fraction: fraction
                                )

                                viewController.navigationItem.rightBarButtonItem?.tintColor = interpolatedColor
                                viewController.navigationItem.leftBarButtonItem?.tintColor = interpolatedColor

                                let scrollEdgeAppearance = DefaultStyling.scrollEdgeNavigationBarAppearance()
                                scrollEdgeAppearance.titleTextAttributes = scrollEdgeAppearance.titleTextAttributes
                                    .merging(
                                        [
                                            NSAttributedString.Key.foregroundColor: interpolatedColor
                                        ],
                                        uniquingKeysWith: { _, rhs in rhs }
                                    )

                                viewController.navigationItem.scrollEdgeAppearance = scrollEdgeAppearance
                            }
                    }

                    return innerBag
                }
            }

        }
    }

    public var withJourneyDismissButton: Self {
        addConfiguration { presenter in
            let viewController = presenter.viewController
            // move over any barButtonItems to the other side
            if viewController.navigationItem.rightBarButtonItems != nil {
                viewController.navigationItem.leftBarButtonItems =
                    viewController.navigationItem.rightBarButtonItems
            }

            let closeButtonItem = UIBarButtonItem(
                image: hCoreUIAssets.close.image,
                style: .plain,
                target: nil,
                action: nil
            )

            presenter.bag += closeButtonItem.onValue { _ in
                presenter.dismisser(JourneyError.dismissed)
            }

            viewController.navigationItem.rightBarButtonItem = closeButtonItem
        }
    }
}
