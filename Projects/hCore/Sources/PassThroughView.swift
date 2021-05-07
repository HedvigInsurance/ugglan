import Foundation
import UIKit

public class PassTroughView: UIView {
	override public func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
		let hitView = super.hitTest(point, with: event)

		if hitView == self { return nil }

		return hitView
	}
}
