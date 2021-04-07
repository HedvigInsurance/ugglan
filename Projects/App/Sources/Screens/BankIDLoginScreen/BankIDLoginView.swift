import Apollo
import Flow
import Form
import Foundation
import hCore
import hCoreUI
import hGraphQL
import Presentation
import UIKit

struct BankIDLoginView: Presentable {
    @Inject var client: ApolloClient

    func materialize() -> (UIViewController, FiniteSignal<String>) {
        let viewController = UIViewController()
        viewController.preferredPresentationStyle = .modal
        let bag = DisposeBag()

        let form = FormView()

        viewController.title = L10n.bankidLoginTitle

        let label = UILabel()
        label.text = Localization.Locale.currentLocale.market.labelTitle

        let textField = UITextField()
        textField.placeholder = L10n.SimpleSignLogin.TextField.helperText
        textField.keyboardType = .numberPad
        textField.clearButtonMode = .whileEditing

        bag += textField.didMoveToWindowSignal.delay(by: 0.5).onValue {
            textField.becomeFirstResponder()
        }

        form.appendSpacing(.top)

        let section = form.appendSection()

        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 27
        stackView.edgeInsets = .init(top: 0, left: 16, bottom: 0, right: 16)

        stackView.addArrangedSubview(label)
        stackView.addArrangedSubview(textField)
        stackView.setCustomSpacing(8, after: textField)

        bag += stackView.addArranged(Divider(backgroundColor: .brand(.primaryBorderColor)))
        section.append(stackView)

        bag += form.append(Spacing(height: 30))

        let buttonSection = form.appendSection()

        form.appendSpacing(.inbetween)

        let buttonRow = ButtonRowViewWrapper(
            title: Localization.Locale.currentLocale.market.buttonTitle,
            type: .standard(
                backgroundColor: UIColor.brand(.secondaryButtonBackgroundColor),
                textColor: UIColor.brand(.secondaryButtonTextColor)
            ),
            isEnabled: false
        )

        bag += textField.distinct()
            .map { text in text.count == Localization.Locale.currentLocale.market.count() }
            .bindTo(buttonRow.isEnabledSignal)

        bag += buttonSection.append(buttonRow)

        bag += viewController.install(form)

        return (viewController, FiniteSignal { callback in
            bag += buttonRow.onTapSignal.onValue {
                callback(.value(textField.text ?? ""))
            }

            return bag
        })
    }
}

private extension Localization.Locale.Market {
    func count() -> Int {
        switch self {
        case .no:
            return 11
        case .dk:
            return 10
        case .se:
            return 10
        }
    }

    var labelTitle: String? {
        switch self {
        case .no:
            return L10n.SimpleSignLogin.TextField.label
        case .se:
            return nil
        case .dk:
            return L10n.SimpleSignLogin.TextField.labelDk
        }
    }

    var buttonTitle: String {
        switch self {
        case .no:
            return L10n.SimpleSign.signIn
        case .se:
            return ""
        case .dk:
            return L10n.SimpleSign.signInDk
        }
    }
}
