//
//  WelcomePagerDots.swift
//  project
//
//  Created by Gustaf Gunér on 2019-06-28.
//

import Flow
import Form
import Foundation
import UIKit
import ComponentKit

struct WelcomePagerDots {
    let pageIndexSignal: ReadWriteSignal<Int> = ReadWriteSignal(0)
    let pageAmountSignal: ReadWriteSignal<Int> = ReadWriteSignal(0)
}

extension WelcomePagerDots: Viewable {
    func materialize(events _: ViewableEvents) -> (UIView, Disposable) {
        let bag = DisposeBag()

        let view = UIView()

        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.spacing = 10

        view.addSubview(stackView)

        bag += view.didLayoutSignal.onValue {
            stackView.snp.makeConstraints { make in
                make.height.centerX.centerY.equalToSuperview()
            }
        }

        bag += pageAmountSignal.atOnce().filter { $0 != 0 }.onValue { pageAmount in
            for subview in stackView.subviews {
                subview.removeFromSuperview()
            }

            for i in 0 ... pageAmount - 2 {
                let indicator = UIView()
                indicator.backgroundColor = i == 0 ? .hedvig(.primaryTintColor) : .gray
                indicator.transform = i == 0 ? CGAffineTransform(scaleX: 1.5, y: 1.5) : CGAffineTransform.identity
                indicator.layer.cornerRadius = 2

                indicator.snp.makeConstraints { make in
                    make.width.height.equalTo(4)
                }

                stackView.addArrangedSubview(indicator)
            }

            let hedvigSymbol = UIImageView()
            hedvigSymbol.image = Asset.symbol.image.withRenderingMode(.alwaysTemplate)
            hedvigSymbol.contentMode = .scaleAspectFit
            hedvigSymbol.tintColor = .gray
            hedvigSymbol.snp.makeConstraints { make in
                make.width.height.equalTo(12)
            }

            stackView.addArrangedSubview(hedvigSymbol)
        }

        bag += pageIndexSignal.animated(style: SpringAnimationStyle.heavyBounce()) { pageIndex in
            for (index, indicator) in stackView.subviews.enumerated() {
                let indicatorIsActive = index == pageIndex

                if indicator is UIImageView {
                    indicator.tintColor = indicatorIsActive ? .hedvig(.primaryTintColor) : .gray
                } else {
                    indicator.backgroundColor = indicatorIsActive ? .hedvig(.primaryTintColor) : .gray
                }

                indicator.transform = indicatorIsActive ? CGAffineTransform(scaleX: 1.5, y: 1.5) : CGAffineTransform.identity
            }
        }

        return (view, bag)
    }
}
