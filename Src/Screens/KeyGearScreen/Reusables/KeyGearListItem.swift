//
//  KeyGearListItem.swift
//  test
//
//  Created by Sam Pettersson on 2020-01-27.
//

import Foundation
import Flow
import Form

struct KeyGearListItem {
    let id: String
    let imageUrl: URL?
    let wasAddedAutomatically: Bool
    
    private let callbacker = Callbacker<Void>()
}


extension KeyGearListItem: SignalProvider {
    var providedSignal: Signal<Void> {
        return callbacker.providedSignal
    }
}


extension KeyGearListItem: Reusable {
    static func makeAndConfigure() -> (make: UIControl, configure: (KeyGearListItem) -> Disposable) {
        let view = UIControl()
        view.layer.cornerRadius = 8
        view.clipsToBounds = true
        view.backgroundColor = .secondaryBackground
        
        let imageView = UIImageView()
        imageView.isUserInteractionEnabled = false
        imageView.contentMode = .scaleAspectFill
        view.addSubview(imageView)
        
        imageView.snp.makeConstraints { make in
            make.top.bottom.leading.trailing.equalToSuperview()
        }
                
        let label = UILabel(value: "TODO", style: .headlineSmallNegSmallNegCenter)
        view.addSubview(label)
        
        label.snp.makeConstraints { make in
            make.width.equalToSuperview()
            make.bottom.equalToSuperview().inset(10)
        }
        
        label.sizeToFit()
        
        return (view, { `self` in
            let bag = DisposeBag()
            
            bag += view.applyBorderColor { trait -> UIColor in
                return UIColor.primaryBorder
            }
            
            let touchUpInsideSignal = view.trackedTouchUpInsideSignal
                  
            bag += touchUpInsideSignal.feedback(type: .impactLight)
          
            bag += view.signal(for: .touchDown).animated(style: AnimationStyle.easeOut(duration: 0.35)) {
                view.transform = CGAffineTransform(scaleX: 0.98, y: 0.98)
            }
                  
            bag += view.delayedTouchCancel(delay: 0.1).animated(style: AnimationStyle.easeOut(duration: 0.35)) {
                view.transform = CGAffineTransform.identity
            }
                        
            imageView.kf.setImage(with: self.imageUrl, options: [
                .preloadAllAnimationData,
                .transition(.fade(1)),
            ])
                        
            bag += view.signal(for: .touchUpInside).onValue { _ in
                self.callbacker.callAll()
            }
            
            return bag
        })
    }
}
