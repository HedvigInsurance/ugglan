//
//  PhoneNumberRow.swift
//  Hedvig
//
//  Created by Sam Pettersson on 2019-01-14.
//  Copyright © 2019 Hedvig AB. All rights reserved.
//

import Apollo
import Flow
import Form
import Foundation

struct PhoneNumberRow {
    let client: ApolloClient
    let store: ApolloStore
    let isEditingSignal: ReadWriteSignal<Bool>
    let shouldSaveSignal: Signal<Void>
    let saveResultSignal: Signal<SaveResult>
    private let saveResultCallbacker = Callbacker<SaveResult>()

    init(
        isEditingSignal: ReadWriteSignal<Bool>,
        shouldSaveSignal: Signal<Void>,
        client: ApolloClient = HedvigApolloClient.shared.client!,
        store: ApolloStore = HedvigApolloClient.shared.store!
    ) {
        saveResultSignal = saveResultCallbacker.signal()
        self.isEditingSignal = isEditingSignal
        self.shouldSaveSignal = shouldSaveSignal
        self.client = client
        self.store = store
    }
}

extension PhoneNumberRow: Viewable {
    func materialize(events _: ViewableEvents) -> (RowView, Disposable) {
        let bag = DisposeBag()
        let row = RowView(title: String(.PHONE_NUMBER_ROW_TITLE), style: .rowTitle)

        let valueTextField = UITextField()
        valueTextField.textAlignment = .right
        valueTextField.autocorrectionType = .no
        valueTextField.autocapitalizationType = .none
        valueTextField.keyboardType = .phonePad

        row.append(valueTextField)

        bag += valueTextField.isEditingSignal.bindTo(isEditingSignal)

        bag += shouldSaveSignal.withLatestFrom(valueTextField.plain()).onValue { _, phoneNumber in
            if phoneNumber.count == 0 {
                self.saveResultCallbacker.callAll(with: .failure(
                    reason: String(.MY_INFO_PHONE_NUMBER_EMPTY_ERROR)
                ))
                return
            }

            bag += self.client.perform(
                mutation: UpdatePhoneNumberMutation(phoneNumber: phoneNumber)
            ).onValue({ result in
                if result.errors?.count != nil {
                    self.saveResultCallbacker.callAll(with: .failure(
                        reason: String(.MY_INFO_PHONE_NUMBER_MALFORMED_ERROR
                    )))
                    return
                }

                self.saveResultCallbacker.callAll(with: .success)
                valueTextField.endEditing(true)

                self.store.update(query: MyInfoQuery()) { (data: inout MyInfoQuery.Data) in
                    data.member.phoneNumber = phoneNumber
                }
            })
        }

        bag += client.fetch(
            query: MyInfoQuery(),
            cachePolicy: .returnCacheDataAndFetch
        ).valueSignal.compactMap { $0.data?.member.phoneNumber }.map { phoneNumber in
            StyledText(text: phoneNumber, style: .rowTitle)
        }.bindTo(valueTextField, \.styledText)

        return (row, bag)
    }
}
