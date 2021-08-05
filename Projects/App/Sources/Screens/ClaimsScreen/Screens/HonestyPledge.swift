import Combine
import Flow
import Foundation
import Presentation
import SwiftUI
import UIKit
import hCore
import hCoreUI

struct SlideTrack: View {
	var hasDraggedOnce: Bool
	var labelOpacity: Double

	var body: some View {
		ZStack {
			VStack(alignment: .center) {
				hText(text: L10n.claimsPledgeSlideLabel, style: .body)
			}
			.frame(maxWidth: .infinity)
			.opacity(labelOpacity)
			.animation(hasDraggedOnce && labelOpacity == 1 ? .easeInOut : nil)
		}
		.frame(height: 50)
		.frame(maxWidth: .infinity)
		.background(Color(UIColor.brand(.primaryBackground())))
		.cornerRadius(25)
	}
}

struct DraggerGeometryEffect: GeometryEffect {
	var dragOffsetX: CGFloat
	var draggerSize: CGSize

	var animatableData: CGFloat {
		get { dragOffsetX }
		set { dragOffsetX = newValue }
	}

	func effectValue(size: CGSize) -> ProjectionTransform {
		let value = max(dragOffsetX, 0)
		let finalOffsetX = min(value, size.width - draggerSize.width)
		return ProjectionTransform(CGAffineTransform(translationX: finalOffsetX, y: 0))
	}
}

struct SlideDragger: View {
	var hasDraggedOnce: Bool
	var dragOffsetX: CGFloat
	var size = CGSize(width: 50, height: 50)
	@State var hasNotifiedStore = false

	@PresentableStore var store: UgglanStore

	var body: some View {
		GeometryReader { geo in
			ZStack(alignment: .leading) {
				ZStack {
					Image(uiImage: Asset.continue.image)
				}
				.frame(width: size.width, height: size.height)
				.background(Color(UIColor.brand(.link)))
				.clipShape(Circle())
			}
			.frame(maxWidth: .infinity, alignment: .leading)
			.modifier(
				DraggerGeometryEffect(
					dragOffsetX: dragOffsetX,
					draggerSize: size
				)
			)
			.animation(hasDraggedOnce && dragOffsetX == 0 ? .spring() : nil)
			.onReceive(Just(hasDraggedOnce && dragOffsetX > (geo.size.width - size.width))) { value in
				if value && !hasNotifiedStore {
					hasNotifiedStore = true
					store.send(.didAcceptHonestyPledge)
				}
			}
		}
	}
}

struct SlideToConfirm: View {
	@State var hasDraggedOnce = false
	@GestureState var dragOffsetX: CGFloat = 0

	var labelOpacity: Double {
		1 - (Double(max(dragOffsetX, 0)) / 100)
	}

	var body: some View {
		ZStack(alignment: .leading) {
			SlideTrack(
				hasDraggedOnce: hasDraggedOnce,
				labelOpacity: labelOpacity
			)
			SlideDragger(
				hasDraggedOnce: hasDraggedOnce,
				dragOffsetX: dragOffsetX
			)
		}
		.gesture(
			DragGesture()
				.updating(
					$dragOffsetX,
					body: { value, state, _ in
						if value.startLocation.x > 50 {
							state =
								(value.startLocation.x
									* (value.translation.width / 100))
								+ value.translation.width
						} else {
							state = value.translation.width
						}
					}
				)
				.onChanged({ _ in
					hasDraggedOnce = true
				})
		)
	}
}

struct HonestyPledge: PresentableView {
	typealias Result = Signal<Void>
	@PresentableStore var store: UgglanStore

	var result: Signal<Void> {
		Signal { callback in
			let bag = DisposeBag()

			bag += store.onAction(
				.didAcceptHonestyPledge,
				{
					callback(())
				}
			)

			return bag
		}
	}

	var body: some View {
		hForm {
			VStack {
				HStack {
					hText(text: L10n.honestyPledgeDescription, style: .body)
						.fixedSize(horizontal: false, vertical: true)
						.foregroundColor(Color(UIColor.brand(.secondaryText)))
				}
				.padding(.bottom, 20)
				SlideToConfirm()
			}
			.padding(.bottom, 20)
			.padding(.leading, 15)
			.padding(.trailing, 15)
		}
		.presentableTitle(L10n.honestyPledgeTitle)
	}
}
