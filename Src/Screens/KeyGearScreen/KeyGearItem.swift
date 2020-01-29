//
//  KeyGearItem.swift
//  test
//
//  Created by Sam Pettersson on 2020-01-27.
//

import Foundation
import Flow
import UIKit
import Apollo
import Presentation
import Form

struct KeyGearItem {
    let name: String
    
    class KeyGearItemViewController: UIViewController {
        override func viewWillAppear(_ animated: Bool) {
            self.navigationController!.navigationBar.setBackgroundImage(UIImage(), for: .default)
            self.navigationController!.navigationBar.setBackgroundImage(UIImage(), for: .compact)
            self.navigationController!.navigationBar.barTintColor = UIColor.transparent
            self.navigationController!.navigationBar.isTranslucent = true
            self.navigationController!.navigationBar.shadowImage = UIImage()
        }
    }
}

extension KeyGearItem: Presentable {
    func materialize() -> (UIViewController, Disposable) {
        let viewController = KeyGearItemViewController()
        let bag = DisposeBag()
        
        viewController.title = name
        
        let scrollView = UIScrollView()
        scrollView.backgroundColor = .primaryBackground
        
        let form = FormView()
        bag += form.didLayoutSignal.take(first: 1).onValue { _ in
            form.dynamicStyle = DynamicFormStyle.defaultGrouped.restyled({ (style: inout FormStyle) in
                style.insets = UIEdgeInsets(top: -(scrollView.safeAreaInsets.top), left: 0, bottom: 0, right: 0)
            })
        }
        
        bag += viewController.install(form, scrollView: scrollView)
        
        bag += form.prepend(KeyGearImageCarousel()) { imageCarouselView in
            bag += scrollView.contentOffsetSignal.onValue({ offset in
                let realOffset = offset.y + scrollView.safeAreaInsets.top
                
                if realOffset < 0 {
                    imageCarouselView.transform = CGAffineTransform(translationX: 0, y: realOffset * 0.5).concatenating(CGAffineTransform(scaleX: 1 + abs(realOffset / imageCarouselView.frame.height), y: 1 + abs(realOffset / imageCarouselView.frame.height)))
                } else {
                    imageCarouselView.transform = CGAffineTransform.identity
                }
                
            })
        }
        
        let section = form.appendSection()
        
        Array(repeating: 1, count: 300).forEach { _ in
            section.append(RowView(title: "Namn"))
        }
        
        return (viewController, bag)
    }
}
