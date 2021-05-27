import Flow
import Foundation
import UIKit

extension UIControl {
	public static var trackingHandler: (_ button: UIControl) -> Void = { _ in }

	/// Triggers on touchUpInside and uses accessibilityLabel to trigger an analytics event
	public var trackedTouchUpInsideSignal: Signal<Void> {
		signal(for: .touchUpInside).atValue { Self.trackingHandler(self) }
	}
}
