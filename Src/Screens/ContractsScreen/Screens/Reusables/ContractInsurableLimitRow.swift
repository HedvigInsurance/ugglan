//
//  ContractInsurableLimitRow.swift
//  test
//
//  Created by sam on 25.3.20.
//

import Flow
import Form
import Foundation
import UIKit

struct ContractInsurableLimitRow: Hashable {
    static func == (lhs: ContractInsurableLimitRow, rhs: ContractInsurableLimitRow) -> Bool {
        lhs.fragment.description == rhs.fragment.description
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(fragment.label)
        hasher.combine(fragment.description)
        hasher.combine(fragment.limit)
    }

    let fragment: InsurableLimitFragment
}

extension ContractInsurableLimitRow: Reusable {
    func makeContent(contentContainer: UIStackView) -> DisposeBag {
        let bag = DisposeBag()

        contentContainer.addArrangedSubview(UILabel(value: fragment.label, style: .headlineMediumMediumLeft))
        bag += contentContainer.addArranged(MultilineLabel(value: fragment.limit, style: .bodySmallSmallLeft))

        return bag
    }

    var contentSize: CGSize {
        let contentContainer = Self.makeContainer()

        let bag = DisposeBag()

        bag += makeContent(contentContainer: contentContainer)

        let size = contentContainer.systemLayoutSizeFitting(CGSize.zero)

        bag.dispose()

        return size
    }

    static func makeContainer() -> UIStackView {
        let contentContainer = UIStackView()
        contentContainer.spacing = 10
        contentContainer.axis = .vertical
        contentContainer.layoutMargins = UIEdgeInsets(inset: 10)
        contentContainer.isLayoutMarginsRelativeArrangement = true
        contentContainer.alignment = .center

        return contentContainer
    }

    static func makeAndConfigure() -> (make: UIView, configure: (ContractInsurableLimitRow) -> Disposable) {
        let view = UIView()

        let contentContainer = makeContainer()
        view.addSubview(contentContainer)

        contentContainer.snp.makeConstraints { make in
            make.top.bottom.leading.trailing.equalToSuperview()
        }

        return (view, { `self` in
            let bag = DisposeBag()

            bag += self.makeContent(contentContainer: contentContainer)

            return bag
        })
    }
}
