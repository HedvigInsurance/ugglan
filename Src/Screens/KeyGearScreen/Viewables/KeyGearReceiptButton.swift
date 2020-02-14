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
    func materialize(events: ViewableEvents) -> (RowView, Signal<Void>) {
        let bag = DisposeBag()
        let row = RowView()
        row.edgeInsets = UIEdgeInsets(top: 8, left: 16, bottom: 8, right: 16)
        row.distribution = .fill
        row.alignment = .center
        
        let icon = Icon(icon: Asset.addReceiptSecondaryCopy, iconWidth: 40)
        row.append(icon)
        
        let receiptText = MultilineLabel(value: "Kvitto", style: .smallTitle)
        bag += row.append(receiptText) { label in
            label.snp.makeConstraints { make in
                make.left.equalTo(icon.snp.right).offset(8)
                make.centerY.equalToSuperview()
            }
        }
        
        let dummyView = UIView()
        dummyView.setContentHuggingPriority(.defaultLow, for: .horizontal)
        row.addArrangedSubview(dummyView)
        
        let control = UIControl()
        let addReceiptText = MultilineLabel(value: "Lägg till +", style: .blockRowDescription)
        bag += control.add(addReceiptText) { label in
            label.textColor = .purple
            label.snp.makeConstraints { make in
                make.top.left.right.bottom.equalToSuperview()
            }
        }
    
        row.append(control)
        control.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
        }

        return (row, control.signal(for: .touchUpInside).hold(bag))
    }
}
