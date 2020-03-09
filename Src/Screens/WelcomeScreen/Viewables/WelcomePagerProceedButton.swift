//
//  WelcomePagerProceedButton.swift
//  project
//
//  Created by Gustaf Gunér on 2019-06-28.
//

import Flow
import Form
import Foundation
import Space

struct WelcomePagerProceedButton {
    let button: Button
    let onTapSignal: Signal<Void>
    private let onTapReadWriteSignal = ReadWriteSignal<Void>(())

    let pageAmountSignal: ReadWriteSignal<Int> = ReadWriteSignal(0)
    let dataSignal: ReadWriteSignal<WelcomeQuery.Data?> = ReadWriteSignal(nil)
    let onScrolledToPageIndexSignal = ReadWriteSignal<Int>(0)

    init(button: Button) {
        self.button = button
        onTapSignal = onTapReadWriteSignal.plain()
    }
}

extension WelcomePagerProceedButton: Viewable {
    func materialize(events: ViewableEvents) -> (UIButton, Disposable) {
        let bag = DisposeBag()
        let (buttonView, disposable) = button.materialize(events: events)
        buttonView.alpha = 0

        let buttonTitleSignal = ReadWriteSignal<String>("")

        func setButtonStyle(isMorePages: Bool) {
            button.type.value = isMorePages ? ButtonType.standard(backgroundColor: UIColor(dynamic: { trait -> UIColor in
                trait.userInterfaceStyle == .dark ? .primaryTintColor : .blackPurple
            }), textColor: .white) : ButtonType.standard(backgroundColor: .primaryTintColor, textColor: .white)
        }

        func setButtonTitle(isMorePages: Bool) {
            buttonTitleSignal.value = isMorePages ? String(key: .NEW_MEMBER_PROCEED) : String(key: .NEW_MEMBER_DISMISS)
        }

        bag += button.onTapSignal.bindTo(onTapReadWriteSignal)

        bag += buttonTitleSignal
            .distinct()
            .delay(by: 0.25)
            .animated(style: SpringAnimationStyle.lightBounce(duration: 0.15)) { title in
                buttonView.setTitle(title)

                buttonView.snp.remakeConstraints { make in
                    make.width.equalTo(buttonView.intrinsicContentSize.width + self.button.type.value.extraWidthOffset)
                }

                buttonView.layoutIfNeeded()
            }

        bag += pageAmountSignal
            .take(first: 1)
            .onValue { pageAmount in
                let isMorePages = pageAmount > 1

                setButtonTitle(isMorePages: isMorePages)
                setButtonStyle(isMorePages: isMorePages)

                buttonView.alpha = 1
            }

        bag += onScrolledToPageIndexSignal.withLatestFrom(pageAmountSignal).onValue { pageIndex, pageAmount in
            let isMorePages = pageIndex < (pageAmount - 1)

            setButtonTitle(isMorePages: isMorePages)
            setButtonStyle(isMorePages: isMorePages)
        }

        return (buttonView, Disposer {
            disposable.dispose()
            bag.dispose()
        })
    }
}
