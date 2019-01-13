//
//  Profile.swift
//  Hedvig
//
//  Created by Sam Pettersson on 2019-01-02.
//  Copyright © 2019 Hedvig AB. All rights reserved.
//

import Flow
import Form
import Presentation
import UIKit

struct Profile {}

extension Profile: Presentable {
    func materialize() -> (UIViewController, Disposable) {
        let bag = DisposeBag()

        let viewController = UIViewController()
        viewController.displayableTitle = "Profil"

        let view = UIView()
        view.backgroundColor = UIColor.black

        let form = FormView()
        let section = form.appendSection(header: nil, footer: nil, style: .sectionPlain)

        let myInfoRow = MyInfoRow(
            presentingViewController: viewController
        )

        bag += section.append(myInfoRow) { rowAndProvider in
            bag += viewController.registerForPreviewing(
                sourceView: rowAndProvider.row,
                presentable: MyInfo()
            )
        }
        bag += section.append(myInfoRow) { rowAndProvider in
            bag += viewController.registerForPreviewing(
                sourceView: rowAndProvider.row,
                presentable: MyInfo()
            )
        }

        let button = Button(
            title: "I am a button",
            type: .standard(
                backgroundColor: .green,
                textColor: .white
            )
        )

        bag += form.append(button) { _, containerView in
            containerView.snp.makeConstraints({ make in
                make.height.equalTo(button.type.height())
            })
        }

        bag += viewController.install(form) { scrollView in
            bag += scrollView.chainAllControlResponders(shouldLoop: true, returnKey: .next)
        }

        return (viewController, bag)
    }
}
