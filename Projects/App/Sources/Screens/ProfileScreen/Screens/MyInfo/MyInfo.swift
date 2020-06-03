//
//  MyInfo.swift
//  Hedvig
//
//  Created by Sam Pettersson on 2019-01-04.
//  Copyright © 2019 Hedvig AB. All rights reserved.
//

import Flow
import Form
import hCore
import Presentation
import UIKit

struct MyInfo {}

extension MyInfo: Presentable {
    func materialize() -> (UIViewController, Future<Void>) {
        let bag = DisposeBag()

        let viewController = UIViewController()
        viewController.title = L10n.myInfoTitle

        let state = MyInfoState(presentingViewController: viewController)
        bag += state.loadData()

        let form = FormView()

        let saveButton = ActivityBarButton(
            item: UIBarButtonItem(title: L10n.myInfoSaveButton, style: .navigationBarButtonPrimary),
            position: .right
        )
        bag += saveButton.onValue { _ in
            bag += state.save()
        }

        bag += state.isSavingSignal.filter { $0 }.onValue { _ in
            saveButton.startAnimating()
        }

        let contactDetailsSection = ContactDetailsSection(
            state: state
        )
        bag += form.append(contactDetailsSection)

        let cancelButton = UIBarButtonItem(
            title: L10n.myInfoCancelButton,
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

                UIApplication.shared.appDelegate.displayToast(Toast(
                    symbol: .character(Character(L10n.profileMyInfoSaveSuccessToastSymbol)),
                    body: L10n.profileMyInfoSaveSuccessToastBody
                )).onValue { _ in }
            } else {
                saveButton.stopAnimating()
            }
        }

        bag += viewController.install(form)

        return (viewController, Future { completion in
            bag += cancelButton.onValue { _ in
                let alert = Alert<Bool>(
                    title: L10n.myInfoCancelAlertTitle,
                    message: L10n.myInfoCancelAlertMessage,
                    actions: [
                        Alert.Action(title: L10n.myInfoCancelAlertButtonConfirm) {
                            true
                        },
                        Alert.Action(title: L10n.myInfoCancelAlertButtonCancel) {
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
