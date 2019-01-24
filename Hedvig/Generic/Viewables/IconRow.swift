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
        case defaults, withArrow, disabled
    }

    let iconAsset: ImageAsset
    let iconWidth: CGFloat
    let title: ReadWriteSignal<String>
    let subtitle: ReadWriteSignal<String>

    let options: ReadWriteSignal<[IconRow.Options]>

    init(
        title: String,
        subtitle: String,
        iconAsset: ImageAsset,
        iconWidth: CGFloat = 40,
        options: [IconRow.Options] = [.defaults]
    ) {
        self.title = ReadWriteSignal(title)
        self.subtitle = ReadWriteSignal(subtitle)
        self.iconAsset = iconAsset
        self.iconWidth = iconWidth
        self.options = ReadWriteSignal(options)
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

        bag += options.atOnce().animated(style: AnimationStyle.easeOut(duration: 5), animations: { newOptions in
            arrow.removeFromSuperview()

            if newOptions.contains(.withArrow) {
                row.append(arrow)
            }

            if newOptions.contains(.disabled) {
                row.alpha = 0.5
            }
        })

        icon.snp.makeConstraints { make in
            make.width.equalTo(50)
        }

        arrow.snp.makeConstraints { make in
            make.width.equalTo(20)
        }

        return (row, bag)
    }
}
