import Flow
import Form
import Foundation
import UIKit
import hCore
import hCoreUI

struct MultiActionAddObjectRow: Hashable, Equatable {
  let title: String
  let didTapRow = ReadWriteSignal<Bool>(false)
  let id = UUID()

  func hash(into hasher: inout Hasher) { hasher.combine(id) }

  static func == (lhs: MultiActionAddObjectRow, rhs: MultiActionAddObjectRow) -> Bool {
    lhs.hashValue == rhs.hashValue
  }
}

extension MultiActionAddObjectRow: Reusable {
  static func makeAndConfigure() -> (make: UIControl, configure: (MultiActionAddObjectRow) -> Disposable) {
    let bag = DisposeBag()

    let control = UIControl()
    control.layer.borderWidth = 0.5
    control.layer.cornerRadius = 8
    bag += control.applyBorderColor { (traitCollection) -> UIColor in
      switch traitCollection.userInterfaceStyle {
      case .dark: return UIColor.brand(.primaryText())
      case .light: return UIColor.brand(.primaryBorderColor)
      default: return UIColor.brand(.primaryBorderColor)
      }
    }

    let stackView = UIStackView()
    stackView.axis = .vertical
    stackView.distribution = .fillEqually
    stackView.alignment = .center
    stackView.isUserInteractionEnabled = false
    stackView.edgeInsets = .init(top: 8, left: 0, bottom: 8, right: 0)

    control.addSubview(stackView)
    stackView.snp.makeConstraints { make in make.edges.equalToSuperview() }

    let imageView = UIImageView()
    imageView.contentMode = .scaleAspectFit
    imageView.image = hCoreUIAssets.circularPlus.image
    imageView.snp.makeConstraints { make in make.height.width.equalTo(24) }
    stackView.addArrangedSubview(imageView)
    imageView.tintColor = .brand(.primaryText())

    let title = UILabel(value: "", style: .brand(.body(color: .primary)))
    stackView.addArrangedSubview(title)

    return (
      control,
      { `self` in

        title.text = self.title

        let didTapButton = control.signal(for: .touchDown)

        bag += didTapButton.onValue { self.didTapRow.value = true }

        return bag
      }
    )
  }
}
