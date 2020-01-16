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
    
    var oneYearfromNow: Date {
       return (Calendar.current as NSCalendar).date(byAdding: .year, value: 1, to: Date(), options: [])!
    }
}

extension PresentStartDate: Presentable {
    func materialize() -> (UIViewController, Future<Void>) {
        let viewController = UIViewController()
        viewController.preferredContentSize = CGSize(width: 40, height: 511)

        let bag = DisposeBag()

        let containerView = UIStackView()
        containerView.axis = .vertical
        bag += containerView.applyPreferredContentSize(on: viewController)

        viewController.view = containerView

        let view = UIStackView()
        view.spacing = 8
        view.axis = .vertical
        view.layoutMargins = UIEdgeInsets(top: 32, left: 24, bottom: 32, right: 24)
        view.isLayoutMarginsRelativeArrangement = true
        view.isUserInteractionEnabled = true
        
        containerView.addArrangedSubview(view)
        
        let view2 = UIStackView()
        view2.spacing = 8
        view2.axis = .vertical
        view2.layoutMargins = UIEdgeInsets(horizontalInset: 15, verticalInset: 24)
        view2.isLayoutMarginsRelativeArrangement = true
        view2.isUserInteractionEnabled = true

        containerView.addArrangedSubview(view2)
        
        let view3 = UIStackView()
        view3.spacing = 24
        view3.axis = .vertical
        view3.alignment = .center
        view3.layoutMargins = UIEdgeInsets(top: 0, left: 129, bottom: 56, right: 129)
        view3.isLayoutMarginsRelativeArrangement = true
        view3.isUserInteractionEnabled = true
        
        containerView.addArrangedSubview(view3)

        let titleLabel = MultilineLabel(
            value: String("Ändra startdatum"),
            style: .draggableOverlayTitle
        )
        bag += view.addArranged(titleLabel)

        let descriptionLabel = MultilineLabel(
            value: String("Vilket datum vill du att din försäkring aktiveras?"),
            style: .bodyOffBlack
        )
        bag += view.addArranged(descriptionLabel)
        
        let picker = UIDatePicker()
        let calendar = Calendar.current
        let date = Date()
        var minComponents = DateComponents()
        
        minComponents.day = calendar.component(.day, from: date)
        minComponents.month = calendar.component(.month, from: date)
        minComponents.year = calendar.component(.year, from: date)

        picker.datePickerMode = .date
        picker.minimumDate = Calendar.current.date(from: minComponents)
        picker.maximumDate = Calendar.current.date(byAdding: .year, value: 1, to: Date())
        view2.addArrangedSubview(picker)
        
        
        
        let chooseDateButton = Button(title: "Välj datum", type: .standard(backgroundColor: .primaryTintColor, textColor: .white))
        let activateNowButton = Button(title: "Aktivera idag", type: .transparent(textColor: .primaryTintColor))
        
        bag += view3.addArranged(chooseDateButton)
        bag += view3.addArranged(activateNowButton)
        
        bag += chooseDateButton.onTapSignal.onValue({ (value) in
            print("Tapped")
            
        })
        
        bag += picker.onValue({ data in
            print(data)
        })
        
        bag += activateNowButton.onTapSignal.onValue({ _ in
            print(Date())
        })
        
        return (viewController, Future { _ in
            bag
        })
    }
}
