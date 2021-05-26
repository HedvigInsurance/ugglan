import Flow
import Form
import Foundation
import hCore
import hCoreUI
import UIKit

struct MultiActionValueRow: Hashable, Equatable {
    let didTapRow = ReadWriteSignal<Bool>(false)
    let values: [String: String]
    let id = UUID()

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    static func == (lhs: MultiActionValueRow, rhs: MultiActionValueRow) -> Bool {
        lhs.id == rhs.id
    }
}

extension MultiActionValueRow: Reusable {
    static func makeAndConfigure() -> (make: UIView, configure: (MultiActionValueRow) -> Disposable) {
        let bag = DisposeBag()

        let control = UIControl()
        control.backgroundColor = .clear

        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.alignment = .center
        stackView.distribution = .fillEqually
        stackView.isUserInteractionEnabled = false

        let stylingView = UIView()
        bag += stylingView.applyShadow { _ in
            UIView.ShadowProperties(
                opacity: 0.05,
                offset: CGSize(width: 0, height: 6),
                blurRadius: 3,
                color: .brand(.primaryShadowColor),
                path: nil,
                radius: 8
            )
        }
        stylingView.layer.cornerRadius = 8
        stylingView.alpha = 0
        stylingView.backgroundColor = .brand(.embarkMessageBubble(false))
        stylingView.isUserInteractionEnabled = false

        control.addSubview(stylingView)
        stylingView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        let title = UILabel(value: "", style: .brand(.body(color: .primary)))

        let values = UILabel(value: "", style: .brand(.body(color: .secondary)))

        stackView.addArrangedSubview(title)
        stackView.addArrangedSubview(values)

        stylingView.addSubview(stackView)
        stackView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        let close = UIImageView()
        close.image = hCoreUIAssets.close.image
        close.contentMode = .scaleAspectFit
        close.tintColor = .brand(.secondaryText)

        stylingView.addSubview(close)
        close.snp.makeConstraints { make in
            make.top.right.equalToSuperview().inset(8)
        }

        return (control, { `self` in
            title.text = self.values.first?.value

            values.numberOfLines = 0
            values.lineBreakMode = .byWordWrapping
            values.text = self.values.map { _, value in
                value
            }.joined(separator: "\u{2022}")

            let didTapButton = control.signal(for: .touchDown)

            bag += didTapButton.onValue {
                self.didTapRow.value = true
            }

            bag += stackView.didLayoutSignal.take(first: 1).onValue { _ in
                stackView.transform = CGAffineTransform.identity
                stackView.transform = CGAffineTransform(translationX: 0, y: 40)
                stackView.alpha = 0

                bag += Signal(after: 0.4).animated(style: .lightBounce(), animations: { _ in
                    stackView.transform = CGAffineTransform.identity
                    stackView.alpha = 1
                    stylingView.alpha = 1
                })
            }

            return bag
        })
    }
}
