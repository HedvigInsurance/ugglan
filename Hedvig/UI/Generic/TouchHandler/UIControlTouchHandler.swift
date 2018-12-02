//
//  UIControlTouchHandler.swift
//  Hedvig
//
//  Created by Sam Pettersson on 2018-11-30.
//  Copyright © 2018 Hedvig AB. All rights reserved.
//

import Flow
import Foundation
import UIKit

public typealias TouchStandardClosure = () -> Void

extension UIControl.Event: Hashable {
    public var hashValue: Int {
        return Int(rawValue)
    }
}

internal class UIControlTouchHandler: NSObject {
    lazy var onTouchDown: Callbacker<Void> = {
        let callbacker = Callbacker<Void>()
        control.addTarget(self, action: #selector(touchDown), for: .touchDown)
        return callbacker
    }()

    lazy var onTouchDownRepeat: Callbacker<Void> = {
        let callbacker = Callbacker<Void>()
        control.addTarget(self, action: #selector(touchDownRepeat), for: .touchDownRepeat)
        return callbacker
    }()

    lazy var onTouchDragInside: Callbacker<Void> = {
        let callbacker = Callbacker<Void>()
        control.addTarget(self, action: #selector(touchDragInside), for: .touchDragInside)
        return callbacker
    }()

    lazy var onTouchDragOutside: Callbacker<Void> = {
        let callbacker = Callbacker<Void>()
        control.addTarget(self, action: #selector(touchDragOutside), for: .touchDragOutside)
        return callbacker
    }()

    lazy var onTouchDragEnter: Callbacker<Void> = {
        let callbacker = Callbacker<Void>()
        control.addTarget(self, action: #selector(touchDragEnter), for: .touchDragEnter)
        return callbacker
    }()

    lazy var onTouchDragExit: Callbacker<Void> = {
        let callbacker = Callbacker<Void>()
        control.addTarget(self, action: #selector(touchDragExit), for: .touchDragExit)
        return callbacker
    }()

    lazy var onTouchUpInside: Callbacker<Void> = {
        let callbacker = Callbacker<Void>()
        control.addTarget(self, action: #selector(touchUpInside), for: .touchUpInside)
        return callbacker
    }()

    lazy var onTouchUpOutside: Callbacker<Void> = {
        let callbacker = Callbacker<Void>()
        control.addTarget(self, action: #selector(touchUpOutside), for: .touchUpOutside)
        return callbacker
    }()

    lazy var onTouchCancel: Callbacker<Void> = {
        let callbacker = Callbacker<Void>()
        control.addTarget(self, action: #selector(touchCancel), for: .touchCancel)
        return callbacker
    }()

    lazy var onValueChanged: Callbacker<Void> = {
        let callbacker = Callbacker<Void>()
        control.addTarget(self, action: #selector(valueChanged), for: .valueChanged)
        return callbacker
    }()

    lazy var onEditingDidBegin: Callbacker<Void> = {
        let callbacker = Callbacker<Void>()
        control.addTarget(self, action: #selector(editingDidBegin), for: .editingDidBegin)
        return callbacker
    }()

    lazy var onEditingChanged: Callbacker<Void> = {
        let callbacker = Callbacker<Void>()
        control.addTarget(self, action: #selector(editingChanged), for: .editingChanged)
        return callbacker
    }()

    lazy var onEditingDidEnd: Callbacker<Void> = {
        let callbacker = Callbacker<Void>()
        control.addTarget(self, action: #selector(editingDidEnd), for: .editingDidEnd)
        return callbacker
    }()

    lazy var onEditingDidEndOnExit: Callbacker<Void> = {
        let callbacker = Callbacker<Void>()
        control.addTarget(self, action: #selector(editingDidEndOnExit), for: .editingDidEndOnExit)
        return callbacker
    }()

    lazy var onAllTouchEvents: Callbacker<Void> = {
        let callbacker = Callbacker<Void>()
        control.addTarget(self, action: #selector(allTouchEvents), for: .allTouchEvents)
        return callbacker
    }()

    lazy var onAllEditingEvents: Callbacker<Void> = {
        let callbacker = Callbacker<Void>()
        control.addTarget(self, action: #selector(allEditingEvents), for: .allEditingEvents)
        return callbacker
    }()

    lazy var onApplicationReserved: Callbacker<Void> = {
        let callbacker = Callbacker<Void>()
        control.addTarget(self, action: #selector(applicationReserved), for: .applicationReserved)
        return callbacker
    }()

    lazy var onSystemReserved: Callbacker<Void> = {
        let callbacker = Callbacker<Void>()
        control.addTarget(self, action: #selector(systemReserved), for: .systemReserved)
        return callbacker
    }()

    lazy var onAllEvents: Callbacker<Void> = {
        let callbacker = Callbacker<Void>()
        control.addTarget(self, action: #selector(allEvents), for: .allEvents)
        return callbacker
    }()

    private var control: UIControl

    init(control: UIControl) {
        self.control = control
        super.init()
    }

    deinit {
        control.removeTarget(self, action: nil, for: UIControl.Event.allEvents)
    }
}

internal extension UIControlTouchHandler {
    @objc fileprivate func touchDown(sender _: AnyObject) { onTouchDown.callAll() }
    @objc fileprivate func touchDownRepeat(sender _: AnyObject) { onTouchDownRepeat.callAll() }
    @objc fileprivate func touchDragInside(sender _: AnyObject) { onTouchDragInside.callAll() }
    @objc fileprivate func touchDragOutside(sender _: AnyObject) { onTouchDragOutside.callAll() }
    @objc fileprivate func touchDragEnter(sender _: AnyObject) { onTouchDragEnter.callAll() }
    @objc fileprivate func touchDragExit(sender _: AnyObject) { onTouchDragExit.callAll() }
    @objc fileprivate func touchUpInside(sender _: AnyObject) { onTouchUpInside.callAll() }
    @objc fileprivate func touchUpOutside(sender _: AnyObject) { onTouchUpOutside.callAll() }
    @objc fileprivate func touchCancel(sender _: AnyObject) { onTouchCancel.callAll() }
    @objc fileprivate func valueChanged(sender _: AnyObject) { onValueChanged.callAll() }
    @objc fileprivate func editingDidBegin(sender _: AnyObject) { onEditingDidBegin.callAll() }
    @objc fileprivate func editingChanged(sender _: AnyObject) { onEditingChanged.callAll() }
    @objc fileprivate func editingDidEnd(sender _: AnyObject) { onEditingDidEnd.callAll() }
    @objc fileprivate func editingDidEndOnExit(sender _: AnyObject) { onEditingDidEndOnExit.callAll() }
    @objc fileprivate func allTouchEvents(sender _: AnyObject) { onAllTouchEvents.callAll() }
    @objc fileprivate func allEditingEvents(sender _: AnyObject) { onAllEditingEvents.callAll() }
    @objc fileprivate func applicationReserved(sender _: AnyObject) { onApplicationReserved.callAll() }
    @objc fileprivate func systemReserved(sender _: AnyObject) { onSystemReserved.callAll() }
    @objc fileprivate func allEvents(sender _: AnyObject) { onAllEvents.callAll() }
}
