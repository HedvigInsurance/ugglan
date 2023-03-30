import Claims
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
    @Binding var didFinished: Bool

    var body: some View {
        ZStack {
            VStack(alignment: .center) {
                L10n.claimsPledgeSlideLabel.hText(.body)
            }
            .frame(maxWidth: .infinity)
            .opacity(didFinished ? 0 : labelOpacity)
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
    @Binding var didFinished: Bool
    static let size = CGSize(width: 50, height: 50)

    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .leading) {
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
                        dragOffsetX: didFinished ? geo.size.width : dragOffsetX,
                        draggerSize: SlideDragger.size
                    )
                )
            }
            .animation(shouldAnimate && dragOffsetX == 0 ? .spring() : nil)
        }
    }
}

struct DidAcceptPledgeNotifier: View {
    var canNotify: Bool
    var dragOffsetX: CGFloat

    @Binding var hasNotifiedStore: Bool
    @PresentableStore var store: ClaimsStore
    var body: some View {
        GeometryReader { geo in
            Color.clear.onReceive(
                Just(canNotify && dragOffsetX > (geo.size.width - SlideDragger.size.width))
            ) { value in
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
    @State var draggedTillTheEnd = false
    var labelOpacity: Double {
        1 - (Double(max(dragOffsetX, 0)) / 100)
    }

    var body: some View {
        ZStack(alignment: .leading) {
            SlideTrack(
                shouldAnimate: hasDraggedOnce,
                labelOpacity: labelOpacity,
                didFinished: $draggedTillTheEnd
            )
            SlideDragger(
                shouldAnimate: hasDraggedOnce,
                dragOffsetX: dragOffsetX,
                didFinished: $draggedTillTheEnd
            )
        }
        .background(
            DidAcceptPledgeNotifier(
                canNotify: hasDraggedOnce,
                dragOffsetX: dragOffsetX,
                hasNotifiedStore: $draggedTillTheEnd
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
        .onAppear {
            self.draggedTillTheEnd = false
        }
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
        style: PresentationStyle,
        @JourneyBuilder _ next: @escaping () -> Next
    ) -> some JourneyPresentation {
        HostingJourney(
            ClaimsStore.self,
            rootView: HonestyPledge(),
            style: style,
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
