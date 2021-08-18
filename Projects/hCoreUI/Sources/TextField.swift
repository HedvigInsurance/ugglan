import Flow
import Foundation
import UIKit
import hCore

public enum TextFieldStyle {
  case border, line
}

public struct TextField {
  public let value: ReadWriteSignal<String>
  public let placeholder: ReadWriteSignal<String>
  public let enabledSignal: ReadWriteSignal<Bool>
  public let shouldReturn = Delegate<(String, UITextField), Bool>()
  public let style: TextFieldStyle
  public let clearButton: Bool

  public init(
    value: String,
    placeholder: String,
    enabled: Bool = true,
    style: TextFieldStyle = .border,
    clearButton: Bool = false
  ) {
    self.value = ReadWriteSignal(value)
    self.placeholder = ReadWriteSignal(placeholder)
    enabledSignal = ReadWriteSignal(enabled)
    self.style = style
    self.clearButton = clearButton
  }
}

extension TextField: Viewable {
  public func materialize(events _: ViewableEvents) -> (UIView, Disposable) {
    let bag = DisposeBag()
    let view = UIControl()
    view.layer.cornerRadius = 8
    view.isUserInteractionEnabled = true

    let paddingView = UIStackView()
    paddingView.isUserInteractionEnabled = true
    paddingView.axis = .vertical
    paddingView.isLayoutMarginsRelativeArrangement = true
    view.addSubview(paddingView)

    paddingView.snp.makeConstraints { make in make.trailing.leading.top.bottom.equalToSuperview() }

    switch style {
    case .border:
      view.layer.borderWidth = UIScreen.main.hairlineWidth
      bag += view.applyBorderColor { _ in .brand(.primaryBorderColor) }

      paddingView.layoutMargins = UIEdgeInsets(horizontalInset: 20, verticalInset: 3)
    case .line:
      let border = CALayer()
      border.backgroundColor = UIColor.brand(.primaryBorderColor).cgColor
      view.layer.addSublayer(border)

      bag += view.didLayoutSignal.onValue { _ in
        border.frame = CGRect(
          x: 0,
          y: view.frame.size.height - 1,
          width: view.frame.size.width,
          height: 1
        )
      }

      paddingView.layoutMargins = UIEdgeInsets(horizontalInset: 0, verticalInset: 6)
    }

    let textField = UITextField(value: "", placeholder: "", style: .default)
    textField.autocorrectionType = .no
    textField.autocapitalizationType = .none
    textField.clearButtonMode = clearButton ? .whileEditing : .never
    bag += value.atOnce().bidirectionallyBindTo(textField)
    bag += placeholder.atOnce().bindTo(textField, \.placeholder)
    bag += enabledSignal.atOnce().bindTo(textField, \.isEnabled)

    textField.snp.makeConstraints { make in make.height.equalTo(34) }

    bag += textField.shouldReturn.set { string -> Bool in
      self.shouldReturn.call((string, textField)) ?? false
    }

    paddingView.addArrangedSubview(textField)

    bag += view.signal(for: .touchDown).filter { !textField.isFirstResponder }
      .onValue { _ in textField.becomeFirstResponder() }

    return (view, bag)
  }
}
