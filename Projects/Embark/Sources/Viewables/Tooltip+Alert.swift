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

typealias Tooltip = GraphQL.EmbarkStoryQuery.Data.EmbarkStory.Passage.Tooltip

extension Tooltip: Presentable {
    public func materialize() -> (UIViewController, Future<Void>)  {
        
        let containerView = UIStackView()
        containerView.layoutMargins = UIEdgeInsets(horizontalInset: 32, verticalInset: 20)
        containerView.isLayoutMarginsRelativeArrangement = true
        containerView.axis = .vertical
        
        let viewController = UIViewController()
        viewController.view.backgroundColor = .white
        let bag = DisposeBag()
        
        viewController.view.addSubview(containerView)
        containerView.snp.makeConstraints { (make) in
            make.leading.trailing.top.equalToSuperview()
            make.bottom.equalToSuperview().inset(viewController.view.safeAreaInsets.bottom)
        }
        
        viewController.title = title
        
        bag += containerView.didLayoutSignal.onValue({ (_) in
            viewController.preferredContentSize = containerView.systemLayoutSizeFitting(.zero)
        })
        
        return (viewController, Future { completion in
            
            let messageLabel = MultilineLabel(value: description, style: .brand(.body(color: .secondary(state: .dynamic))))
            bag += containerView.addArranged(messageLabel)
            
            return bag
        })
    }
}
