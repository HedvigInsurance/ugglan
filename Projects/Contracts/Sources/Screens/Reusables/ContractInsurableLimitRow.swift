//
//  ContractInsurableLimitRow.swift
//  test
//
//  Created by sam on 25.3.20.
//

import Flow
import Form
import Foundation
import hCoreUI
import hGraphQL
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

    let fragment: GraphQL.InsurableLimitFragment
}

extension ContractInsurableLimitRow: Reusable {
    func makeContent(contentContainer: UIStackView) -> DisposeBag {
        let bag = DisposeBag()

        bag += contentContainer.addArranged(MultilineLabel(value: fragment.label, style: .brand(.headline(color: .primary))))
        bag += contentContainer.addArranged(MultilineLabel(value: fragment.limit, style: .brand(.body(color: .secondary))))

        return bag
    }

    func contentSize(_ targetSize: CGSize) -> CGSize {
        let contentContainer = Self.makeContainer()

        let bag = DisposeBag()

        bag += makeContent(contentContainer: contentContainer)

        let size = contentContainer.systemLayoutSizeFitting(
            targetSize,
            withHorizontalFittingPriority: .required,
            verticalFittingPriority: .defaultLow
        )

        bag.dispose()

        return size
    }

    static func makeContainer() -> UIStackView {
        let contentContainer = UIStackView()
        contentContainer.spacing = 10
        contentContainer.axis = .vertical
        contentContainer.layoutMargins = UIEdgeInsets(top: 10, left: 0, bottom: 10, right: 0)
        contentContainer.isLayoutMarginsRelativeArrangement = true
        contentContainer.alignment = .leading

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
