import Flow
import Foundation
import hCore
import UIKit

struct Blob: Viewable {
	let color: UIColor
	let position: Position
	let respectsHeight: Bool

	enum Position { case top, bottom }

	init(
		color: UIColor,
		position: Position,
		respectsHeight: Bool = true
	) {
		self.color = color
		self.position = position
		self.respectsHeight = respectsHeight
	}

	func materialize(events _: ViewableEvents) -> (UIView, Disposable) {
		let bag = DisposeBag()
		let containerView = UIView()

		let view = UIView()
		view.clipsToBounds = true

		containerView.addSubview(view)

		let shapeLayer = CAShapeLayer()
		view.layer.addSublayer(shapeLayer)

		bag += merge(containerView.didLayoutSignal, containerView.traitCollectionSignal.toVoid().plain())
			.map { (view.layer.frame.width, self.color.cgColor) }
			.distinct { (a, b) -> Bool in a.0 != b.0 && a.1 != b.1 }
			.onValue { width, color in shapeLayer.fillColor = color

				containerView.snp.remakeConstraints { make in
					make.height.equalTo(self.respectsHeight ? 44 : 0)
					make.width.equalToSuperview()
				}

				view.snp.remakeConstraints { make in make.width.equalToSuperview()
					make.height.equalTo(44)
				}

				let shape: UIBezierPath

				switch self.position {
				case .top:
					shape = UIBezierPath()
					shape.move(to: CGPoint(x: 0.5 * width, y: 83.07))
					shape.addCurve(
						to: CGPoint(x: 1 * width, y: 43.21),
						controlPoint1: CGPoint(x: 0.77 * width, y: 100.63),
						controlPoint2: CGPoint(x: 1 * width, y: 67.45)
					)
					shape.addCurve(
						to: CGPoint(x: 0.4 * width, y: 12.83),
						controlPoint1: CGPoint(x: 1 * width, y: 18.96),
						controlPoint2: CGPoint(x: 0.66 * width, y: -20.54)
					)
					shape.addCurve(
						to: CGPoint(x: 0, y: 43.21),
						controlPoint1: CGPoint(x: 0.14 * width, y: 46.19),
						controlPoint2: CGPoint(x: 0, y: 18.96)
					)
					shape.addCurve(
						to: CGPoint(x: 0.5 * width, y: 83.07),
						controlPoint1: CGPoint(x: 0, y: 67.45),
						controlPoint2: CGPoint(x: 0.23 * width, y: 65.51)
					)
					shape.close()
				case .bottom:
					shape = UIBezierPath()
					shape.move(to: CGPoint(x: 0.5 * width, y: 39.07))
					shape.addCurve(
						to: CGPoint(x: 1 * width, y: -0.79),
						controlPoint1: CGPoint(x: 0.77 * width, y: 56.63),
						controlPoint2: CGPoint(x: 1 * width, y: 23.45)
					)
					shape.addCurve(
						to: CGPoint(x: 0.4 * width, y: -31.17),
						controlPoint1: CGPoint(x: 1 * width, y: -25.04),
						controlPoint2: CGPoint(x: 0.66 * width, y: -64.54)
					)
					shape.addCurve(
						to: CGPoint(x: 0, y: -0.79),
						controlPoint1: CGPoint(x: 0.14 * width, y: 2.19),
						controlPoint2: CGPoint(x: 0, y: -25.04)
					)
					shape.addCurve(
						to: CGPoint(x: 0.5 * width, y: 39.07),
						controlPoint1: CGPoint(x: 0, y: 23.45),
						controlPoint2: CGPoint(x: 0.23 * width, y: 21.51)
					)
					shape.close()
				}

				shapeLayer.path = shape.cgPath
			}

		return (containerView, bag)
	}
}
