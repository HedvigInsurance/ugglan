//
//  ImageLibraryButton.swift
//  project
//
//  Created by Sam Pettersson on 2019-09-09.
//

import Foundation
import UIKit
import Flow
import Form

struct ImageLibraryButton {}

extension ImageLibraryButton: Reusable {
    static func makeAndConfigure() -> (make: UIView, configure: (ImageLibraryButton) -> Disposable) {
        let view = UIView()
        
        return (view, { `self` in
            let bag = DisposeBag()
            
            bag += view.add(self) { buttonView in
                buttonView.snp.makeConstraints { make in
                    make.width.height.equalToSuperview()
                }
            }.onValue({ _ in
                
            })
            
            return bag
        })
    }
}

extension ImageLibraryButton: Viewable {
    func materialize(events: ViewableEvents) -> (UIView, Signal<Void>) {
        let bag = DisposeBag()
        
        let button = UIControl()
        button.backgroundColor = .green
        
        return (button, Signal<Void> { callback -> Disposable in
            
            return bag
        })
    }
}
