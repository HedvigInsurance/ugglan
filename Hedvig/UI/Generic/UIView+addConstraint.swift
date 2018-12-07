//
//  UIView+addConstraint.swift
//  Hedvig
//
//  Created by Sam Pettersson on 2018-12-07.
//  Copyright © 2018 Hedvig AB. All rights reserved.
//

import Flow
import Foundation
import SnapKit
import UIKit

extension UIView {
    func makeConstraints(wasAdded: Signal<Void>) -> Future<(ConstraintMaker, UILayoutGuide)> {
        return Future { completion in
            let bag = DisposeBag()

            bag += wasAdded.onValue({ _ in
                self.snp.makeConstraints({ make in
                    if #available(iOS 11.0, *) {
                        if let safeAreaLayoutGuide = self.superview?.safeAreaLayoutGuide {
                            completion(.success((make, safeAreaLayoutGuide)))
                        }
                    }

                    completion(.success((make, self.layoutMarginsGuide)))
                })
            })

            return bag
        }
    }
}
