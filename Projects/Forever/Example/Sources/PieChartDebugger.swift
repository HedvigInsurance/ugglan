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
        
        let slicesSignal = ReadWriteSignal<[PieChartSlice]>([])
        
        bag += pieChartContainer.addArranged(PieChart(slicesSignal: slicesSignal))
        
        let sliceChangerRow = RowView(title: "Number of slices")
        let sliceChangerStepper = UIStepper()
                
        bag += sliceChangerStepper.signal(for: .touchUpInside).onValue {
            slicesSignal.value = Array(repeating: PieChartSlice(percent: 0.1, color: .brand(.primaryButtonBackgroundColor)), count: Int(sliceChangerStepper.value))
        }
        
        sliceChangerRow.append(sliceChangerStepper)
        
        section.append(sliceChangerRow)

        bag += viewController.install(form)

        return (viewController, bag)
    }
}
