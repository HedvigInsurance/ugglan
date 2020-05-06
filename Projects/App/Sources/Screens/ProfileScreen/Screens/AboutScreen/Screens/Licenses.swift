//
//  Licenses.swift
//  Hedvig
//
//  Created by Sam Pettersson on 2019-01-16.
//  Copyright © 2019 Hedvig AB. All rights reserved.
//

// import AcknowList
import Flow
import Form
import Presentation
import UIKit

struct Licenses {}
//
// extension Acknow: Reusable {
//    public static func makeAndConfigure() -> (make: RowView, configure: (Acknow) -> Disposable) {
//        let row = RowView()
//        let titleLabel = UILabel(value: "", style: .rowTitle)
//
//        row.append(titleLabel)
//
//        let arrow = Icon(frame: .zero, icon: Asset.chevronRight, iconWidth: 20)
//        row.append(arrow)
//
//        arrow.snp.makeConstraints { make in
//            make.width.equalTo(20)
//        }
//
//        return (row, { item in
//            titleLabel.text = item.title
//            return NilDisposer()
//        })
//    }
// }
//
// extension Acknow: Previewable {
//    func preview() -> (License, PresentationOptions) {
//        return (License(acknowledgement: self), .defaults)
//    }
// }
//
// extension Licenses: Presentable {
//    func materialize() -> (UIViewController, Disposable) {
//        let viewController = UIViewController()
//
//        let bag = DisposeBag()
//
//        viewController.title = String(key: .LICENSES_SCREEN_TITLE)
//
//        let acknowListViewController = AcknowListViewController(fileNamed: "Pods-Hedvig-acknowledgements")
//
//        let tableKit = TableKit<EmptySection, Acknow>(
//            table: Table(),
//            style: .grouped,
//            holdIn: bag
//        )
//
//        tableKit.set(
//            Table(rows: acknowListViewController.acknowledgements!),
//            rowIdentifier: { $0.title }
//        )
//
//        let headerView = UIView()
//
//        let headerLabel = UILabel(
//            value: String(key: .ACKNOWLEDGEMENT_HEADER_TITLE),
//            style: .body
//        )
//        headerLabel.numberOfLines = 0
//        headerLabel.lineBreakMode = .byWordWrapping
//
//        bag += headerLabel.didLayoutSignal.onValue {
//            headerLabel.preferredMaxLayoutWidth = headerLabel.frame.size.width
//
//            headerView.snp.remakeConstraints { make in
//                make.width.equalToSuperview()
//                make.height.equalTo(headerLabel.intrinsicContentSize.height + 40)
//            }
//        }
//
//        headerView.addSubview(headerLabel)
//
//        tableKit.headerView = headerView
//
//        headerLabel.snp.makeConstraints { make in
//            make.width.equalToSuperview().inset(15)
//            make.center.equalToSuperview()
//        }
//
//        headerLabel.sizeToFit()
//
//        bag += tableKit.delegate.didSelectRow.onValue { acknowledgement in
//            let license = License(acknowledgement: acknowledgement)
//            viewController.present(license)
//        }
//
//        bag += tableKit.delegate.willDisplayCell.onValue { cell, index in
//            let acknow = tableKit.table[index]
//            bag += viewController.registerForPreviewing(sourceView: cell, previewable: acknow)
//        }
//
//        bag += viewController.install(tableKit)
//
//        return (viewController, bag)
//    }
// }
