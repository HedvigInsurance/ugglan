//
//  OfferStartDateButton.swift
//  test
//
//  Created by Sam Pettersson on 2020-01-14.
//

import Foundation
import Flow
import UIKit

struct OfferStartDateButton {
    let containerScrollView: UIScrollView
}

extension UIView {
    func applyCornerRadius(getCornerRadius: @escaping (_ traitCollection: UITraitCollection) -> CGFloat) -> Disposable {
        
        let bag = DisposeBag()
        
        bag += didLayoutSignal.onValue { _ in
            self.layer.cornerRadius = getCornerRadius(self.traitCollection)
        }
        
        bag += traitCollectionSignal.onValue { trait in
            self.layer.cornerRadius = getCornerRadius(trait)
        }
        
        return bag
    }
}



extension OfferStartDateButton: Viewable {
    func materialize(events: ViewableEvents) -> (UIStackView, Disposable) {
        let bag = DisposeBag()
        
        let containerStackView = UIStackView()
        containerStackView.alignment = .center
        containerStackView.axis = .vertical
        
        let button = UIControl()
        button.layer.borderWidth = 1
        bag += button.applyBorderColor { traitCollection -> UIColor in
            return .white
        }
        bag += button.applyCornerRadius { _ -> CGFloat in
            return button.layer.frame.height / 2
        }
        containerStackView.addArrangedSubview(button)
        
        bag += containerScrollView.contentOffsetSignal.onValue { contentOffset in
            containerStackView.transform = CGAffineTransform(
                translationX: 0,
                y: (contentOffset.y / 5)
            )
        }
                
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.distribution = .equalCentering
        stackView.alignment = .center
        stackView.spacing = 8
        stackView.layoutMargins = UIEdgeInsets(top: 12, left: 20, bottom: 12, right: 20)
        stackView.isLayoutMarginsRelativeArrangement = true
        button.addSubview(stackView)
        
        stackView.snp.makeConstraints { make in
            make.top.bottom.leading.trailing.equalToSuperview()
        }
        
        let keyLabel = UILabel(value: "Startdatum", style: .body)
        stackView.addArrangedSubview(keyLabel)
        
        let valueLabel = UILabel(value: "Idag", style: .bodyBold)
        stackView.addArrangedSubview(valueLabel)
                
        return (containerStackView, bag)
    }
}
