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

struct SafeArea {
    let insets: UIEdgeInsets
    let layoutGuide: UILayoutGuide
}

extension UIView {
    func makeConstraints(wasAdded: Signal<Void>) -> Future<(ConstraintMaker, SafeArea)> {
        return Future { completion in
            let bag = DisposeBag()

            bag += wasAdded.onValue { _ in
                self.snp.makeConstraints { make in
                    if let safeAreaLayoutGuide = self.superview?.safeAreaLayoutGuide,
                        let safeAreaInsets = self.superview?.safeAreaInsets {
                        completion(
                            .success(
                                (
                                    make,
                                    SafeArea(
                                        insets: safeAreaInsets,
                                        layoutGuide: safeAreaLayoutGuide
                                    )
                                )
                            )
                        )
                    }

                    completion(
                        .success(
                            (
                                make,
                                SafeArea(
                                    insets: self.layoutMargins,
                                    layoutGuide: self.layoutMarginsGuide
                                )
                            )
                        )
                    )
                }
            }

            return bag
        }
    }
}
