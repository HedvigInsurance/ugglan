//
//  PieChartDebugger.swift
//  ForeverExample
//
//  Created by sam on 4.6.20.
//  Copyright © 2020 Hedvig AB. All rights reserved.
//

import Flow
import Forever
import Form
import Foundation
import Presentation
import UIKit

struct PieChartDebugger {}

extension PieChartDebugger: Presentable {
    func materialize() -> (UIViewController, Disposable) {
        let viewController = UIViewController()
        viewController.title = "Pie chart debugger"

        let bag = DisposeBag()

        let form = FormView()

        let section = form.appendSection(headerView: UILabel(value: "Pie chart", style: .default), footerView: nil)

        let pieChartContainer = UIStackView()
        section.append(pieChartContainer)

        let pieChartStateSignal = ReadWriteSignal<PieChartState>(PieChartState(percentagePerSlice: 0, slices: 0))

        bag += pieChartContainer.addArranged(PieChart(stateSignal: pieChartStateSignal))

        let sliceChangerRow = RowView(title: "Number of slices (stepper)")
        let sliceChangerStepper = UIStepper()
        sliceChangerStepper.maximumValue = 20

        bag += sliceChangerStepper.signal(for: .touchUpInside).onValue {
            pieChartStateSignal.value = PieChartState(percentagePerSlice: 0.05, slices: CGFloat(sliceChangerStepper.value))
        }

        sliceChangerRow.append(sliceChangerStepper)

        section.append(sliceChangerRow)
        
        let sliceChangerTextFieldRow = RowView(title: "Number of slices (text field)")
        let sliceChangerTextField = UITextField(value: "1.0", placeholder: "", style: .default)
        sliceChangerTextField.keyboardType = .numberPad
        
        bag += sliceChangerStepper.signal(for: .touchUpInside).map { String(sliceChangerStepper.value) }.bindTo(sliceChangerTextField, \.value)
        
        sliceChangerTextFieldRow.append(sliceChangerTextField)
        
        bag += sliceChangerTextField.shouldReturn.set { _ -> Bool in
            return true
        }
        
        bag += sliceChangerTextField.signal(for: .primaryActionTriggered).map { sliceChangerTextField.value }.onValue { newValue in
            if let floatValue = Float(newValue) {
                let cgFloatValue = CGFloat(floatValue)
                pieChartStateSignal.value = PieChartState(percentagePerSlice: 0.05, slices: cgFloatValue)
            }
        }
        
        section.append(sliceChangerTextFieldRow)

        bag += viewController.install(form)

        return (viewController, bag)
    }
}
