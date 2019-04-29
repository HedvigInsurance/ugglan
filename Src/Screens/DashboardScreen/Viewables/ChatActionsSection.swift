//
//  ChatActionsSection.swift
//  ugglan
//
//  Created by Axel Backlund on 2019-04-10.
//

import Flow
import Form
import Foundation
import UIKit

struct ChatActionsSection {
    let dataSignal: ReadWriteSignal<[ChatActionsQuery.Data.ChatAction?]?> = ReadWriteSignal(nil)
    let presentingViewController: UIViewController
}

extension ChatActionsSection: Viewable {
    func materialize(events _: ViewableEvents) -> (UIView, Disposable) {
        let bag = DisposeBag()

        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 16

        let headerLabelContainer = UIStackView()
        headerLabelContainer.edgeInsets = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        let headerLabel = MultilineLabel(
            styledText: StyledText(
                text: String(key: .DASHBOARD_CHAT_ACTIONS_HEADER),
                style: .boldSmallTitle
            )
        )
        bag += headerLabelContainer.addArranged(headerLabel)
        stackView.addArrangedSubview(headerLabelContainer)

        bag += dataSignal.atOnce().map { $0 == nil }.bindTo(headerLabelContainer, \.isHidden)

        let scrollView = UIScrollView()
        scrollView.contentInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.showsVerticalScrollIndicator = false

        let buttonStackView = UIStackView()
        buttonStackView.axis = .horizontal
        buttonStackView.spacing = 10

        scrollView.embedView(buttonStackView, scrollAxis: .horizontal)

        bag += dataSignal.atOnce()
            .compactMap { $0?.filter { $0?.enabled == true } }
            .onValue { chatActions in

                buttonStackView.subviews.forEach { view in
                    view.removeFromSuperview()
                }

                for chatAction in chatActions {
                    let buttonContainer = UIView()
                    let button = Button(title: chatAction?.text ?? "", type: .standard(backgroundColor: .purple, textColor: .white))
                    bag += button.onTapSignal.filter { chatAction?.triggerUrl != nil }.onValue {
                        DashboardRouting.openChat(viewController: self.presentingViewController, chatActionUrl: chatAction?.triggerUrl ?? "")
                    }
                    bag += buttonContainer.add(button) { button in
                        button.snp.makeConstraints { make in
                            make.height.width.centerX.centerY.equalToSuperview()
                        }
                    }

                    buttonStackView.addArrangedSubview(buttonContainer)
                }
            }

        stackView.addArrangedSubview(scrollView)

        return (stackView, bag)
    }
}
