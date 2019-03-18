//
//  ActivityView.swift
//  Hedvig
//
//  Created by Sam Pettersson on 2019-01-17.
//  Copyright © 2019 Hedvig AB. All rights reserved.
//

import Flow
import Foundation
import Presentation
import UIKit

extension PresentationStyle {
    static let activityView = PresentationStyle(name: "activityView") { viewController, from, _ in
        let future = Future<Void> { completion in
            from.present(viewController, animated: true) {
                completion(.success)
            }

            return NilDisposer()
        }

        return (future, { Future() })
    }
}

struct ActivityView {
    let activityItems: [Any]
    let applicationActivities: [UIActivity]?
    let sourceView: UIView?
    let sourceRect: CGRect?
}

extension ActivityView: Presentable {
    func materialize() -> (UIActivityViewController, Disposable) {
        let viewController = UIActivityViewController(
            activityItems: activityItems,
            applicationActivities: applicationActivities
        )
        viewController.preferredPresentationStyle = .activityView

        if let popover = viewController.popoverPresentationController, let sourceRect = sourceRect {
            popover.sourceView = sourceView
            popover.sourceRect = sourceRect
        }

        return (viewController, NilDisposer())
    }
}
