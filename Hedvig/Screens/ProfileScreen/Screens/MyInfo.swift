//
//  MyInfo.swift
//  Hedvig
//
//  Created by Sam Pettersson on 2019-01-04.
//  Copyright © 2019 Hedvig AB. All rights reserved.
//

import Flow
import Form
import Presentation
import UIKit

struct MyInfo {}

extension MyInfo: Presentable {
    func materialize() -> (UIViewController, Future<Void>) {
        let bag = DisposeBag()

        let viewController = UIViewController()
        viewController.displayableTitle = "Min info"

        if #available(iOS 11.0, *) {
            viewController.navigationItem.largeTitleDisplayMode = .never
        }

        let view = UIView()
        view.backgroundColor = UIColor.black

        let form = FormView()
        let section = form.appendSection(header: nil, footer: nil, style: .default)

        let myInfoRow = MyInfoRow(
            presentingViewController: viewController
        )

        bag += section.append(myInfoRow)
        bag += section.append(myInfoRow)

        let button = Button(
            title: "Gå tillbaka",
            type: .standard(
                backgroundColor: .purple,
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

        return (viewController, Future { completion in
            bag += button.onTapSignal.onValue {
                completion(.success)
            }

            return DelayedDisposer(bag, delay: 1)
        })
    }
}
