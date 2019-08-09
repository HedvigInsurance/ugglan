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
        backgroundView.backgroundColor = UIColor.offWhite.withAlphaComponent(0.8)

        let effect = UIBlurEffect(style: .light)
        let effectView = UIVisualEffectView(effect: effect)
        backgroundView.addSubview(effectView)

        effectView.snp.makeConstraints { make in
            make.width.height.leading.trailing.equalToSuperview()
        }

        let topBorderView = UIView()
        topBorderView.backgroundColor = .lightGray
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
        contentView.addArrangedSubview(inputBar)

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
            stackView.isLayoutMarginsRelativeArrangement = true
            stackView.layoutMargins = UIEdgeInsets(
                top: padding,
                left: padding,
                bottom: padding,
                right: 0
            )

            bag += attachGIFPaneIsOpenSignal.animated(style: SpringAnimationStyle.lightBounce()) { isHidden in
                stackView.isHidden = isHidden
                stackView.alpha = isHidden ? 0 : 1
            }
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
            stackView.isLayoutMarginsRelativeArrangement = true
            stackView.layoutMargins = UIEdgeInsets(
                top: padding,
                left: 10,
                bottom: padding,
                right: 0
            )

            bag += attachFilePaneIsOpenSignal.animated(style: SpringAnimationStyle.lightBounce()) { isHidden in
                stackView.isHidden = isHidden
                stackView.alpha = isHidden ? 0 : 1
            }
        }.onValue({ _ in
            attachGIFPaneIsOpenSignal.value = !attachGIFPaneIsOpenSignal.value
            contentView.firstResponder?.resignFirstResponder()
        })

        let currentGlobalIdSignal = currentMessageSignal.map { message in message?.globalId }

        let textView = ChatTextView(currentGlobalIdSignal: currentGlobalIdSignal)
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

        let optionsSignal = ReadWriteSignal<[SingleSelectOption]>([])

        let singleSelectListContainer = UIStackView()
        containerView.addArrangedSubview(singleSelectListContainer)

        let singleSelectList = SingleSelectList(
            optionsSignal: optionsSignal.readOnly(),
            currentGlobalIdSignal: currentGlobalIdSignal,
            navigateCallbacker: navigateCallbacker
        )
        bag += singleSelectListContainer.addArranged(singleSelectList)

        bag += currentMessageSignal.compactMap { $0 }.animated(style: SpringAnimationStyle.lightBounce()) { message in
            switch message.responseType {
            case .text:
                optionsSignal.value = []
                singleSelectListContainer.animationSafeIsHidden = true
                inputBar.transform = CGAffineTransform(translationX: 0, y: 0)
            case let .singleSelect(options):
                optionsSignal.value = options
                singleSelectListContainer.animationSafeIsHidden = false
                inputBar.transform = CGAffineTransform(translationX: 0, y: 200)
            }
        }

        bag += containerView.addArranged(AttachFilePane(isOpenSignal: attachFilePaneIsOpenSignal.readOnly()))
        bag += containerView.addArranged(AttachGIFPane(isOpenSignal: attachGIFPaneIsOpenSignal.readOnly()))

        return (backgroundView, bag)
    }
}
