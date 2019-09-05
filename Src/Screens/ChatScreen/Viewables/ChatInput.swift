//
//  ChatInput.swift
//  UITests
//
//  Created by Sam Pettersson on 2019-07-12.
//

import Apollo
import Flow
import Foundation
import UIKit

struct ChatInput {
    let currentMessageSignal: ReadSignal<Message?>
    let navigateCallbacker: Callbacker<NavigationEvent>

    init(
        currentMessageSignal: ReadSignal<Message?>,
        navigateCallbacker: Callbacker<NavigationEvent>
    ) {
        self.currentMessageSignal = currentMessageSignal
        self.navigateCallbacker = navigateCallbacker
    }
}

class ViewWithFixedIntrinsicSize: UIView {
    override var intrinsicContentSize: CGSize {
        return CGSize(width: 0, height: 0)
    }
}

extension ChatInput: Viewable {
    func materialize(events _: ViewableEvents) -> (UIView, Disposable) {
        let bag = DisposeBag()

        let backgroundView = ViewWithFixedIntrinsicSize()
        backgroundView.autoresizingMask = .flexibleHeight
        backgroundView.backgroundColor = UIColor.primaryBackground.withAlphaComponent(0.8)

        let effectView = UIVisualEffectView()
        backgroundView.addSubview(effectView)

        bag += backgroundView.traitCollectionSignal.atOnce().onValue { trait in
            effectView.effect = UIBlurEffect(style: trait.userInterfaceStyle == .dark ? .dark : .light)
        }

        effectView.snp.makeConstraints { make in
            make.width.height.leading.trailing.equalToSuperview()
        }

        let topBorderView = UIView()
        topBorderView.backgroundColor = .primaryBorder
        backgroundView.addSubview(topBorderView)

        topBorderView.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.width.equalToSuperview()
            make.height.equalTo(1 / UIScreen.main.scale)
        }

        let containerView = UIStackView()
        containerView.axis = .vertical
        backgroundView.addSubview(containerView)

        containerView.snp.makeConstraints { make in
            make.leading.trailing.top.bottom.equalToSuperview()
        }

        let contentView = UIStackView()
        contentView.axis = .vertical
        containerView.addArrangedSubview(contentView)

        let inputBar = UIStackView()
        inputBar.axis = .horizontal
        inputBar.alpha = 0

        let padding: CGFloat = 10

        let attachFilePaneIsOpenSignal = ReadWriteSignal(false)
        let attachGIFPaneIsOpenSignal = ReadWriteSignal(false)

        let attachFileButton = AttachFileButton(
            isOpenSignal: attachFilePaneIsOpenSignal.readOnly()
        )

        bag += inputBar.addArranged(attachFileButton.wrappedIn({
            let stackView = UIStackView()
            stackView.alignment = .bottom
            return stackView
        }()).wrappedIn(UIStackView())) { stackView in
            stackView.isHidden = true
            stackView.isLayoutMarginsRelativeArrangement = true
            stackView.layoutMargins = UIEdgeInsets(
                top: padding,
                left: padding,
                bottom: padding,
                right: 0
            )

//            bag += attachGIFPaneIsOpenSignal.animated(style: SpringAnimationStyle.lightBounce()) { isHidden in
//                stackView.isHidden = isHidden
//                stackView.alpha = isHidden ? 0 : 1
//            }
        }.onValue({ _ in
            attachFilePaneIsOpenSignal.value = !attachFilePaneIsOpenSignal.value
            contentView.firstResponder?.resignFirstResponder()
        })

        let attachGIFButton = AttachGIFButton(
            isOpenSignal: attachGIFPaneIsOpenSignal.readOnly()
        )

        bag += inputBar.addArranged(attachGIFButton.wrappedIn({
            let stackView = UIStackView()
            stackView.alignment = .bottom
            return stackView
        }()).wrappedIn(UIStackView())) { stackView in
            stackView.isHidden = true
            stackView.isLayoutMarginsRelativeArrangement = true
            stackView.layoutMargins = UIEdgeInsets(
                top: padding,
                left: 10,
                bottom: padding,
                right: 0
            )

//            bag += attachFilePaneIsOpenSignal.animated(style: SpringAnimationStyle.lightBounce()) { isHidden in
//                stackView.isHidden = isHidden
//                stackView.alpha = isHidden ? 0 : 1
//            }
        }.onValue({ _ in
            attachGIFPaneIsOpenSignal.value = !attachGIFPaneIsOpenSignal.value
            contentView.firstResponder?.resignFirstResponder()
        })

        let currentGlobalIdSignal = currentMessageSignal.map { message in message?.globalId }

        let textView = ChatTextView(currentMessageSignal: currentMessageSignal)
        bag += textView.didBeginEditingSignal.map { false }.bindTo(attachFilePaneIsOpenSignal)
        bag += textView.didBeginEditingSignal.map { false }.bindTo(attachGIFPaneIsOpenSignal)

        bag += inputBar.addArranged(textView.wrappedIn(UIStackView())) { stackView in
            stackView.isLayoutMarginsRelativeArrangement = true
            stackView.layoutMargins = UIEdgeInsets(
                top: padding,
                left: 10,
                bottom: padding,
                right: padding
            )
        }

        contentView.addArrangedSubview(inputBar)
        
        let singleSelectContainer = UIView()
        contentView.addSubview(singleSelectContainer)
        
        singleSelectContainer.snp.makeConstraints { make in
            make.top.bottom.trailing.leading.equalToSuperview()
        }
        
        contentView.bringSubviewToFront(inputBar)

        bag += currentMessageSignal.animated(style: SpringAnimationStyle.lightBounce()) { message in
            guard let message = message else {
                inputBar.alpha = 0
                singleSelectContainer.alpha = 0
                return
            }
            
            switch message.responseType {
            case .none:
                inputBar.alpha = 0
                singleSelectContainer.alpha = 0
            case .text:
                inputBar.alpha = 1
                singleSelectContainer.alpha = 0
                contentView.bringSubviewToFront(inputBar)
                
                singleSelectContainer.subviews.forEach { view in
                    view.removeFromSuperview()
                }
                
            case let .singleSelect(options):
                inputBar.alpha = 0
                singleSelectContainer.alpha = 1
                
                UIView.performWithoutAnimation {
                    let list = SingleSelectList(options: options, currentGlobalIdSignal: currentGlobalIdSignal, navigateCallbacker: self.navigateCallbacker)
                    
                    singleSelectContainer.subviews.forEach { view in
                        view.removeFromSuperview()
                    }
                    
                    bag += singleSelectContainer.add(list) { view in
                        view.snp.makeConstraints { make in
                            make.top.bottom.trailing.leading.equalToSuperview()
                        }
                    }
                }
                
                contentView.bringSubviewToFront(singleSelectContainer)
            }
        }

        bag += containerView.addArranged(AttachFilePane(isOpenSignal: attachFilePaneIsOpenSignal.readOnly()))
        bag += containerView.addArranged(AttachGIFPane(isOpenSignal: attachGIFPaneIsOpenSignal.readOnly()))

        return (backgroundView, bag)
    }
}
