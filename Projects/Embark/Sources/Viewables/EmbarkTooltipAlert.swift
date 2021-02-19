//
//  EmbarkAlert.swift
//  Embark
//
//  Created by Tarik Stafford on 2021-02-05.
//  Copyright © 2021 Hedvig AB. All rights reserved.
//

import Flow
import hCore
import hCoreUI
import Presentation
import UIKit
import hGraphQL

public typealias Tooltip = GraphQL.EmbarkStoryQuery.Data.EmbarkStory.Passage.Tooltip

struct EmbarkTooltipAlert {
    let tooltips: [Tooltip]
}

extension EmbarkTooltipAlert: Presentable {
    public func materialize() -> (UIViewController, Future<Void>)  {
        let containerView = UIStackView()
       
        containerView.layoutMargins = UIEdgeInsets(horizontalInset: 20, verticalInset: 20)
        containerView.isLayoutMarginsRelativeArrangement = true
        containerView.axis = .vertical
        containerView.spacing = 16

        let viewController = UIViewController()
        viewController.view.backgroundColor = .white
        let bag = DisposeBag()

        viewController.view.addSubview(containerView)
        containerView.snp.makeConstraints { (make) in
            make.leading.trailing.top.equalToSuperview()
            make.bottom.lessThanOrEqualToSuperview().inset(viewController.view.safeAreaInsets.bottom)
        }

        viewController.title = L10n.OnboardingEmbarkFlow.informationModalTitle

        bag += containerView.didLayoutSignal.onValue({ (_) in
            viewController.preferredContentSize = containerView.systemLayoutSizeFitting(.zero)
        })

        return (viewController, Future { completion in
            tooltips.forEach { (tooltip) in
                bag += containerView.addArranged(tooltip)
            }

            return bag
        })
    }
}

extension Tooltip: Viewable {
    public func materialize(events: ViewableEvents) -> (UIView, Disposable) {
        let bag = DisposeBag()
        
        let containerView = UIStackView()
        containerView.isLayoutMarginsRelativeArrangement = true
        containerView.axis = .vertical
        containerView.spacing = 10
        
        let titleLabel = UILabel(value: title, style: .brand(.title2(color: .primary)))
        containerView.addArrangedSubview(titleLabel)
        
        let messageLabel = MultilineLabel(value: description, style: .brand(.body(color: .secondary(state: .dynamic))))
        
        bag += containerView.addArranged(messageLabel)
        
        return (containerView, bag)
    }
}
