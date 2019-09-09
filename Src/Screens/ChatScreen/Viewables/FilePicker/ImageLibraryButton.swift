//
//  ImageLibraryButton.swift
//  project
//
//  Created by Sam Pettersson on 2019-09-09.
//

import Foundation
import UIKit
import Flow

struct ImageLibraryButton {}

extension ImageLibraryButton: Viewable {
    func materialize(events: ViewableEvents) -> (UIView, Signal<Void>) {
        let bag = DisposeBag()
        
        let button = UIControl()
        
        return (button, Signal<Void> { callback -> Disposable in
            
            return bag
        })
    }
}
