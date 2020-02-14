//
//  KeyGearReceiptButton.swift
//  test
//
//  Created by Pavel Barros Quintanilla on 2020-02-13.
//

import Foundation
import Flow
import Form
import Presentation
import UIKit

struct KeyGearReceiptButton {
}

extension KeyGearReceiptButton: Viewable {
    func materialize(events: ViewableEvents) -> (UIView, Signal<Void>) {
        let bag = DisposeBag()
        let view = UIView()
        view.layer.cornerRadius = 9
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor.lightGray.cgColor
        view.backgroundColor = .white
        
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.edgeInsets = UIEdgeInsets(top: 8, left: 16, bottom: 8, right: 0)
        stackView.distribution = .fillProportionally
        stackView.alignment = .center
        
        view.addSubview(stackView)
        stackView.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview()
        }
        
        let icon = Icon(icon: Asset.addReceiptSecondaryCopy, iconWidth: 40)
        stackView.addArrangedSubview(icon)
        
        let receiptText = MultilineLabel(value: "Kvitto", style: .smallTitle)
        bag += stackView.addArranged(receiptText) { label in
            label.snp.makeConstraints { make in
                make.centerY.equalTo(view)
            }
        }
        
        stackView.setCustomSpacing(8, after: icon)
        
        let trailingStackView = UIStackView()
        trailingStackView.axis = .horizontal
        trailingStackView.edgeInsets = UIEdgeInsets(top: 18, left: 0, bottom: 18, right: 16)
        trailingStackView.distribution = .fill
        trailingStackView.alignment = .center
        
        view.addSubview(trailingStackView)
        trailingStackView.snp.makeConstraints { make in
            make.top.right.bottom.equalToSuperview()
        }
        
        let control = UIControl()
        let addReceiptText = MultilineLabel(value: "Lägg till kvitto +", style: .blockRowDescription)
        bag += control.add(addReceiptText) { view in
            view.snp.makeConstraints { make in
                view.textColor = .purple
                make.top.left.right.bottom.equalToSuperview()
            }
        }
        
        trailingStackView.addArrangedSubview(control)
        
        return (view, control.signal(for: .touchUpInside).hold(bag))
    }
}
