import Flow
import Form
import Foundation
import hCore
import hCoreUI
import Market
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
        let view = UIControl()
        view.backgroundColor = .clear

        let stackView = UIStackView()
        stackView.isUserInteractionEnabled = false

        return (view, { `self` in
            let bag = DisposeBag()

            let title = UILabel()
            title.text = self.title

            stackView.addArrangedSubview(title)
            view.addSubview(stackView)
            stackView.snp.makeConstraints { make in
                make.edges.equalToSuperview()
            }

            return bag
        })
    }
}
