import Combine
import Flow
import Foundation
import Presentation
import SwiftUI
import UIKit
import hAnalytics
import hCore
import hCoreUI

struct SlideTrack: View {
    var shouldAnimate: Bool
    var labelOpacity: Double

    var body: some View {
        ZStack {
            VStack(alignment: .center) {
                L10n.claimsPledgeSlideLabel.hText(.body)
            }
            .frame(maxWidth: .infinity)
            .opacity(labelOpacity)
            .animation(shouldAnimate && labelOpacity == 1 ? .easeInOut : nil)
        }
        .frame(height: 50)
        .frame(maxWidth: .infinity)
        .background(hBackgroundColor.secondary)
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
    var shouldAnimate: Bool
    var dragOffsetX: CGFloat
    static var size = CGSize(width: 50, height: 50)

    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                ZStack {
                    Image(uiImage: Asset.continue.image)
                }
                .frame(width: SlideDragger.size.width, height: SlideDragger.size.height)
                .background(hTintColor.lavenderOne)
                .clipShape(Circle())
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .modifier(
                DraggerGeometryEffect(
                    dragOffsetX: dragOffsetX,
                    draggerSize: SlideDragger.size
                )
            )
            .animation(shouldAnimate && dragOffsetX == 0 ? .spring() : nil)
        }
    }
}

struct DidAcceptPledgeNotifier: View {
    var canNotify: Bool
    var dragOffsetX: CGFloat

    @State var hasNotifiedStore = false
    @PresentableStore var store: UgglanStore

    var body: some View {
        GeometryReader { geo in
            Color.clear.onReceive(
                Just(canNotify && dragOffsetX > (geo.size.width - SlideDragger.size.width))
            ) { value in
                if value && !hasNotifiedStore {
                    hasNotifiedStore = true
                    store.send(.didAcceptHonestyPledge)
                    hAnalyticsEvent.honorPledgeConfirmed().send()
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
                shouldAnimate: hasDraggedOnce,
                labelOpacity: labelOpacity
            )
            SlideDragger(
                shouldAnimate: hasDraggedOnce,
                dragOffsetX: dragOffsetX
            )
        }
        .background(
            DidAcceptPledgeNotifier(
                canNotify: hasDraggedOnce,
                dragOffsetX: dragOffsetX
            )
        )
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

struct HonestyPledge: View {
    @PresentableStore var store: UgglanStore

    var body: some View {
        hForm {
            VStack {
                HStack {
                    L10n.honestyPledgeDescription.hText(.body)
                        .foregroundColor(hLabelColor.secondary)
                }
                .padding(.bottom, 20)
                SlideToConfirm()
                    .frame(maxHeight: 50)
            }
            .padding(.bottom, 20)
            .padding(.leading, 15)
            .padding(.trailing, 15)
        }
        .trackOnAppear(hAnalyticsEvent.screenView(screen: .claimHonorPledge))
    }
}

extension HonestyPledge {
    static func journey<Next: JourneyPresentation>(
        @JourneyBuilder _ next: @escaping () -> Next
    ) -> some JourneyPresentation {
        HostingJourney(
            UgglanStore.self,
            rootView: HonestyPledge(),
            style: .detented(.scrollViewContentSize),
            options: [
                .defaults, .prefersLargeTitles(true), .largeTitleDisplayMode(.always),
                .allowSwipeDismissAlways,
            ]
        ) { action in
            if case .didAcceptHonestyPledge = action {
                next()
            }
        }
        .configureTitle(L10n.honestyPledgeTitle)
        .withDismissButton
    }
}
