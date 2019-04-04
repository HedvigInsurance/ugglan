//
//  CharityInformation.swift
//  ugglan
//
//  Created by Gustaf Gunér on 2019-03-28.
//

import Apollo
import Flow
import Form
import Presentation
import UIKit
import MarkdownKit

struct CharityInformation {}

extension CharityInformation: Presentable {
    func materialize() -> (UIViewController, Disposable) {
        let bag = DisposeBag()
        
        let viewController = UIViewController()
        
        let containerView = UIView()
        containerView.backgroundColor = UIColor.white
        
        let header = DraggableViewHeader(title: String(.PROFILE_MY_CHARITY_INFO_TITLE))
        bag += containerView.add(header)
        
        let bodyView = UIView()
        containerView.addSubview(bodyView)
        
        bodyView.snp.remakeConstraints { make in
            make.top.equalTo(60)
            make.width.equalToSuperview()
        }
        
        let markdownParser = MarkdownParser()
        
        let body = UILabel()
        body.numberOfLines = 0
        body.lineBreakMode = .byWordWrapping
        body.attributedText = markdownParser.parse(String(.PROFILE_MY_CHARITY_INFO_BODY))
        
        bag += body.didLayoutSignal.onValue { _ in
            body.snp.remakeConstraints { make in
                make.width.equalToSuperview().inset(24)
                make.height.equalToSuperview().inset(24)
                make.center.equalToSuperview()
            }
        }
        
        bodyView.addSubview(body)
        
        viewController.view = containerView;
        
        return (viewController, bag)
    }
}

