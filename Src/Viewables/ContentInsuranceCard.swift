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

struct ContentInsuranceCard {
    let iconImage: ImageAsset
    let title: String
    let description: String
    let type: ContentAction
    let presentingViewController: UIViewController
}

extension ContentInsuranceCard: Viewable {
    func materialize(events: ViewableEvents) -> (UIView, Future<Void>) {
        let bag = DisposeBag()
        let view = UIView()
        view.backgroundColor = .violet100
        view.layer.cornerRadius = 8
        
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.alignment = .center
        stackView.edgeInsets = UIEdgeInsets(top: 16, left: 15, bottom: 24, right: 15)
        
        let icon = Icon(icon: self.iconImage, iconWidth: 40)
        stackView.addArrangedSubview(icon)
        
        bag += stackView.addArranged(Spacing(height: 16))
        
        let titleLabel = MultilineLabel(value: "", style: .headlineSmallSmallLeft)
        bag += stackView.addArranged(titleLabel)
        
        bag += stackView.addArranged(Spacing(height: 4))
        
        let descriptionLabel = MultilineLabel(value: "TEST IGEN", style: .bodySmallSmallLeft)
        bag += stackView.addArranged(descriptionLabel)
        
        bag += stackView.addArranged(Spacing(height: 22))
        
        let button = Button(title: "Get Contents insurance", type: .standardSmall(backgroundColor: .purple, textColor: .white))
        bag += stackView.addArranged(button)
        
        view.addSubview(stackView)
        stackView.snp.makeConstraints { make in
            make.top.left.right.bottom.equalToSuperview()
        }
        
        return (view, Future { completion in
            switch self.type {
            case .toContentInsurance:
                icon.icon = Asset.attachFile
                titleLabel.styledTextSignal.value.text = self.title
                descriptionLabel.styledTextSignal.value.text = self.description
                button.title.value = "Get Contents insurance"
                
            case .toTravelInsurance:
                icon.icon = Asset.addButton
                titleLabel.styledTextSignal.value.text = self.title
                descriptionLabel.styledTextSignal.value.text = self.description
                button.title.value = "Get Travel insurance"
            }
            
            bag += button.onTapSignal.onValue({ _ in
                
            })
            
            return bag
        })
    }
}
