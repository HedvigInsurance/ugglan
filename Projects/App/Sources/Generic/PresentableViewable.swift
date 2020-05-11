//
//  PresentableViewable.swift
//  test
//
//  Created by Sam Pettersson on 2020-01-21.
//

import Flow
import Form
import Foundation
import Presentation
import UIKit
import Core

struct PresentableViewable<View: Viewable, SignalValue>: Presentable where View.Events == ViewableEvents, View.Matter: UIView, View.Result == Signal<SignalValue> {
    let viewable: View
    let customizeViewController: (_ vc: UIViewController) -> Void

    func materialize() -> (UIViewController, Signal<SignalValue>) {
        let viewController = UIViewController()
        customizeViewController(viewController)
        let containerView = UIView()
        viewController.view = containerView

        let bag = DisposeBag()

        bag += containerView.traitCollectionSignal.onValue { _ in
            self.customizeViewController(viewController)
        }

        return (viewController, containerView.add(viewable) { view in
            view.snp.remakeConstraints { make in
                make.top.bottom.trailing.leading.equalToSuperview()
            }
        }.hold(bag))
    }
}
