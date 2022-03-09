import Flow
import Form
import Foundation
import UIKit
import hCore
import hCoreUI

struct CircleLabelSmall {
    let labelText: DynamicString
    let textColor: UIColor
    let backgroundColor: UIColor

    init(
        labelText: DynamicString,
        textColor: UIColor,
        backgroundColor: UIColor
    ) {
        self.labelText = labelText
        self.textColor = textColor
        self.backgroundColor = backgroundColor
    }
}

extension CircleLabelSmall: Viewable {
    func materialize(events _: ViewableEvents) -> (UIView, Disposable) {
        let circleView = UIView()
        let bag = DisposeBag()

        let labelsContainer = CenterAllStackView()
        labelsContainer.axis = .vertical

        let titleLabel = UILabel()
        titleLabel.font = Fonts.fontFor(style: .title2)
        titleLabel.lineBreakMode = .byWordWrapping
        titleLabel.textAlignment = .center
        titleLabel.numberOfLines = 0
        titleLabel.adjustsFontSizeToFitWidth = true
        titleLabel.textColor = textColor
        bag += titleLabel.setDynamicText(labelText)

        bag += circleView.applyShadow { _ in
            UIView.ShadowProperties(
                opacity: 0.2,
                offset: CGSize(width: 10, height: 10),
                blurRadius: 3,
                color: UIColor.brand(.primaryShadowColor),
                path: nil,
                radius: 8
            )
        }

        circleView.backgroundColor = backgroundColor
        titleLabel.textColor = .brand(.primaryText())

        labelsContainer.addArrangedSubview(titleLabel)

        circleView.addSubview(labelsContainer)

        labelsContainer.snp.makeConstraints { make in make.edges.equalToSuperview() }

        bag += circleView.didLayoutSignal.onValue { _ in
            circleView.layer.cornerRadius = circleView.frame.height * 0.5
        }

        bag += circleView.didLayoutSignal.onFirstValue {
            circleView.snp.makeConstraints { make in make.width.equalTo(circleView.snp.height)
                make.height.equalToSuperview()
                make.center.equalToSuperview()
            }
        }

        return (circleView, bag)
    }
}
