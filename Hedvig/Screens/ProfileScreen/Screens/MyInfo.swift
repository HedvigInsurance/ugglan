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
        viewController.title = String.translation(.MY_INFO_TITLE)

        let form = FormView()
        let section = form.appendSection(
            header: String.translation(.MY_INFO_CONTACT_DETAILS_TITLE),
            footer: nil,
            style: .sectionPlain
        )

        let nameCircleText = DynamicString("Adam Pålsson")

        let nameCircle = CircleLabel(
            text: nameCircleText
        )
        bag += form.prepend(nameCircle) { _, containerView in
            containerView.snp.makeConstraints({ make in
                make.height.equalTo(200)
            })
        }

        let nameTextField = UITextField(
            value: "Adam Pålsson",
            placeholder: "Namn",
            style: .default
        )
        nameTextField.isUserInteractionEnabled = true
        nameTextField.textAlignment = .right
        bag += viewController.registerForPreviewing(sourceView: nameTextField, presentable: MyInfo())

        bag += nameTextField.bindTo(nameCircleText)

        let nameRow = RowView().prepend("Namn").append(nameTextField)

        section.append(nameRow)

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
            bag += scrollView.chainAllControlResponders(shouldLoop: false, returnKey: .next)
        }

        return (viewController, Future { completion in
            bag += button.onTapSignal.onValue {
                completion(.success)
            }

            return DelayedDisposer(bag, delay: 1)
        })
    }
}
