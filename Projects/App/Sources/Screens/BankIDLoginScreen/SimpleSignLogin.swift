import Apollo
import Flow
import Form
import Foundation
import hCore
import hCoreUI
import hGraphQL
import Presentation
import UIKit

struct SimpleSignLoginView: Presentable {
    @Inject var client: ApolloClient

    func materialize() -> (UIViewController, FiniteSignal<String>) {
        let viewController = UIViewController()
        viewController.preferredPresentationStyle = .modal

        let bag = DisposeBag()

        let form = FormView()

        let masking = Localization.Locale.currentLocale.market.masking

        viewController.title = L10n.bankidLoginTitle

        let label = UILabel()
        label.text = Localization.Locale.currentLocale.market.labelTitle

        let continueButton = Button(
            title: Localization.Locale.currentLocale.market.buttonTitle,
            type: .standard(
                backgroundColor: UIColor.brand(.secondaryButtonBackgroundColor),
                textColor: UIColor.brand(.secondaryButtonTextColor)
            ),
            isEnabled: false
        )

        let textField = UITextField()
        masking.applySettings(textField)
        textField.placeholder = L10n.SimpleSignLogin.TextField.helperText
        textField.clearButtonMode = .whileEditing

        bag += textField.didMoveToWindowSignal.delay(by: 0.5).onValue {
            textField.becomeFirstResponder()
        }

        bag += masking.isValidSignal(textField).bindTo(continueButton.isEnabled)
        bag += masking.applyMasking(textField)

        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 27
        stackView.edgeInsets = .init(top: 0, left: 16, bottom: 0, right: 16)

        stackView.addArrangedSubview(label)
        stackView.addArrangedSubview(textField)
        stackView.setCustomSpacing(8, after: textField)
        stackView.setContentHuggingPriority(.defaultHigh, for: .vertical)

        bag += stackView.addArranged(Divider(backgroundColor: .brand(.primaryBorderColor)))

        let views = [UIView(), stackView, UIView()]

        let buttonStack = UIStackView()
        buttonStack.edgeInsets = .init(top: 0, left: 16, bottom: 16 + viewController.view.safeAreaInsets.bottom, right: 16)
        bag += buttonStack.addArranged(continueButton)

        bag += viewController.install(form) { scrollView in
            bag += scrollView.embedPinned(buttonStack, edge: .bottom, minHeight: 44)
            bag += scrollView.embedWithSpacingBetween(views)
        }

        return (viewController, FiniteSignal { callback in
            bag += continueButton.onTapSignal.onValue {
                callback(.value(textField.text ?? ""))
            }

            return bag
        })
    }
}

private extension Localization.Locale.Market {
    var masking: Masking {
        switch self {
        case .no:
            return .init(type: .norwegianPersonalNumber)
        case .se:
            return .init(type: .personalNumber)
        case .dk:
            return .init(type: .danishPersonalNumber)
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
