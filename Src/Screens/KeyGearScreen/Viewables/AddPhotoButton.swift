//
//  AddPhotoButton.swift
//  test
//
//  Created by Sam Pettersson on 2020-02-10.
//

import Foundation
import Flow
import UIKit

struct AddPhotoButton {}

extension AddPhotoButton: Viewable {
    func materialize(events: ViewableEvents) -> (UIView, Disposable) {
        let view = UIView()
        view.backgroundColor = .purple
        
        view.snp.makeConstraints { make in
            make.height.equalTo(300)
        }
        
        return (view, NilDisposer())
    }
}
