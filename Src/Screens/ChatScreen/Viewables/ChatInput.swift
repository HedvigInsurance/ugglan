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
import ComponentKit

struct ChatInput {
    let chatState: ChatState
    let navigateCallbacker: Callbacker<NavigationEvent>

    init(
        chatState: ChatState,
        navigateCallbacker: Callbacker<NavigationEvent>
    ) {
        self.chatState = chatState
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

            bag += combineLatest(
                chatState.currentMessageSignal,
                attachGIFPaneIsOpenSignal
            ).animated(style: SpringAnimationStyle.lightBounce()) { currentMessage, attachGIFPaneIsOpen in

                var isHidden: Bool

                if attachGIFPaneIsOpen {
                    isHidden = true
                } else if currentMessage?.richTextCompatible == true {
                    isHidden = false
                } else {
                    isHidden = true
                }

                stackView.animationSafeIsHidden = isHidden
                stackView.alpha = isHidden ? 0 : 1
            }
        }.onValue { _ in
            attachFilePaneIsOpenSignal.value = !attachFilePaneIsOpenSignal.value
            contentView.firstResponder?.resignFirstResponder()
        }

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

            bag += combineLatest(
                chatState.currentMessageSignal,
                attachFilePaneIsOpenSignal
            ).animated(style: SpringAnimationStyle.lightBounce()) { currentMessage, attachFilePaneIsOpen in

                var isHidden: Bool

                if attachFilePaneIsOpen {
                    isHidden = true
                } else if currentMessage?.richTextCompatible == true {
                    isHidden = false
                } else {
                    isHidden = true
                }

                stackView.animationSafeIsHidden = isHidden
                stackView.alpha = isHidden ? 0 : 1
            }
        }.onValue { _ in
            attachGIFPaneIsOpenSignal.value = !attachGIFPaneIsOpenSignal.value
            contentView.firstResponder?.resignFirstResponder()
        }

        let textView = ChatTextView(chatState: chatState)
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

            bag += attachGIFPaneIsOpenSignal.animated(style: SpringAnimationStyle.lightBounce()) { attachGifPaneIsOpen in
                var isHidden: Bool

                if attachGifPaneIsOpen {
                    isHidden = true
                } else {
                    isHidden = false
                }
                stackView.alpha = isHidden ? 0 : 1
            }
        }

        contentView.addArrangedSubview(inputBar)

        let singleSelectContainer = UIView()
        contentView.addSubview(singleSelectContainer)

        singleSelectContainer.snp.makeConstraints { make in
            make.top.bottom.trailing.leading.equalToSuperview()
        }

        let audioContainer = UIView()
        contentView.addSubview(audioContainer)

        audioContainer.snp.makeConstraints { make in
            make.top.bottom.trailing.leading.equalToSuperview()
        }

        contentView.bringSubviewToFront(inputBar)

        bag += chatState.currentMessageSignal.animated(style: SpringAnimationStyle.lightBounce()) { message in
            guard let message = message else {
                inputBar.alpha = 0
                singleSelectContainer.alpha = 0
                audioContainer.alpha = 0
                return
            }

            switch message.responseType {
            case .none:
                inputBar.alpha = 0
                singleSelectContainer.alpha = 0
                audioContainer.alpha = 0
            case .text:
                inputBar.alpha = 1
                singleSelectContainer.alpha = 0
                audioContainer.alpha = 0
                contentView.bringSubviewToFront(inputBar)

                singleSelectContainer.subviews.forEach { view in
                    view.removeFromSuperview()
                }
            case let .singleSelect(options):
                inputBar.alpha = 0
                singleSelectContainer.alpha = 1
                audioContainer.alpha = 0

                UIView.performWithoutAnimation {
                    let list = SingleSelectList(
                        options: options,
                        chatState: self.chatState,
                        navigateCallbacker: self.navigateCallbacker
                    )

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
            case .audio:
                inputBar.alpha = 0
                singleSelectContainer.alpha = 0
                audioContainer.alpha = 1

                UIView.performWithoutAnimation {
                    let audioRecorder = AudioRecorder(chatState: self.chatState)

                    audioContainer.subviews.forEach { view in
                        view.removeFromSuperview()
                    }

                    bag += audioContainer.add(audioRecorder) { view in
                        view.snp.makeConstraints { make in
                            make.top.bottom.trailing.leading.equalToSuperview()
                        }
                    }
                }
            }
        }

        bag += containerView.addArranged(
            AttachFilePane(
                isOpenSignal: attachFilePaneIsOpenSignal,
                chatState: chatState
            )
        )
        bag += containerView.addArranged(
            AttachGIFPane(
                isOpenSignal: attachGIFPaneIsOpenSignal,
                chatState: chatState
            )
        )

        return (backgroundView, bag)
    }
}
