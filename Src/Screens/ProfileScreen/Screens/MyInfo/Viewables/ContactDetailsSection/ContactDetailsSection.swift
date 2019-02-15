//
//  ContactDetailsSection.swift
//  Hedvig
//
//  Created by Sam Pettersson on 2019-01-14.
//  Copyright © 2019 Hedvig AB. All rights reserved.
//

import Flow
import Form
import Foundation

struct ContactDetailsSection {
    let isEditingSignal: ReadWriteSignal<Bool>
    let shouldSaveSignal: Signal<Void>
    let saveResultSignal: Signal<SaveResult>
    private let saveResultCallbacker = Callbacker<SaveResult>()

    init(
        isEditingSignal: ReadWriteSignal<Bool>,
        shouldSaveSignal: Signal<Void>
    ) {
        self.isEditingSignal = isEditingSignal
        self.shouldSaveSignal = shouldSaveSignal
        saveResultSignal = saveResultCallbacker.signal()
    }
}

enum SaveResult {
    case success, failure(reason: String)
}

extension ContactDetailsSection: Viewable {
    func materialize(events _: ViewableEvents) -> (SectionView, Disposable) {
        let bag = DisposeBag()

        let section = SectionView(
            header: String(.MY_INFO_CONTACT_DETAILS_TITLE),
            footer: nil,
            style: .sectionPlain
        )

        let phoneNumberRow = PhoneNumberRow(
            isEditingSignal: isEditingSignal,
            shouldSaveSignal: shouldSaveSignal
        )
        bag += section.append(phoneNumberRow)

        let emailRow = EmailRow(
            isEditingSignal: isEditingSignal,
            shouldSaveSignal: shouldSaveSignal
        )

        bag += isEditingSignal.filter { $0 }.onValueDisposePrevious { _ -> Disposable? in
            return join(
                emailRow.saveResultSignal.future,
                phoneNumberRow.saveResultSignal.future
            ).onValue { emailResult, phoneResult in
                switch emailResult {
                case .failure:
                    self.saveResultCallbacker.callAll(with: emailResult)
                    return
                case .success:
                    break
                }

                self.saveResultCallbacker.callAll(with: phoneResult)
            }.disposable
        }

        bag += section.append(emailRow)

        return (section, bag)
    }
}
