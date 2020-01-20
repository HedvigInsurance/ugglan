//
//  PresentStartDate.swift
//  test
//
//  Created by Pavel Barros Quintanilla on 2020-01-14.
//

import Foundation
import Flow
import Presentation
import UIKit
import SnapKit

struct PresentStartDate {
    private let didRedeemValidCodeCallbacker = Callbacker<RedeemCodeMutation.Data.RedeemCode>()
}

extension PresentStartDate: Presentable {
    func materialize() -> (UIViewController, Future<Void>) {
        let viewController = UIViewController()
        viewController.preferredContentSize = CGSize(width: 50, height: 511)

        let bag = DisposeBag()
        
        let containerView = UIStackView()
        containerView.axis = .vertical
        
        bag += containerView.applyPreferredContentSize(on: viewController)

        viewController.view = containerView

        let textStackView = UIStackView()
        textStackView.spacing = 8
        textStackView.axis = .vertical
        textStackView.layoutMargins = UIEdgeInsets(top: 32, left: 24, bottom: 32, right: 24)
        textStackView.isLayoutMarginsRelativeArrangement = true        
        containerView.addArrangedSubview(textStackView)
        
        let pickerStackView = UIStackView()
        pickerStackView.spacing = 8
        pickerStackView.axis = .vertical
        pickerStackView.layoutMargins = UIEdgeInsets(horizontalInset: 0, verticalInset: 0)
        pickerStackView.isLayoutMarginsRelativeArrangement = true
        pickerStackView.alignment = .fill
        pickerStackView.isUserInteractionEnabled = true

        containerView.addArrangedSubview(pickerStackView)
        
        let actionStackView = UIStackView()
        actionStackView.spacing = 24
        actionStackView.axis = .vertical
        actionStackView.alignment = .center
        actionStackView.layoutMargins = UIEdgeInsets(top: 32, left: 129, bottom: 56, right: 129)
        actionStackView.isLayoutMarginsRelativeArrangement = true
        actionStackView.isUserInteractionEnabled = true
        
        containerView.addArrangedSubview(actionStackView)

        let titleLabel = MultilineLabel(
            value: String("Byt startdatum"),
            style: .startDateTitle
        )
      
        bag += textStackView.addArranged(titleLabel)

        let descriptionLabel = MultilineLabel(
            value: String("Vilket datum vill du att din försäkring aktiveras?"),
            style: .startDateDescription
        )
        
        bag += textStackView.addArranged(descriptionLabel)
        
        let picker = UIDatePicker()
        
        picker.calendar = Calendar.current
        picker.datePickerMode = .date
        picker.minimumDate = Date()
        picker.maximumDate = Calendar.current.date(byAdding: .year, value: 1, to: Date())

        pickerStackView.addArrangedSubview(picker)
        
        let chooseDateButton = Button(title: "Välj datum", type: .standard(backgroundColor: .primaryTintColor, textColor: .white))
        let activateNowButton = Button(title: "Aktivera idag", type: .transparent(textColor: .primaryTintColor))
        
        bag += actionStackView.addArranged(chooseDateButton)
        bag += actionStackView.addArranged(activateNowButton)
        
        bag += chooseDateButton.onTapSignal.onValue({ date in
            let dateChoosen = picker.date
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd"
            dateFormatter.timeZone = NSTimeZone.local
            print("Date Choosen: \(dateFormatter.string(from: dateChoosen))")
        })
        
        bag += activateNowButton.onTapSignal.onValue({ _ in
            print("Start Today: \(Date())")
        })

        return (viewController, Future { _ in
            bag
        })
    }
}
