import Foundation
import UIKit

public class LeftAlignedCollectionViewFlowLayout: UICollectionViewFlowLayout {
    override public func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        let attributes = super.layoutAttributesForElements(in: rect)

        var leftMargin = sectionInset.left
        var maxY: CGFloat = -1.0
        attributes?
            .forEach { layoutAttribute in
                if layoutAttribute.frame.origin.y >= maxY { leftMargin = sectionInset.left }

                layoutAttribute.frame.origin.x = leftMargin

                leftMargin += layoutAttribute.frame.width + minimumInteritemSpacing
                maxY = max(layoutAttribute.frame.maxY, maxY)
            }

        return attributes
    }
}
