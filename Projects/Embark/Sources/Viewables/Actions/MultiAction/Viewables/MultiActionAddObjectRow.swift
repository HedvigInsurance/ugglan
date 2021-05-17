import Flow
import Form
import Foundation
import hCore
import hCoreUI
import Market
import UIKit

struct MultiActionAddObjectRow: Hashable, Equatable {
    let title: String
    let didTapRow = ReadWriteSignal<Bool>(false)
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
        stackView.distribution = .fillEqually
        stackView.isUserInteractionEnabled = false

        control.addSubview(stackView)
        stackView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.image = hCoreUIAssets.addButton.image
        stackView.addArrangedSubview(imageView)

        return (control, { `self` in
            let title = UILabel()
            title.text = self.title

            stackView.addArrangedSubview(title)

            let didTapButton = control.signal(for: .touchDown)

            bag += didTapButton.onValue {
                self.didTapRow.value = true
            }

            return bag
        })
    }
}
