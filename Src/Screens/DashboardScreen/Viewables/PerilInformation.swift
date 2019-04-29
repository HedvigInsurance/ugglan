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

        let containerView = UIView()
        containerView.backgroundColor = UIColor.white

        let icon = Icon(icon: self.icon, iconWidth: 60)
        containerView.addSubview(icon)

        icon.snp.makeConstraints { make in
            make.width.equalTo(60)
            make.height.equalTo(60)
            make.leading.equalToSuperview().inset(24)
            make.top.equalToSuperview().inset(24)
        }

        let titleLabel = UILabel()
        titleLabel.style = .standaloneLargeTitle
        titleLabel.textAlignment = .left

        bag += titleLabel.setDynamicText(DynamicString(title))

        let titleContainer = UIView()
        titleContainer.addSubview(titleLabel)

        titleLabel.snp.remakeConstraints { make in
            make.width.equalToSuperview().inset(24)
            make.top.equalToSuperview().inset(24 + 60 + 12)
            make.height.equalTo(32)
            make.centerX.equalToSuperview()
        }

        containerView.addSubview(titleContainer)

        titleContainer.snp.makeConstraints { make in
            make.width.equalToSuperview()
            make.height.equalToSuperview()
        }

        let bodyView = UIView()
        containerView.addSubview(bodyView)

        let body = CharityInformationBody(text: description)
        bag += bodyView.add(body) { bodyText in
            bodyText.snp.makeConstraints { make in
                make.height.equalTo(bodyText.intrinsicContentSize.height)
                make.top.bottom.trailing.leading.equalToSuperview()
            }
        }

        bodyView.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(24 + 60 + 12 + 32 + 8)
            make.width.equalToSuperview()
            make.height.equalTo(bodyView.intrinsicContentSize.height)
        }

        viewController.view = containerView

        return (viewController, Future { _ in
            return bag
        })
    }
}
