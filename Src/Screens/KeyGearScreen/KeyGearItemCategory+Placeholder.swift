//
//  KeyGearItemCategory+Placeholder.swift
//  test
//
//  Created by Sam Pettersson on 2020-02-20.
//

import Foundation
import UIKit

extension KeyGearItemCategory {
    var image: UIImage? {
        switch self {
        case .phone:
            return Asset.keyGearPhonePlaceholder.image
        case .smartWatch, .watch:
            return Asset.keyGearWatchPlacholder.image
        case .__unknown:
            return nil
        default:
            return nil
        }
    }
}
