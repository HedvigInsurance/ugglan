//
//  KeyGearDateValuation.swift
//  test
//
//  Created by Pavel Barros Quintanilla on 2020-02-03.
//

import Foundation
import Flow
import Presentation
import Form

struct KeyGearDateValuation {
    
}

extension KeyGearDateValuation: Presentable {
    func materialize() -> (UIViewController, Disposable) {
        let bag = DisposeBag()
        let viewController = UIViewController()
        let form = FormView()
        
        bag += viewController.install(form)
        
        let containerView = UIStackView()
        containerView.axis = .vertical
        containerView.edgeInsets = UIEdgeInsets(top: 40, left: 24, bottom: 40, right: 24)
        containerView.distribution = .fill
        containerView.alignment = .center
        
        viewController.view.addSubview(containerView)
        
        containerView.snp.makeConstraints { make in
            make.top.bottom.trailing.leading.equalToSuperview()
        }
        
        let firstTitle = MultilineLabel(value: "Beräkna värdering", style: .headlineLargeLargCenter)
        bag += containerView.addArranged(firstTitle)
        
        bag += containerView.addArranged(Spacing(height: 8))
        
        let firstBody = MultilineLabel(value: "Vi försöker reparera i första hand, men om din mobiltelefon skulle behöva ersättas helt (ex. om den blivit stulen) ersätts du med inköpspriset minus åldersavdrag.", style: .bodyRegularRegularCenter)
        bag += containerView.addArranged(firstBody)
        
        bag += containerView.addArranged(Spacing(height: 40))
        
        let secondTitle = MultilineLabel(value: "Inköpsdatum", style: .headlineMediumMediumCenter)
        bag += containerView.addArranged(secondTitle)
        
        bag += containerView.addArranged(Spacing(height: 8))
        
        let secondBody = MultilineLabel(value: "Ange när du köpte telefonen för att beräkna åldersavdraget", style: .bodySmallSmallCenter)
        bag += containerView.addArranged(secondBody)
        
        bag += containerView.addArranged(Spacing(height: 24))
        
        let datePicker = UIDatePicker()

        datePicker.datePickerMode = .date
        datePicker.calendar = Calendar.current
        datePicker.maximumDate = Calendar.current.date(byAdding: .year, value: 0, to: Date())

        containerView.addArrangedSubview(datePicker)
        datePicker.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(8)
            make.right.equalToSuperview().offset(-8)
        }
        
        let continueButton = Button(title: "Fortsätt", type: .standard(backgroundColor: .purple, textColor: .white))
        let loadableButton = LoadableButton(button: continueButton)
        
        bag += containerView.addArranged(Spacing(height: 40))
        
        bag += containerView.addArranged(loadableButton)
        
        bag += loadableButton.onTapSignal.onValue { _ in
            loadableButton.isLoadingSignal.value = true
        }
        
        return (viewController, bag)
    }
    
}
