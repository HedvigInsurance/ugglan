//
//  WaveForm.swift
//  project
//
//  Created by Sam Pettersson on 2019-09-17.
//

import Foundation
import Flow
import UIKit
import AVKit

struct WaveForm {
    let audioRecorder: AVAudioRecorder
}

extension WaveForm: Viewable {
    func materialize(events: ViewableEvents) -> (UIView, Disposable) {
        let view = UIView()
        let bag = DisposeBag()
        
        view.backgroundColor = .primaryTintColor
        
        bag += view.didMoveToWindowSignal.take(first: 1).onValue { _ in
            view.snp.makeConstraints { make in
                make.width.equalTo(80)
                make.height.equalTo(35)
                make.center.equalToSuperview()
            }
        }
        
        view.transform = CGAffineTransform(translationX: 0, y: -80)
        view.layer.cornerRadius = 17.5
        
        var staples: [UIView] = []
        
        for _ in 1...20 {
            let staple = UIView()
            staple.backgroundColor = .white
                        
            staples.append(staple)
            view.addSubview(staple)
        }
        
        var pastPeakPower: [Float] = []
                
        bag += Signal(every: 1 / 60).onValue { _ in
            self.audioRecorder.updateMeters()
            pastPeakPower.append(self.audioRecorder.averagePower(forChannel: 0))
            pastPeakPower = pastPeakPower.suffix(20)
                        
            pastPeakPower.enumerated().forEach { offset, value in
                let normalizedValue: CGFloat = CGFloat(max(value, -60))
                let maxHeight: CGFloat = 15
                
                print(normalizedValue)
                
                let height = min(maxHeight * log10((normalizedValue / -60)), -1)
                                
                staples[offset].frame = CGRect(x: CGFloat(offset * 3) + 10, y: 20, width: 2, height: CGFloat(height))
                staples[offset].layoutIfNeeded()
            }
        }
        
        return (view, bag)
    }
}
