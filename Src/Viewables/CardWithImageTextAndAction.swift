//
//  ContentInsuranceCard.swift
//  test
//
//  Created by Pavel Barros Quintanilla on 2020-03-04.
//

import Foundation
import Flow
import Form
import Presentation
import UIKit

enum ContentAction {
    case toContentInsurance, toTravelInsurance
}

struct CardWithImageTextAndAction {
    let iconImage: ReadWriteSignal<ImageAsset>
    let title: ReadWriteSignal<String>
    let description: ReadWriteSignal<String>
    let actionButtonTitle: ReadWriteSignal<String>
}

extension CardWithImageTextAndAction: Viewable {
    func materialize(events: ViewableEvents) -> (UIView, Signal<Void>) {
        let bag = DisposeBag()
        let view = UIView()
        view.backgroundColor = .violet100
        view.layer.cornerRadius = 8
        
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.alignment = .center
        stackView.edgeInsets = UIEdgeInsets(top: 16, left: 15, bottom: 24, right: 15)
        
        let icon = Icon(icon: self.iconImage.value, iconWidth: 40)
        stackView.addArrangedSubview(icon)
        
        bag += stackView.addArranged(Spacing(height: 16))
        
        let titleLabel = MultilineLabel(value: self.title.value, style: .headlineSmallSmallLeft)
        bag += stackView.addArranged(titleLabel)
        
        bag += stackView.addArranged(Spacing(height: 4))
        let descriptionLabel = MultilineLabel(value: self.description.value, style: .bodySmallSmallLeft)
        bag += stackView.addArranged(descriptionLabel)
        
        bag += stackView.addArranged(Spacing(height: 22))
        
        let button = Button(title: actionButtonTitle.value, type: .standardSmall(backgroundColor: .purple, textColor: .white))
        bag += stackView.addArranged(button)
        
        view.addSubview(stackView)
        stackView.snp.makeConstraints { make in
            make.top.left.right.bottom.equalToSuperview()
        }
        
        return (view, Signal { callback in
            bag += button.onTapSignal.onValue(callback)
            
            return bag
        })
    }
}
