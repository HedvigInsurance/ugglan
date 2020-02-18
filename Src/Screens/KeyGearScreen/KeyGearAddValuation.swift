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

struct KeyGearAddValuation {}

struct PurchasePrice: Viewable {
    func materialize(events: ViewableEvents) -> (RowView, Disposable) {
        let bag = DisposeBag()
        let row = RowView()
        
        row.prepend(UILabel(value: String(key: .KEY_GEAR_ADD_PURCHASE_PRICE_CELL_TITLE), style: .headlineMediumMediumLeft))
        
        let textField = UITextField(value: "", placeholder: "0", style: .defaultRight)
        textField.keyboardType = .numeric
        
        bag += textField.addDoneToolbar()
        
        row.append(textField)
        
        return (row, bag)
    }
}

struct DatePicker: Viewable {
    func materialize(events: SelectableViewableEvents) -> (RowView, Disposable) {
        let bag = DisposeBag()
        let row = RowView()
        
        let containerView = UIStackView()
        containerView.axis = .vertical
        containerView.spacing = 10
        row.append(containerView)
        
        let mainRowContainerView = UIStackView()
        mainRowContainerView.axis = .horizontal
        containerView.addArrangedSubview(mainRowContainerView)
        
        mainRowContainerView.addArrangedSubview(UILabel(value: String(key: .KEY_GEAR_YEARMONTH_PICKER_TITLE), style: .headlineMediumMediumLeft))
        
        let value = UILabel(value: Date().localDateString ?? "", style: .rowValueEditableRight)
        mainRowContainerView.addArrangedSubview(value)
        
        let picker = UIDatePicker()
        picker.calendar = Calendar.current
        picker.datePickerMode = .date
        picker.isHidden = true
        containerView.addArrangedSubview(picker)
        
        picker.snp.makeConstraints { make in
            make.height.equalTo(216)
        }
        
        bag += picker.onValue { date in
            value.value = date.localDateString ?? ""
        }
        
        bag += events.onSelect.animated(style: SpringAnimationStyle.lightBounce(), animations: { _ in
            picker.isHidden = !picker.isHidden
            picker.layoutSuperviewsIfNeeded()
            picker.layoutIfNeeded()
            picker.alpha = picker.isHidden ? 0 : 1
        })
        
        return (row, bag)
    }
}

extension KeyGearAddValuation: Presentable {
    func materialize() -> (UIViewController, Disposable) {
        let bag = DisposeBag()
        let viewController = UIViewController()
        viewController.title = String(key: .KEY_GEAR_ADD_PURCHASE_INFO_PAGE_TITLE)
        let form = FormView()
        
        bag += viewController.install(form)
                
        let descriptionLabel = MultilineLabel(value: String(key: .KEY_GEAR_ADD_PURCHASE_INFO_BODY(itemType: "TODO")), style: .bodyRegularRegularCenter)
        bag += form.append(descriptionLabel)
        
        bag += form.append(Spacing(height: 40))
        
        let priceSection = form.appendSection()
        priceSection.dynamicStyle = .sectionPlain
        
        bag += priceSection.append(PurchasePrice())
        
        bag += form.append(Spacing(height: 20))
        
        let dateSection = form.appendSection()
        dateSection.dynamicStyle = .sectionPlain
        
        bag += dateSection.append(DatePicker())
        
        bag += form.append(Spacing(height: 40))
        
        let button = LoadableButton(button: Button(title: "Spara", type: .standard(backgroundColor: .primaryTintColor, textColor: .white)))
        bag += form.append(button)
        
        bag += button.onTapSignal.onValue { _ in
            viewController.present(KeyGearValuation())
        }
        
        return (viewController, bag)
    }
    
}
