//
//  MyInfoState.swift
//  ugglan
//
//  Created by Sam Pettersson on 2019-02-16.
//

import Apollo
import Flow
import Foundation
import Presentation
import UIKit
import hCore

struct MyInfoState {
    @Inject private var client: ApolloClient
    @Inject private var store: ApolloStore

    let presentingViewController: UIViewController

    let isEditingSignal = ReadWriteSignal<Bool>(false)
    let isSavingSignal = ReadWriteSignal<Bool>(false)

    let emailSignal = ReadWriteSignal<String>("")
    let phoneNumberSignal = ReadWriteSignal<String>("")

    let emailInputPristineSignal = ReadWriteSignal<Bool>(true)
    let emailInputValueSignal = ReadWriteSignal<String>("")
    let phoneNumberInputPristineSignal = ReadWriteSignal<Bool>(true)
    let phoneNumberInputValueSignal = ReadWriteSignal<String>("")

    private let onSaveCallbacker = Callbacker<Flow.Result<Void>>()
    let onSaveSignal: Signal<Flow.Result<Void>>

    func save() -> Disposable {
        let bag = DisposeBag()

        isSavingSignal.value = true

        let phoneNumberFuture = phoneNumberInputValueSignal
            .atOnce()
            .withLatestFrom(phoneNumberInputPristineSignal)
            .mapLatestToFuture { phoneNumber, isPristine in
                Future<Void> { completion in
                    if isPristine {
                        completion(.success)
                        return NilDisposer()
                    }

                    if phoneNumber.count == 0 {
                        completion(.failure(MyInfoSaveError.phoneNumberEmpty))
                        return NilDisposer()
                    }

                    let innerBag = bag.innerBag()

                    innerBag += self.client.perform(
                        mutation: UpdatePhoneNumberMutation(phoneNumber: phoneNumber)
                    ).onValue { result in
                        if result.errors?.count != nil {
                            completion(.failure(MyInfoSaveError.phoneNumberMalformed))
                            return
                        }

                        completion(.success)
                    }

                    return innerBag
                }
            }.future

        let emailFuture = emailInputValueSignal
            .atOnce()
            .withLatestFrom(emailInputPristineSignal)
            .mapLatestToFuture { email, isPristine in
                Future<Void> { completion in
                    if isPristine {
                        completion(.success)
                        return NilDisposer()
                    }

                    if email.count == 0 {
                        completion(.failure(MyInfoSaveError.emailEmpty))
                        return NilDisposer()
                    }

                    let innerBag = bag.innerBag()

                    innerBag += self.client.perform(mutation: UpdateEmailMutation(email: email)).onValue { result in
                        if result.errors?.count != nil {
                            completion(.failure(MyInfoSaveError.emailMalformed))
                            return
                        }

                        completion(.success)

                        self.store.update(query: MyInfoQuery()) { (data: inout MyInfoQuery.Data) in
                            data.member.email = email
                        }
                    }

                    return innerBag
                }
            }.future

        join(phoneNumberFuture, emailFuture).onValue { _, _ in
            self.onSaveCallbacker.callAll(with: .success)
        }.onError { error in
            self.onSaveCallbacker.callAll(with: .failure(error))
            let alert = Alert<Void>(
                title: L10n.myInfoAlertSaveFailureTitle,
                message: error.localizedDescription,
                actions: [
                    Alert.Action(title: L10n.myInfoAlertSaveFailureButton) {
                        ()
                    },
                ]
            )
            self.presentingViewController.present(alert)
        }.onResult { _ in
            self.isSavingSignal.value = false
        }

        return bag
    }

    func loadData() -> Disposable {
        let bag = DisposeBag()

        let dataSignal = client.watch(
            query: MyInfoQuery(),
            cachePolicy: .returnCacheDataAndFetch
        )

        bag += dataSignal.compactMap { $0.data?.member.email }.bindTo(emailSignal)
        bag += dataSignal.compactMap { $0.data?.member.phoneNumber }.bindTo(phoneNumberSignal)

        return bag
    }

    init(
        presentingViewController: UIViewController
    ) {
        self.presentingViewController = presentingViewController
        onSaveSignal = onSaveCallbacker.signal()
    }
}
