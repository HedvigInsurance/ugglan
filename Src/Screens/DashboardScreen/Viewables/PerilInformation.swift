//
//  PerilInformation.swift
//  ugglan
//
//  Created by Axel Backlund on 2019-04-15.
//

import Apollo
import Flow
import Form
import Presentation
import UIKit

struct PerilInformation {
    let description: String
    let title: String
    let icon: ImageAsset

    init(title: String, description: String, icon: ImageAsset) {
        self.title = title
        self.description = description
        self.icon = icon
    }
}

extension PerilInformation: Presentable {
    func materialize() -> (UIViewController, Future<Void>) {
        let bag = DisposeBag()

        let viewController = UIViewController()
        viewController.preferredContentSize = CGSize(width: 0, height: 0)

        let containerView = UIStackView()
        containerView.layoutMargins = UIEdgeInsets(horizontalInset: 15, verticalInset: 24)
        containerView.isLayoutMarginsRelativeArrangement = true
        containerView.spacing = 15
        containerView.backgroundColor = UIColor.white
        containerView.axis = .vertical
        containerView.alignment = .top
        
        if #available(iOS 11.0, *) {
            containerView.insetsLayoutMarginsFromSafeArea = false
        }

        let icon = Icon(icon: self.icon, iconWidth: 60)
        containerView.addArrangedSubview(icon)

        icon.snp.makeConstraints { make in
            make.width.equalTo(60)
            make.height.equalTo(60)
        }

        let titleLabel = UILabel()
        titleLabel.style = .standaloneLargeTitle
        titleLabel.textAlignment = .left

        bag += titleLabel.setDynamicText(DynamicString(title))

        containerView.addArrangedSubview(titleLabel)

        let body = MarkdownText(text: description, style: .bodyOffBlack)
        bag += containerView.addArranged(body)
        
//        bag += containerView.didLayoutSignal.take(first: 1).onValue { _ in
//            var height: CGFloat = 0
//            for subview in containerView.subviews {
//                height += subview.intrinsicContentSize.height
//
//                if subview != containerView.subviews.last! {
//                    height += containerView.spacing
//                }
//            }
//
//            height += containerView.layoutMargins.top + containerView.layoutMargins.bottom
//
//            if #available(iOS 11.0, *) {
//                height += containerView.safeAreaInsets.bottom
//            }
//
//            viewController.preferredContentSize = CGSize(width: 0, height: height)
//        }
        
        bag += viewController.install(containerView) { scrollView in
            bag += scrollView.didLayoutSignal.onValue({ _ in
                print(scrollView.contentSize)
            })
        }

        viewController.view = containerView

        return (viewController, Future { _ in
            bag
        })
    }
}
