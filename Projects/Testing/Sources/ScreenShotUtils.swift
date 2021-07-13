import Flow
import Form
import Foundation
import SnapshotTesting
import UIKit
import XCTest
import hCore
import hCoreUI

public func setupScreenShotTests() {
	Localization.Locale.currentLocale = .en_SE
	DefaultStyling.installCustom()
	ApplicationContext.shared.hasFinishedBootstrapping = true
	UIView.setAnimationsEnabled(false)
	XCTAssertEqual(UIScreen.main.scale, 3)
	Fonts.forceTraitCollection = UITraitCollection(preferredContentSizeCategory: .medium)

	#if RECORD
		isRecording = true
	#endif
}

@discardableResult public func materializeViewable<View: Viewable>(
	_ viewable: View,
	onCreated: (_ view: View.Matter) -> Void
) -> Disposable where View.Events == ViewableEvents, View.Matter: UIView, View.Result == Disposable {
	let bag = DisposeBag()
	let (matter, result) = viewable.materialize(events: ViewableEvents(wasAddedCallbacker: Callbacker()))
	matter.layoutIfNeeded()
	bag += result
	onCreated(matter)
	return bag
}

@discardableResult public func materializeViewable<View: Viewable, SignalKind, SignalValue>(
	_ viewable: View,
	onCreated: (_ view: View.Matter) -> Void
) -> CoreSignal<SignalKind, SignalValue>
where View.Events == ViewableEvents, View.Matter: UIView, View.Result == CoreSignal<SignalKind, SignalValue> {
	let bag = DisposeBag()
	let (matter, result) = viewable.materialize(events: ViewableEvents(wasAddedCallbacker: Callbacker()))
	matter.layoutIfNeeded()
	onCreated(matter)
	return result.hold(bag)
}
