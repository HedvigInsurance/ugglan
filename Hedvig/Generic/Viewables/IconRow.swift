//
//  IconRow.swift
//  Hedvig
//
//  Created by Sam Pettersson on 2019-01-03.
//  Copyright © 2019 Hedvig AB. All rights reserved.
//

import Flow
import Form
import Foundation
import UIKit

struct IconRow {
    enum Options {
        case defaults, withArrow
    }

    let iconAsset: ImageAsset
    let iconWidth: CGFloat
    let title: ReadSignal<String>
    let subtitle: ReadSignal<String>

    let options: [IconRow.Options]

    init(
        title: String,
        subtitle: String,
        iconAsset: ImageAsset,
        iconWidth: CGFloat = 50,
        options: [IconRow.Options] = [.defaults]
    ) {
        self.title = ReadWriteSignal(title).readOnly()
        self.subtitle = ReadWriteSignal(subtitle).readOnly()
        self.iconAsset = iconAsset
        self.iconWidth = iconWidth
        self.options = options
    }
}

extension IconRow: Viewable {
    func materialize(events _: SelectableViewableEvents) -> (RowView, Disposable) {
        let bag = DisposeBag()

        let rowView = RowView()
        let icon = Icon(frame: .zero, icon: iconAsset, iconWidth: iconWidth)
        let arrow = Icon(frame: .zero, icon: Asset.chevronRight, iconWidth: 20)

        let labelsContainer = UIStackView()
        labelsContainer.axis = .vertical

        let titleLabel = UILabel(value: "", style: .rowTitle)
        bag += title.atOnce().bindTo(titleLabel, \.text)

        let subtitleLabel = UILabel(value: "", style: .rowSubtitle)
        bag += subtitle.atOnce().bindTo(subtitleLabel, \.text)

        labelsContainer.addArrangedSubview(titleLabel)
        labelsContainer.addArrangedSubview(subtitleLabel)

        let row = rowView.prepend(
            icon
        ).append(labelsContainer)

        if options.contains(.withArrow) {
            row.append(arrow)
        }

        icon.snp.makeConstraints { make in
            make.width.equalTo(50)
        }

        arrow.snp.makeConstraints { make in
            make.width.equalTo(20)
        }

        return (row, bag)
    }
}
