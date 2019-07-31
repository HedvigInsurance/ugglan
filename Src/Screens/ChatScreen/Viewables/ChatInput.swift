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

    init(currentMessageSignal: ReadSignal<Message?>) {
        self.currentMessageSignal = currentMessageSignal
    }
}

class ViewWithFixedIntrinsicSize: UIView {
    override var intrinsicContentSize: CGSize {
        return CGSize(width: 300, height: 200)
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
        contentView.axis = .horizontal
        containerView.addArrangedSubview(contentView)

        let padding: CGFloat = 10

        let attachFilePaneIsOpenSignal = ReadWriteSignal(false)
        let attachGIFPaneIsOpenSignal = ReadWriteSignal(false)

        let attachFileButton = AttachFileButton(
            isOpenSignal: attachFilePaneIsOpenSignal.readOnly()
        )

        bag += contentView.addArranged(attachFileButton.wrappedIn({
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

        bag += contentView.addArranged(attachGIFButton.wrappedIn({
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
        
        bag += attachFilePaneIsOpenSignal.filter { $0 }.map { _ in false }.bindTo(attachGIFPaneIsOpenSignal)
        bag += attachGIFPaneIsOpenSignal.filter { $0 }.map { _ in false }.bindTo(attachFilePaneIsOpenSignal)

        let textView = ChatTextView(currentGlobalIdSignal: currentMessageSignal.map { message in message?.globalId })
        bag += textView.didBeginEditingSignal.map { false }.bindTo(attachFilePaneIsOpenSignal)
        bag += textView.didBeginEditingSignal.map { false }.bindTo(attachGIFPaneIsOpenSignal)

        bag += contentView.addArranged(textView.wrappedIn(UIStackView())) { stackView in
            stackView.isLayoutMarginsRelativeArrangement = true
            stackView.layoutMargins = UIEdgeInsets(
                top: padding,
                left: 10,
                bottom: padding,
                right: padding
            )
        }

        bag += containerView.addArranged(AttachFilePane(isOpenSignal: attachFilePaneIsOpenSignal.readOnly()))
        bag += containerView.addArranged(AttachGIFPane(isOpenSignal: attachGIFPaneIsOpenSignal.readOnly()))

        return (backgroundView, bag)
    }
}
