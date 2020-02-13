//
//  KeyGearCategoryChooser.swift
//  test
//
//  Created by Pavel Barros Quintanilla on 2020-02-05.
//

import Foundation
import Flow
import Form
import Presentation
import UIKit

class KeyGearCategoryChooser {
//    var buttonArray: [KeyGearCategoryButton] = []
    var isMarked: Bool = false

//    init(buttonArray: [KeyGearCategoryButton] = []) {
//        self.buttonArray = buttonArray
//    }
}

enum KeyGearCategory: String, CaseIterable {
    case computer = "Computer"
    case cellphone = "Cellphone"
    case jewlery = "Jewlery"
    case camera = "Camera"
    case bicycle = "Bicycle"
    case watch = "Watch"
    case other = "Other"
}

extension KeyGearCategoryChooser: Viewable {
    func materialize(events: ViewableEvents) -> (UIView, Disposable) {
//        let view = UIView()
        let bag = DisposeBag()

        
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.scrollDirection = .horizontal

        let collectionKit = CollectionKit<EmptySection, KeyGearListButton>(
            table: Table(),
            layout: flowLayout,
            holdIn: bag
        )

        bag += collectionKit.delegate.sizeForItemAt.set { _ -> CGSize in
            CGSize(
                width: min(85, collectionKit.view.frame.width / 4),
                height: 85
            )
        }
        
        collectionKit.view.backgroundColor = .blue

        let allButtons = KeyGearCategory.allCases.map { category in
            KeyGearListButton(title: category.rawValue)
        }
        
        allButtons.forEach { button in
            collectionKit.table.append(button)
        }
        

        
//MARK:-
//        bag += allButtons.map { button in
////            (button, collectionKit.table = Table(rows: button))
//        }.map { button, onTapSignal in
//            onTapSignal.onValue { _ in
//
//                print("THIS: \(button.title) = \(button.selectedSignal.value)")
//
//                buttons.forEach { innerButton in
//                    print(innerButton.title, innerButton.selectedSignal.value)
//
//                    if button.selectedSignal.value == true {
//                        innerButton.selectedSignal.value = false
//                        button.selectedSignal.value = false
//
//                    } else {
//                        innerButton.selectedSignal.value = false
//                        button.selectedSignal.value = true
//                    }
//
//                }
//
//            }
//        }
        
        return (collectionKit.view, bag)
    }
}



