//
//  KeyGearCoverage.swift
//  test
//
//  Created by Sam Pettersson on 2020-02-17.
//

import Flow
import Form
import Foundation

struct KeyGearCoverage {
    let type: CoverageType

    enum CoverageType {
        case included, excluded
    }
}

extension KeyGearCoverage: Viewable {
    func materialize(events _: ViewableEvents) -> (RowView, Disposable) {
        let row = RowView()
        let bag = DisposeBag()

        let icon = Icon(icon: type == .included ? Asset.greenCircularCheckmark : Asset.pinkCircularCross, iconWidth: 15)
        icon.snp.makeConstraints { make in
            make.width.equalTo(30)
        }
        row.prepend(icon)

        row.append(UILabel(value: "Om du slarvar bort den", style: .bodyRegularRegularLeft))

        return (row, bag)
    }
}
