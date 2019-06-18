//
//  ReferralsMoreInfo.swift
//  UITests
//
//  Created by Sam Pettersson on 2019-06-17.
//

import Foundation
import Flow
import Presentation
import UIKit

struct ReferralsMoreInfo {}

extension ReferralsMoreInfo: Presentable {
    func materialize() -> (UIViewController, Future<Void>) {
        let bag = DisposeBag()
        
        let viewController = UIViewController()
        
        let containerStackView = UIStackView()
        bag += containerStackView.applySafeAreaBottomLayoutMargin()
        
        let containerView = UIStackView()
        containerView.spacing = 15
        containerView.backgroundColor = UIColor.white
        containerView.axis = .vertical
        containerView.layoutMargins = UIEdgeInsets(horizontalInset: 15, verticalInset: 24)
        containerView.isLayoutMarginsRelativeArrangement = true
        
        containerStackView.addArrangedSubview(containerView)
        
        let title = MultilineLabel(value: String(key: .REFERRAL_PROGRESS_MORE_INFO_HEADLINE), style: .standaloneLargeTitle)
        bag += containerView.addArranged(title)
        
        let body = MarkdownText(text: String(key: .REFERRAL_PROGRESS_MORE_INFO_PARAGRAPH(referralValue: "10")), style: .bodyOffBlack)
        bag += containerView.addArranged(body)
        
        let button = Button(title: String(key: .REFERRAL_PROGRESS_MORE_INFO_CTA), type: .standard(backgroundColor: .purple, textColor: .white))
        bag += containerView.addArranged(button.wrappedIn(UIStackView())) { stackView in
            stackView.alignment = .center
            stackView.axis = .vertical
        }
        
        bag += containerStackView.applyPreferredContentSize(on: viewController)
        
        viewController.view = containerStackView
        
        return (viewController, Future { _ in
            bag
        })
    }
}
