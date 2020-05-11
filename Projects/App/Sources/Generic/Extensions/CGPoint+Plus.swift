//
//  CGPoint+Plus.swift
//  project
//
//  Created by Sam Pettersson on 2019-09-02.
//

import Foundation
import UIKit

func + (lhs: CGPoint, rhs: CGPoint) -> CGPoint {
    return CGPoint(x: lhs.x + rhs.x, y: lhs.y + rhs.y)
}
