import Flow
import Form
import Foundation
import hCore
import hCoreUI
import hGraphQL
import UIKit

struct WelcomePagerProceedButton {
    let button: Button
    let onTapSignal: Signal<Void>
    private let onTapReadWriteSignal = ReadWriteSignal<Void>(())

    let pageAmountSignal: ReadWriteSignal<Int> = ReadWriteSignal(0)
    let dataSignal: ReadWriteSignal<GraphQL.WelcomeQuery.Data?> = ReadWriteSignal(nil)
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

        func setButtonStyle(isMorePages _: Bool) {
            button.type.value = ButtonType.standard(backgroundColor: .brand(.primaryButtonBackgroundColor), textColor: .brand(.primaryButtonTextColor))
        }

        func setButtonTitle(isMorePages: Bool) {
            buttonTitleSignal.value = isMorePages ? L10n.newMemberProceed : L10n.newMemberDismiss
        }

        bag += button.onTapSignal.bindTo(onTapReadWriteSignal)

        bag += buttonTitleSignal
            .distinct()
            .delay(by: 0.25)
            .transition(style: .crossDissolve(duration: 0.25), with: buttonView, animations: { title in
                self.button.title.value = title
            })

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
