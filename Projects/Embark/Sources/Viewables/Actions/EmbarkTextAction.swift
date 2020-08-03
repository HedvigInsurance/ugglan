//
//  EmbarkTextAction.swift
//  test
//
//  Created by Sam Pettersson on 2020-01-16.
//

import Flow
import Foundation
import hCore
import hCoreUI
import Presentation
import UIKit

typealias EmbarkTextActionData = EmbarkStoryQuery.Data.EmbarkStory.Passage.Action.AsEmbarkTextAction

struct EmbarkTextAction {
    let state: EmbarkState
    let data: EmbarkTextActionData
    
    var masking: Masking? {
        if let mask = self.data.textActionData.mask,
            let maskType = MaskType(rawValue: mask) {
            return Masking(type: maskType)
        }
        
        return nil
    }
}

protocol ViewableAnimatorHandler {
    associatedtype Views
    associatedtype State
    func animate(animator: ViewableAnimator<Self>) -> ReadSignal<Bool>
}

class ViewableAnimator<AnimatorHandler: ViewableAnimatorHandler> {
    public init(
        state: AnimatorHandler.State,
        handler: AnimatorHandler,
        views: AnimatorHandler.Views
    ) {
        self.handler = handler
        self.state = state
        self.views = views
    }
    
    private let handler: AnimatorHandler
    var views: AnimatorHandler.Views
    private var bag = DisposeBag()
    private(set) var state: AnimatorHandler.State
    
    func setState(_ state: AnimatorHandler.State) -> ReadSignal<Bool> {
        self.state = state
        return self.handler.animate(animator: self)
    }
    
    func register<View: UIView>(key: WritableKeyPath<AnimatorHandler.Views, View>, value: View) {
        views[keyPath: key] = value
    }
}

@propertyWrapper
struct ViewableAnimatedView<View: UIView> {
    private var inner: View? = nil
    var wrappedValue: View {
        get {
            return inner ?? View()
        }
        set {
            inner = newValue
        }
    }
    
    init() {}
}

extension EmbarkTextAction: ViewableAnimatorHandler {
    typealias Views = AnimatorViews
    typealias State = AnimatorState
    
    struct AnimatorViews {
        @ViewableAnimatedView var view: UIStackView
        @ViewableAnimatedView var box: UIView
        @ViewableAnimatedView var boxStack: UIStackView
        @ViewableAnimatedView var input: UIView
        @ViewableAnimatedView var button: UIButton
    }
    
    enum AnimatorState {
        case loading
        case notLoading
    }
    
    func animate(animator: ViewableAnimator<Self>) -> ReadSignal<Bool> {
        guard animator.state == .loading else {
            return ReadSignal(true)
        }
        
        let bag = DisposeBag()
        
        let view = animator.views.view
        let boxStack = animator.views.boxStack
        let box = animator.views.box
        let button = animator.views.button
        let input = animator.views.input
        
        let dummyActivityIndicator = UIView()
        
        let activityIndicator = UIActivityIndicatorView()
        activityIndicator.startAnimating()
        activityIndicator.alpha = 0
        
        func layoutAllContainers() {
            boxStack.layoutIfNeeded()
            view.layoutIfNeeded()
            box.layoutIfNeeded()
        }
        
        bag += Animated.now.animated(style: .easeOut(duration: 0.35)) {
            button.alpha = 0
            button.isHidden = true
            button.transform = CGAffineTransform(translationX: 0, y: 50)
            layoutAllContainers()
        }

        let inputAndLoader = Animated.now.animated(style: .lightBounce(duration: 0.25)) {
            input.alpha = 0
            layoutAllContainers()
        }
        
        bag += inputAndLoader.atValue { _ in
            boxStack.addArrangedSubview(dummyActivityIndicator)
            boxStack.addSubview(activityIndicator)
            
            activityIndicator.snp.makeConstraints { make in
                make.center.equalTo(box.snp.center)
            }
            
            dummyActivityIndicator.snp.makeConstraints { make in
                make.width.height.equalTo(activityIndicator)
            }
            
            dummyActivityIndicator.layoutIfNeeded()
            activityIndicator.layoutIfNeeded()
        }.animated(style: .easeIn(duration: 0.25, delay: 0.20)) {
            activityIndicator.alpha = 1
            activityIndicator.layoutIfNeeded()
        }
        
        let completionSignal = inputAndLoader.animated(style: .lightBounce(duration: 0.5)) {
            input.isHidden = true
            boxStack.alignment = .center
            view.alignment = .center
            layoutAllContainers()
        }
                
        return completionSignal.hold(bag).boolean()
    }
}

