import Flow
import Form
import Foundation
import hCore
import hCoreUI
import Market
import UIKit

struct MultiActionAddObjectRow: Hashable, Equatable {
    let title: String
    let callbacker = Callbacker<Void>()
    let id = UUID()

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    static func == (lhs: MultiActionAddObjectRow, rhs: MultiActionAddObjectRow) -> Bool {
        lhs.hashValue == rhs.hashValue
    }
}

extension MultiActionAddObjectRow: Reusable {
    static func makeAndConfigure() -> (make: UIControl, configure: (MultiActionAddObjectRow) -> Disposable) {
        let bag = DisposeBag()

        let control = UIControl()
        control.backgroundColor = .red

        let stackView = UIStackView()
        stackView.axis = .vertical

        let imageView = UIImageView()
        stackView.addArrangedSubview(imageView)
        imageView.backgroundColor = .clear
        imageView.contentMode = .scaleAspectFit
        imageView.image = hCoreUIAssets.addButton.image

        return (control, { `self` in
            let title = UILabel()
            title.text = self.title

            stackView.addArrangedSubview(title)
            control.addSubview(stackView)
            stackView.snp.makeConstraints { make in
                make.edges.equalToSuperview()
            }

            bag += control.signal(for: .touchDown).onValue { () in
                bag += self.callbacker.addCallback { _ in }
            }

            return bag
        })
    }
}
