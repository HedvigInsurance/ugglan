//
//  AccessoryViewController.swift
//  Ugglan
//
//  Created by Sam Pettersson on 2019-09-02.
//

import Flow
import Foundation
import hCore
import UIKit

class AccessoryViewController<Accessory: Viewable>: UIViewController where Accessory.Events == ViewableEvents, Accessory.Matter: UIView, Accessory.Result == Disposable {
    let accessoryView: Accessory.Matter

    init(accessoryView: Accessory) {
        let (view, disposable) = accessoryView.materialize(events: ViewableEvents(wasAddedCallbacker: Callbacker<Void>()))
        self.accessoryView = view

        let bag = DisposeBag()

        bag += disposable

        super.init(nibName: nil, bundle: nil)

        bag += deallocSignal.onValue { _ in
            bag.dispose()
        }
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override var canBecomeFirstResponder: Bool {
        return true
    }

    override var inputAccessoryView: UIView? {
        return accessoryView
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        becomeFirstResponder()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        becomeFirstResponder()
    }
}