extension EmbarkTextAction: Viewable {
    func materialize(events: ViewableEvents) -> (UIView, Signal<EmbarkLinkFragment>) {
        let view = UIStackView()
        view.axis = .vertical
        view.spacing = 10
        let animator = ViewableAnimator(state: .notLoading, handler: self, views: AnimatorViews())
        animator.register(key: \.view, value: view)
        
        let bag = DisposeBag()
        
        let box = UIView()
        box.backgroundColor = .brand(.secondaryBackground())
        box.layer.cornerRadius = 10
        bag += box.applyShadow { _ -> UIView.ShadowProperties in
            UIView.ShadowProperties(
                opacity: 0.25,
                offset: CGSize(width: 0, height: 6),
                radius: 8,
                color: .brand(.primaryShadowColor),
                path: nil
            )
        }
        animator.register(key: \.box, value: box)
        
        let boxStack = UIStackView()
        boxStack.axis = .vertical
        boxStack.layoutMargins = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        boxStack.isLayoutMarginsRelativeArrangement = true
        animator.register(key: \.boxStack, value: boxStack)
        
        box.addSubview(boxStack)
        boxStack.snp.makeConstraints { make in
            make.top.bottom.right.left.equalToSuperview()
        }
        view.addArrangedSubview(box)

        let input = EmbarkInput(
            placeholder: data.textActionData.placeholder,
            keyboardType: masking?.keyboardType,
            textContentType: masking?.textContentType,
            masking: masking
        )
        let textSignal = boxStack.addArranged(input) { inputView in
            animator.register(key: \.input, value: inputView)
        }
        bag += textSignal.nil()

        let button = Button(
            title: data.textActionData.link.fragments.embarkLinkFragment.label,
            type: .standard(backgroundColor: .black, textColor: .white)
        )
        bag += view.addArranged(button) { buttonView in
            animator.register(key: \.button, value: buttonView)
        }

        return (view, Signal { callback in
            func complete(_ value: String) {
                if let passageName = self.state.passageNameSignal.value {
                   self.state.store.setValue(
                       key: "\(passageName)Result",
                       value: value
                   )
               }
                
               let unmaskedValue = self.masking?.unmaskedValue(text: value) ?? value
               self.state.store.setValue(
                   key: self.data.textActionData.key,
                   value: unmaskedValue
               )
               
               if let derivedValues = self.masking?.derivedValues(text: value) {
                   derivedValues.forEach { (key, value) in
                       self.state.store.setValue(
                           key: "\(self.data.textActionData.key)\(key)",
                           value: value
                       )
                   }
               }
                
                self.state.store.createRevision()
                
                if let apiFragment = self.data.textActionData.api?.fragments.apiFragment {
                    bag += self.state.handleApi(apiFragment: apiFragment).valueSignal.wait(until: animator.setState(.loading)).onValue { link in
                        guard let link = link else {
                            return
                        }
                        callback(link)
                    }
                } else {
                    callback(self.data.textActionData.link.fragments.embarkLinkFragment)
                }
            }
            
            bag += input.shouldReturn.set { _ -> Bool in
                let innerBag = DisposeBag()
                innerBag += textSignal.atOnce().take(first: 1).onValue { value in
                    complete(value)
                    innerBag.dispose()
                }
                return true
            }
            
            bag += button.onTapSignal.withLatestFrom(textSignal.plain()).onValue { _, value in
               let innerBag = DisposeBag()
               innerBag += textSignal.atOnce().take(first: 1).onValue { value in
                   complete(value)
                   innerBag.dispose()
               }
            }

            return bag
        })
    }
}
