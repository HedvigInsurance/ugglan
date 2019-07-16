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
        viewController.title = String(key: .MY_INFO_TITLE)

        let state = MyInfoState(presentingViewController: viewController)
        bag += state.loadData()

        let form = FormView()

        let saveButton = ActivityBarButton(
            item: UIBarButtonItem(title: String(key: .MY_INFO_SAVE_BUTTON), style: .navigationBarButtonPrimary),
            position: .right
        )
        bag += saveButton.onValue { _ in
            bag += state.save()
        }

        bag += state.isSavingSignal.filter { $0 }.onValue { _ in
            saveButton.startAnimating()
        }

        let nameCircle = NameCircle()
        bag += form.prepend(nameCircle)

        let contactDetailsSection = ContactDetailsSection(
            state: state
        )
        bag += form.append(contactDetailsSection)

        let cancelButton = UIBarButtonItem(
            title: String(key: .MY_INFO_CANCEL_BUTTON),
            style: .navigationBarButton
        )

        bag += state.isEditingSignal.atOnce().filter { $0 }.onValue { _ in
            saveButton.attachTo(viewController.navigationItem)
            viewController.navigationItem.setLeftBarButtonItems([cancelButton], animated: true)
        }

        bag += state.onSaveSignal.onValue { result in
            if result.isSuccess() {
                saveButton.remove()
                viewController.navigationItem.setLeftBarButtonItems([], animated: true)
                
                UIApplication.shared.appDelegate.createToast(
                    symbol: .character(Character(String(key: .PROFILE_MY_INFO_SAVE_SUCCESS_TOAST_SYMBOL))),
                    body: String(key: .PROFILE_MY_INFO_SAVE_SUCCESS_TOAST_BODY)
                )
            } else {
                saveButton.stopAnimating()
            }
        }

        bag += viewController.install(form)

        return (viewController, Future { completion in
            bag += cancelButton.onValue { _ in
                let alert = Alert<Bool>(
                    title: String(key: .MY_INFO_CANCEL_ALERT_TITLE),
                    message: String(key: .MY_INFO_CANCEL_ALERT_MESSAGE),
                    actions: [
                        Alert.Action(title: String(key: .MY_INFO_CANCEL_ALERT_BUTTON_CONFIRM)) {
                            true
                        },
                        Alert.Action(title: String(key: .MY_INFO_CANCEL_ALERT_BUTTON_CANCEL)) {
                            false
                        },
                    ]
                )
                bag += viewController.present(alert).onValue { shouldContinue in
                    if shouldContinue {
                        completion(.success)
                    }
                }
            }

            return DelayedDisposer(bag, delay: 2)
        })
    }
}
