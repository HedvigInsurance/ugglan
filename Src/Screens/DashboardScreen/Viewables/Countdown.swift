//
//  Countdown.swift
//  UITests
//
//  Created by Axel Backlund on 2019-04-21.
//

import Flow
import Form
import Foundation
import UIKit
import ComponentKit

struct Countdown {
    func descriptiveLabel(text: String) -> UILabel {
        let label = UILabel(styledText: StyledText(text: text, style: .countdownLetter))
        label.snp.makeConstraints { make in
            make.width.equalTo(label.intrinsicContentSize.width + 7)
        }
        return label
    }

    let date: Date

    init(date: Date) {
        self.date = date
    }
}

extension Countdown: Viewable {
    func materialize(events _: ViewableEvents) -> (UIView, Disposable) {
        let bag = DisposeBag()

        let contentView = UIView()

        let view = UIStackView()
        view.alignment = .top
        view.distribution = .fill
        view.spacing = 4

        contentView.addSubview(view)

        let monthLabel = UILabel(styledText: StyledText(text: "0", style: .countdownNumber))
        view.addArrangedSubview(monthLabel)

        let m = descriptiveLabel(text: String(key: .DASHBOARD_PENDING_MONTHS))
        view.addArrangedSubview(m)

        let dayLabel = UILabel(styledText: StyledText(text: "0", style: .countdownNumber))
        dayLabel.textColor = UIColor.hedvig(.darkPurple)
        view.addArrangedSubview(dayLabel)

        let d = descriptiveLabel(text: String(key: .DASHBOARD_PENDING_DAYS))
        view.addArrangedSubview(d)

        let hourLabel = UILabel(styledText: StyledText(text: "0", style: .countdownNumber))
        hourLabel.textColor = UIColor.hedvig(.purple)
        view.addArrangedSubview(hourLabel)

        let h = descriptiveLabel(text: String(key: .DASHBOARD_PENDING_HOURS))
        view.addArrangedSubview(h)

        let minLabel = UILabel(styledText: StyledText(text: "0", style: .countdownNumber))
        minLabel.textColor = UIColor.hedvig(.turquoise)
        view.addArrangedSubview(minLabel)

        let mi = descriptiveLabel(text: String(key: .DASHBOARD_PENDING_MINUTES))
        view.addArrangedSubview(mi)

        view.snp.makeConstraints { make in
            make.height.centerX.centerY.equalToSuperview()
        }

        bag += Signal(every: 30).atOnce().onValue {
            // TODO: Singleton, move into struct
            let currentDate = Date()
            let calendar = Calendar.current

            let timeInterval = calendar.dateComponents([.month, .day, .hour, .minute], from: currentDate, to: self.date)

            if let months = timeInterval.month {
                monthLabel.text = String(months)
            }
            if let days = timeInterval.day {
                dayLabel.text = String(days)
            }
            if let hours = timeInterval.hour {
                hourLabel.text = String(hours)
            }
            if let mins = timeInterval.minute {
                minLabel.text = String(mins)
            }
        }

        return (contentView, bag)
    }
}
