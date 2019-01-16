//
//  Licenses.swift
//  Hedvig
//
//  Created by Sam Pettersson on 2019-01-16.
//  Copyright © 2019 Hedvig AB. All rights reserved.
//

import AcknowList
import Flow
import Form
import Presentation
import UIKit

struct Licenses {
    let presentingViewController: UIViewController
}

extension Acknow: Reusable {
    public static func makeAndConfigure() -> (make: RowView, configure: (Acknow) -> Disposable) {
        let row = RowView()
        let titleLabel = UILabel(value: "", style: .rowTitle)

        row.append(titleLabel)

        let arrow = Icon(frame: .zero, icon: Asset.chevronRight, iconWidth: 20)
        row.append(arrow)

        arrow.snp.makeConstraints { make in
            make.width.equalTo(20)
        }

        return (row, { item in
            titleLabel.text = item.title
            return NilDisposer()
        })
    }
}

extension Licenses: Presentable {
    func materialize() -> (UIViewController, Disposable) {
        let viewController = UIViewController()

        let bag = DisposeBag()

        viewController.title = String.translation(.LICENSES_SCREEN_TITLE)

        let acknowListViewController = AcknowListViewController()

        let tableKit = TableKit<EmptySection, Acknow>(bag: bag)
        
        tableKit.set(
            Table(rows: acknowListViewController.acknowledgements!),
            rowIdentifier: { $0.title }
        )

        bag += tableKit.delegate.didSelectRow.onValue { acknow in
            let acknowViewPresentable = AnyPresentable<AcknowViewController, Disposable> {
                let acknowViewController = AcknowViewController(acknowledgement: acknow)
                return (acknowViewController, NilDisposer())
            }

            self.presentingViewController.present(acknowViewPresentable)
        }

        bag += viewController.install(tableKit)

        return (viewController, bag)
    }
}
