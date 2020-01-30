//
//  keyGearInformationView.swift
//  test
//
//  Created by Pavel Barros Quintanilla on 2020-01-30.
//

import Foundation
import Form
import Flow
import Presentation

struct KeyGearInfo {

}


extension KeyGearInfo: Presentable {
    func materialize() -> (UIViewController, Disposable) {
        let bag = DisposeBag()
        let viewController = UIViewController()
        
        let form = FormView()
        bag += viewController.install(form)
        
        let containerView = UIStackView()
        containerView.axis = .vertical
        containerView.alignment = .center
        containerView.distribution = .fill
        containerView.edgeInsets = .init(top: 80, left: 10, bottom: 40, right: 10)
        
        form.prepend(containerView)
        
        let firstTitle = UILabel(value: "70%", style: .infoTextHeader)
        
        let underProcentageLabel = UILabel(value: "av inköpspriset", style: .body)
        
        let informationText = UILabel(value: "Vi försöker reparera i första hand, men om din mobiltelefon skulle behöva ersättas helt (ex. om den blivit stulen) ersätts du med 70% av vad du köpte den för.", style: .body)
        informationText.textAlignment = .center
        informationText.numberOfLines = 0
        
        containerView.addArrangedSubview(firstTitle)
        containerView.addArrangedSubview(underProcentageLabel)
        containerView.addArrangedSubview(informationText)
        
        firstTitle.snp.makeConstraints { make in
            make.top.equalTo(containerView).offset(96)
        }
        containerView.setCustomSpacing(40, after: underProcentageLabel)

        informationText.snp.makeConstraints { make in
            make.left.equalTo(containerView).offset(24)
            make.right.equalTo(containerView).offset(-24)
        }
        containerView.setCustomSpacing(64, after: informationText)

        let divider = UIView()
        divider.backgroundColor = .lightGray
        containerView.addArrangedSubview(divider)
        
        divider.snp.makeConstraints { make in
            make.left.equalTo(containerView).offset(16)
            make.height.equalTo(1)
        }
        containerView.setCustomSpacing(40, after: divider)
    
        let reducedValueWhenAgingText = UILabel(value: "Åldersavdrag",
                                                style: .bodyBold)
        
        containerView.addArrangedSubview(reducedValueWhenAgingText)
        
        reducedValueWhenAgingText.snp.makeConstraints { make in
            make.left.equalTo(containerView).offset(24)
        }
        containerView.setCustomSpacing(64, after: informationText)
        
        let reducedAgingBodyText = UILabel(value: "För enkelhets skull gör vi ett avdrag med en viss procent beroende på hur länge sedan du köpte den.", style: .body)
        reducedAgingBodyText.numberOfLines = 0
        containerView.addArrangedSubview(reducedAgingBodyText)
        
        reducedAgingBodyText.snp.makeConstraints { make in
            make.left.equalTo(containerView).offset(24)
            make.right.equalTo(containerView).offset(-24)
        }
        containerView.setCustomSpacing(8, after: reducedValueWhenAgingText)
        
        let content = KeyGearExpandableListInfo()
        let expandable = ExpandableContent(content: content, isExpanded: .static(false))
        bag += containerView.addArranged(expandable)

        containerView.setCustomSpacing(24, after: reducedAgingBodyText)
 
        return (viewController, bag)
    }
}
