import Foundation
import UIKit

public class TopAlignedCollectionViewFlowLayout: UICollectionViewFlowLayout {
    override public func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        var attrsCopy = [UICollectionViewLayoutAttributes]()

        if let attrs = super.layoutAttributesForElements(in: rect) {
            for element in attrs {
                if let elementCopy = element.copy() as? UICollectionViewLayoutAttributes {
                    if elementCopy.representedElementCategory == .cell {
                        elementCopy.frame.origin.y = 0
                    }

                    attrsCopy.append(elementCopy)
                }
            }
        }

        return attrsCopy
    }
}
