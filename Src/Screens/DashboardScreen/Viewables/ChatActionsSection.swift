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
}

extension ChatActionsSection: Viewable {
    func materialize(events _: ViewableEvents) -> (UIView, Disposable) {
        let bag = DisposeBag()
        
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.edgeInsets = UIEdgeInsets(
            top: 0,
            left: 16,
            bottom: 0,
            right: 0
        )
        
        let headerLabel = MultilineLabel(styledText: StyledText(
            text: "Vad vill du göra idag?",
            style: .boldSmallTitle
            )
        )
        bag += stackView.addArranged(headerLabel)
        
        let scrollViewContainer = UIView()
        stackView.addArrangedSubview(scrollViewContainer)
        
        let horizontalScrollView = UIScrollView()
        scrollViewContainer.addSubview(horizontalScrollView)
        
        horizontalScrollView.snp.makeConstraints { make in
            make.top.bottom.leading.trailing.equalToSuperview()
            make.width.equalToSuperview()
        }
        
        let buttonStackView = UIStackView()
        buttonStackView.axis = .horizontal
        buttonStackView.spacing = 20
        horizontalScrollView.addSubview(buttonStackView)
        
        buttonStackView.snp.makeConstraints { make in
            make.leading.trailing.top.bottom.equalToSuperview()
            make.height.equalToSuperview()
        }
        
        bag += dataSignal.atOnce().compactMap {
                $0?.compactMap {
                    Button(title: $0?.text ?? "", type: .standard(backgroundColor: .purple, textColor: .white))
                }
            }.onValue { buttons in
                for button in buttons {
                    bag += buttonStackView.addArranged(button) { buttonView in
                        buttonView.snp.makeConstraints({ (make) in
                            make.width.equalTo(60)
                        })
                    }
                }
                print(buttonStackView.arrangedSubviews)
            }
        
        
        return (stackView, bag)
    }
}
