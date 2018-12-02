//
//  UIButton+On.swift
//  Hedvig
//
//  Created by Sam Pettersson on 2018-11-30.
//  Copyright © 2018 Hedvig AB. All rights reserved.
//

import Flow
import Foundation
import UIKit

extension UIButton {
    private struct AssociatedKeys {
        static var touchHandlerKey = "ControlTouchHandlerKey"
    }

    private var touchHandler: UIControlTouchHandler {
        get {
            if let handler = objc_getAssociatedObject(self, &AssociatedKeys.touchHandlerKey) as? UIControlTouchHandler {
                return handler
            } else {
                self.touchHandler = UIControlTouchHandler(control: self)
                return self.touchHandler
            }
        }
        set {
            objc_setAssociatedObject(
                self,
                &AssociatedKeys.touchHandlerKey,
                newValue,
                .OBJC_ASSOCIATION_RETAIN_NONATOMIC
            )
        }
    }

    // swiftlint:disable:next cyclomatic_complexity
    func on(event: UIControl.Event) -> (Signal<UIButton>) {
        return Signal<UIButton> { callback in
            let completion = {
                callback(self)
            }

            switch event {
            case .touchDown:
                return self.touchHandler.onTouchDown.addCallback(completion)
            case .touchDragInside:
                return self.touchHandler.onTouchDownRepeat.addCallback(completion)
            case .touchDragOutside:
                return self.touchHandler.onTouchDragOutside.addCallback(completion)
            case .touchDragEnter:
                return self.touchHandler.onTouchDragEnter.addCallback(completion)
            case .touchDragExit:
                return self.touchHandler.onTouchDragExit.addCallback(completion)
            case .touchUpInside:
                return self.touchHandler.onTouchUpInside.addCallback(completion)
            case .touchUpOutside:
                return self.touchHandler.onTouchUpOutside.addCallback(completion)
            case .touchCancel:
                return self.touchHandler.onTouchCancel.addCallback(completion)
            case .valueChanged:
                return self.touchHandler.onValueChanged.addCallback(completion)
            case .editingDidBegin:
                return self.touchHandler.onEditingDidBegin.addCallback(completion)
            case .editingChanged:
                return self.touchHandler.onEditingChanged.addCallback(completion)
            case .editingDidEnd:
                return self.touchHandler.onEditingChanged.addCallback(completion)
            case .editingDidEndOnExit:
                return self.touchHandler.onEditingDidEndOnExit.addCallback(completion)
            case .allTouchEvents:
                return self.touchHandler.onAllTouchEvents.addCallback(completion)
            case .allEditingEvents:
                return self.touchHandler.onAllEditingEvents.addCallback(completion)
            case .applicationReserved:
                return self.touchHandler.onApplicationReserved.addCallback(completion)
            case .systemReserved:
                return self.touchHandler.onSystemReserved.addCallback(completion)
            case .allEvents:
                return self.touchHandler.onAllEvents.addCallback(completion)
            default:
                return NilDisposer()
            }
        }
    }
}
