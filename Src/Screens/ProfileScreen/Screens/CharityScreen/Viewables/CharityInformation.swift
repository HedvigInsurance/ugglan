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

struct CharityInformation {}

extension CharityInformation: Presentable {
    func materialize() -> (UIViewController, Disposable) {
        let bag = DisposeBag()
        
        let viewController = UIViewController()
        
        let containerView = UIView()
        containerView.backgroundColor = UIColor.white
        
        let header = DraggableOverlayHeader(title: String(key: .PROFILE_MY_CHARITY_INFO_TITLE))
        bag += containerView.add(header)
        
        let bodyView = UIView()
        containerView.addSubview(bodyView)
        
        bodyView.snp.remakeConstraints { make in
            make.top.equalTo(56 + 8)
            make.width.equalToSuperview()
            make.height.equalToSuperview().offset(56 + 8)
        }
        
        let body = CharityInformationBody(text: String(key: .PROFILE_MY_CHARITY_INFO_BODY))
        
        bag += bodyView.add(body)
        
        viewController.view = containerView;
        
        return (viewController, bag)
    }
}

