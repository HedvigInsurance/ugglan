//
//  TabHeader.swift
//  test
//
//  Created by Sam Pettersson on 2020-01-24.
//

import Flow
import Form
import Foundation
import hCore
import hCoreUI
import UIKit

struct TabHeader {
    let image: UIImage
    let title: String
    let description: String

    fileprivate struct Text {
        let title: String
        let description: String
    }
}

extension TabHeader: Reusable {
    static func makeAndConfigure() -> (make: UIView, configure: (TabHeader) -> Disposable) {
        let view = UIView()

        return (view, { `self` in
            let bag = DisposeBag()

            bag += view.add(self) { buttonView in
                buttonView.snp.makeConstraints { make in
                    make.width.height.equalToSuperview()
                }
            }

            return bag
        })
    }
}

extension TabHeader.Text: Viewable {
    func materialize(events _: ViewableEvents) -> (UIStackView, Disposable) {
        let view = UIStackView()
        view.axis = .vertical
        view.alignment = .center
        view.spacing = 10

        let bag = DisposeBag()

        let titleLabel = MultilineLabel(
            value: title,
            style: TextStyle.brand(.largeTitle(color: .primary)).centerAligned
        )
        bag += view.addArranged(titleLabel)

        let descriptionLabel = MultilineLabel(
            value: description,
            style: TextStyle.brand(.body(color: .secondary)).centerAligned
        )
        bag += view.addArranged(descriptionLabel)

        return (view, bag)
    }
}

extension TabHeader: Viewable {
    func materialize(events _: ViewableEvents) -> (UIView, Disposable) {
        let view = UIStackView()
        view.layoutMargins = UIEdgeInsets(horizontalInset: 0, verticalInset: 15)
        view.axis = .vertical
        view.alignment = .center
        view.isLayoutMarginsRelativeArrangement = true
        view.spacing = 15
        let bag = DisposeBag()

        let imageView = UIImageView()
        imageView.image = image
        imageView.contentMode = .scaleAspectFit

        imageView.snp.makeConstraints { make in
            make.height.equalTo(imageView.image?.size.height ?? 0)
            make.width.equalTo(imageView.image?.size.width ?? 0)
        }

        view.addArrangedSubview(imageView)

        bag += view.addArranged(Text(title: title, description: description)) { textView in
            textView.snp.makeConstraints { make in
                make.width.equalToSuperview().multipliedBy(0.8)
            }
        }

        return (view, bag)
    }
}
