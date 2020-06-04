//
//  PieChart.swift
//  Forever
//
//  Created by sam on 4.6.20.
//  Copyright © 2020 Hedvig AB. All rights reserved.
//

import Foundation
import UIKit
import hCoreUI
import hCore
import Flow

struct PieChartSlice {
    var percent: CGFloat
    var color: UIColor
}

struct PieChart {
    let slicesSignal: ReadWriteSignal<[PieChartSlice]>
    
    public init(slicesSignal: ReadWriteSignal<[PieChartSlice]>) {
        self.slicesSignal = slicesSignal
    }
    
    func percentToRadian(_ percent: CGFloat) -> CGFloat {
        //Because angle starts wtih X positive axis, add 270 degrees to rotate it to Y positive axis.
        var angle = 270 + percent * 360
        if angle >= 360 {
            angle -= 360
        }
        return angle * CGFloat.pi / 180.0
    }
}

extension PieChart: Viewable {
    func materialize(events: ViewableEvents) -> (UIStackView, Disposable) {
        let stackView = UIStackView()
        let bag = DisposeBag()
        
        let pieView = UIView()
        
        pieView.snp.makeConstraints { make in
            make.height.width.equalTo(215)
        }
        
        stackView.addArrangedSubview(pieView)
        
        func renderChart(slices: [PieChartSlice]) {
            
            slices.map { slice -> CAShapeLayer in
                
                let pieViewWidth = pieView.frame.width

                
                let path = UIBezierPath(arcCenter: pieView.center,
                                               radius: pieViewWidth * 3 / 8,
                                               startAngle: percentToRadian(0),
                                               endAngle: percentToRadian(0 + slice.percent),
                                               clockwise: true)
                       
               let sliceLayer = CAShapeLayer()
               sliceLayer.path = path.cgPath
               sliceLayer.fillColor = nil
               sliceLayer.strokeColor = slice.color.cgColor
               sliceLayer.lineWidth = pieViewWidth * 2 / 8
               sliceLayer.strokeEnd = 1
                
                return sliceLayer
            }.forEach { shapeLayer in
                pieView.layer.addSublayer(shapeLayer)
            }
            
        }
        
        bag += slicesSignal.onValue(renderChart)
        
        return (stackView, bag)
    }
}
