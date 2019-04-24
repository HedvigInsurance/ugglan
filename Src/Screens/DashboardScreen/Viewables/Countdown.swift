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

struct Countdown {}

extension Countdown: Viewable {
    func materialize(events _: ViewableEvents) -> (UIView, Disposable) {
        let bag = DisposeBag()
        
        let contentView = UIView()
        
        let view = UIStackView()
        view.alignment = .top
        view.distribution = .fill
        view.spacing = 4
        
        contentView.addSubview(view)
        
        func descriptiveLabel(text: String) -> UILabel {
            let label = UILabel(styledText: StyledText(text: text, style: .countdownLetter))
            label.snp.makeConstraints { make in
                make.width.equalTo(label.intrinsicContentSize.width + 7)
            }
            return label
        }
        
        let date = Date()
        
        //bag += Signal(every: 1)
        
        let monthLabel = UILabel(styledText: StyledText(text: "8", style: .countdownNumber))
        view.addArrangedSubview(monthLabel)
        
        let m = descriptiveLabel(text: "M")
        view.addArrangedSubview(m)
        
        let dayLabel = UILabel(styledText: StyledText(text: "24", style: .countdownNumber))
        dayLabel.textColor = UIColor.darkPurple
        view.addArrangedSubview(dayLabel)
        
        let d = descriptiveLabel(text: "D")
        view.addArrangedSubview(d)
        
        let hourLabel = UILabel(styledText: StyledText(text: "13", style: .countdownNumber))
        hourLabel.textColor = UIColor.purple
        view.addArrangedSubview(hourLabel)
        
        let h = descriptiveLabel(text: "H")
        view.addArrangedSubview(h)
        
        let minLabel = UILabel(styledText: StyledText(text: "45", style: .countdownNumber))
        minLabel.textColor = UIColor.turquoise
        view.addArrangedSubview(minLabel)
        
        let mi = descriptiveLabel(text: "M")
        view.addArrangedSubview(mi)
        
        view.snp.makeConstraints { (make) in
            make.height.centerX.centerY.equalToSuperview()
        }
        
        return (contentView, bag)
    }
}
