//
//  MyInfo.swift
//  Hedvig
//
//  Created by Sam Pettersson on 2019-01-04.
//  Copyright © 2019 Hedvig AB. All rights reserved.
//

import Apollo
import Flow
import Form
import Presentation
import UIKit

struct MyInfo {
    let client: ApolloClient
    let isEditingSignal = ReadWriteSignal<Bool>(false)

    init(client: ApolloClient = HedvigApolloClient.shared.client!) {
        self.client = client
    }
}

extension MyInfo: Presentable {
    func materialize() -> (UIViewController, Future<Void>) {
        let bag = DisposeBag()

        let viewController = UIViewController()
        viewController.title = String(.MY_INFO_TITLE)

        let form = FormView()

        let saveButton = ActivityBarButton(
            item: UIBarButtonItem(title: "Spara", style: .navigationBarButton),
            position: .right
        )
        bag += saveButton.onValue { _ in
            saveButton.startAnimating()
        }

        let nameCircle = NameCircle()
        bag += form.prepend(nameCircle)

        let contactDetailsSection = ContactDetailsSection(
            isEditingSignal: isEditingSignal,
            shouldSaveSignal: saveButton.toVoid().plain()
        )
        bag += form.append(contactDetailsSection)

        bag += contactDetailsSection.saveResultSignal.onValue { result in
            switch result {
            case .success:
                return
            case let .failure(reason):
                let alert = Alert<Void>(
                    title: String(.MY_INFO_ALERT_SAVE_FAILURE_TITLE),
                    message: reason,
                    actions: [
                        Alert.Action(title: String(.MY_INFO_ALERT_SAVE_FAILURE_BUTTON)) {
                            ()
                        },
                    ]
                )
                viewController.present(alert)
            }
        }

        let cancelButton = UIBarButtonItem(
            title: String(.MY_INFO_CANCEL_BUTTON),
            style: .navigationBarButton
        )

        bag += isEditingSignal.atOnce().filter { $0 }.onValue { _ in
            saveButton.attachTo(viewController.navigationItem)
            viewController.navigationItem.setLeftBarButtonItems([cancelButton], animated: true)
        }

        bag += contactDetailsSection.saveResultSignal.onValue { _ in
            saveButton.remove()
            viewController.navigationItem.setLeftBarButtonItems([], animated: true)
        }

        bag += viewController.install(form)

        return (viewController, Future { completion in
            bag += cancelButton.onValue { _ in
                let alert = Alert<Bool>(
                    title: String(.MY_INFO_CANCEL_ALERT_TITLE),
                    message: String(.MY_INFO_CANCEL_ALERT_MESSAGE),
                    actions: [
                        Alert.Action(title: String(.MY_INFO_CANCEL_ALERT_BUTTON_CONFIRM)) {
                            true
                        },
                        Alert.Action(title: String(.MY_INFO_CANCEL_ALERT_BUTTON_CANCEL)) {
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
