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

struct ImageLibraryButton {
    let uploadFileDelegate = Delegate<Data, Signal<Bool>>()
}

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
        
        let containerView = UIStackView()
        containerView.axis = .vertical
        containerView.distribution = .fillEqually
        containerView.spacing = 5
        
        let cameraButton = UIControl()
        cameraButton.backgroundColor = .green
        bag += cameraButton.signal(for: .touchUpInside).onValue { _ in
            containerView.viewController?.present(ImagePicker(sourceType: .camera))
        }
        
        containerView.addArrangedSubview(cameraButton)
        
        let imagePickerButton = UIControl()
        imagePickerButton.backgroundColor = .red
        bag += imagePickerButton.signal(for: .touchUpInside).onValue { _ in
            containerView.viewController?.present(ImagePicker(sourceType: .photoLibrary))
        }
        
        containerView.addArrangedSubview(imagePickerButton)
        
        return (containerView, Signal<Void> { callback -> Disposable in
            return bag
        })
    }
}
