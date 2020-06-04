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

public struct PieChartSlice {
    public var percent: CGFloat
    public var color: UIColor
    
    public init(percent: CGFloat, color: UIColor) {
        self.percent = percent
        self.color = color
    }
}

public struct PieChart {
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
    public func materialize(events: ViewableEvents) -> (UIStackView, Disposable) {
        let stackView = UIStackView()
        let bag = DisposeBag()
        
        let pieView = UIView()
        
        pieView.snp.makeConstraints { make in
            make.height.width.equalTo(215)
        }
        
        stackView.addArrangedSubview(pieView)
        
        let pieBag = bag.innerBag()
        
        func renderChart(slices: [PieChartSlice]) {
            pieBag.dispose()
            var currPercent: CGFloat = 0
            
            slices.map { slice -> CAShapeLayer in
                
                let pieViewWidth: CGFloat = 100

                
                let path = UIBezierPath(arcCenter: pieView.center,
                                               radius: pieViewWidth * 3 / 8,
                                               startAngle: percentToRadian(currPercent),
                                               endAngle: percentToRadian(currPercent + slice.percent),
                                               clockwise: true)
                        
                currPercent += slice.percent
            
               let sliceLayer = CAShapeLayer()
               sliceLayer.path = path.cgPath
               sliceLayer.fillColor = nil
               sliceLayer.strokeColor = slice.color.cgColor
               sliceLayer.lineWidth = pieViewWidth - 25
                
                return sliceLayer
            }.forEach { shapeLayer in
                pieView.layer.addSublayer(shapeLayer)
                
                pieBag += {
                    shapeLayer.removeFromSuperlayer()
                }
            }
        }
        
        bag += combineLatest(self.slicesSignal.atOnce().plain().toVoid(), pieView.didLayoutSignal.toVoid()).onValue { _ in
            renderChart(slices: self.slicesSignal.value)
        }
                
        return (stackView, bag)
    }
}
