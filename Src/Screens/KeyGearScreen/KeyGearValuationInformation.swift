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

struct KeyGearValuationInformation { }

extension KeyGearValuationInformation: Presentable {
    func materialize() -> (UIViewController, Disposable) {
        let bag = DisposeBag()
        let viewController = UIViewController()
        viewController.view.backgroundColor = .primaryBackground
        let form = FormView()
        bag += viewController.install(form)
        
        let containerView = UIStackView()
        containerView.axis = .vertical
        containerView.alignment = .center
        containerView.edgeInsets = .init(top: 20, left: 24, bottom: 0, right: 24)
        
        form.prepend(containerView)
        
        let firstTitle = MultilineLabel(styledText: StyledText(text: "70%", style: .infoTextHeader))
        bag += containerView.addArranged(firstTitle)
        
        let underProcentageLabel = MultilineLabel(value: "av inköpspriset",
                                                  style: .keySmallText)
        bag += containerView.addArranged(underProcentageLabel)
        bag += containerView.addArranged(Spacing(height: 40))
        
        let informationText = MultilineLabel(value: "Vi försöker reparera i första hand, men om din mobiltelefon skulle behöva ersättas helt (ex. om den blivit stulen) ersätts du med 70% av vad du köpte den för.",
                                             style: .keyInformationBodyText)
        bag += containerView.addArranged(informationText) { text in
            text.textAlignment = .center
        }
        bag += containerView.addArranged(Spacing(height: 64))

        let divider = UIView()
        divider.backgroundColor = .lightGray
        containerView.addArrangedSubview(divider)
        
        divider.snp.makeConstraints { make in
            make.left.equalTo(containerView).offset(16)
            make.height.equalTo(1)
        }
        
        let subContainerView = UIStackView()
        subContainerView.axis = .vertical
        subContainerView.alignment = .leading
        subContainerView.edgeInsets = UIEdgeInsets(top: 40, left: 24, bottom: 40, right: 24)
        
        form.append(subContainerView)
        
        let reducedValueWhenAgingText = MultilineLabel(value: "Åldersavdrag",
                                                style: .keyBoldTitletext)
        bag += subContainerView.addArranged(reducedValueWhenAgingText)
        bag += subContainerView.addArranged(Spacing(height: 8))
        
        let reducedAgingBodyText = MultilineLabel(value: "För enkelhets skull gör vi ett avdrag med en viss procent beroende på hur länge sedan du köpte den.",
                                                  style: .keySmallText)
        bag += subContainerView.addArranged(reducedAgingBodyText)
        bag += subContainerView.addArranged(Spacing(height: 24))
        
        let expandableView = FormView()
        let expandable = ExpandableContent(content: KeyGearExpandableListInfo(), isExpanded: .static(false))
        bag += expandableView.append(expandable)
        
        subContainerView.addArrangedSubview(expandableView)
        
        expandableView.snp.makeConstraints { make in
            make.left.equalTo(containerView).offset(16)
            make.right.equalTo(containerView).offset(-16)
        }
 
        return (viewController, bag)
    }
}
