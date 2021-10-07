import Flow
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

    public var withScrollEdgeDismissButton: Self {
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
