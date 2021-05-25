import Flow
import Form
import Foundation
import hCore
import hCoreUI
import UIKit

struct MultiActionValueRow: Hashable, Equatable {
    let title: String
    let keyInformation: [String]
    let id = UUID()

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    static func == (lhs: MultiActionValueRow, rhs: MultiActionValueRow) -> Bool {
        lhs.hashValue == rhs.hashValue
    }
}

extension MultiActionValueRow: Reusable {
    static func makeAndConfigure() -> (make: UIView, configure: (MultiActionValueRow) -> Disposable) {
        let bag = DisposeBag()

        let view = UIControl()
        view.backgroundColor = .clear

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

        view.addSubview(stylingView)
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

        return (view, { `self` in
            title.text = self.title

            values.numberOfLines = 0
            values.lineBreakMode = .byWordWrapping
            values.text = self.keyInformation.joined(separator: "\u{2022}")

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
