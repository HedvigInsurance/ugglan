import Flow
import Form
import Foundation
import hCore
import hCoreUI
import Market
import UIKit

struct MultiActionObjectRow {
    let title: String
}

extension MultiActionObjectRow: Reusable {
    static func makeAndConfigure() -> (make: UIView, configure: (MultiActionObjectRow) -> Disposable) {
        let view = UIControl()
        view.backgroundColor = .clear

        let stackView = UIStackView()

        let imageView = UIImageView()
        stackView.addSubview(imageView)
        view.clipsToBounds = true
        imageView.isUserInteractionEnabled = false
        imageView.backgroundColor = .clear
        imageView.contentMode = .scaleAspectFill
        imageView.image = hCoreUIAssets.addButton.image

        return (view, { `self` in
            let bag = DisposeBag()

            let title = UILabel()
            title.text = self.title

            stackView.addSubview(title)
            view.addSubview(stackView)
            stackView.snp.makeConstraints { make in
                make.edges.equalToSuperview()
            }

            return bag
        })
    }
}
