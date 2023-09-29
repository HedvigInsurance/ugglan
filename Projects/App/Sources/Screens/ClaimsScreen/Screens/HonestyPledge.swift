import Claims
import Combine
import Flow
import Foundation
import Presentation
import Profile
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
                    .foregroundColor(getLabelColor)

            }
            .frame(maxWidth: .infinity)
            .opacity(didFinished ? 0 : labelOpacity)
            .animation(shouldAnimate && labelOpacity == 1 ? .easeInOut : nil)
        }
        .frame(height: 58)
        .frame(maxWidth: .infinity)
        .background(hFillColor.opaqueTwo)
        .cornerRadius(29)
    }

    @hColorBuilder
    private var getLabelColor: some hColor {
        if didFinished {
            hTextColor.disabled
        } else {
            hTextColor.secondary
        }
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
                        Group {
                            if didFinished {
                                Image(uiImage: hCoreUIAssets.tick.image)
                                    .transition(.scale)
                            } else {
                                Image(uiImage: hCoreUIAssets.chevronRight.image)
                                    .transition(.asymmetric(insertion: .scale, removal: .opacity))
                            }
                        }
                        .foregroundColor(hTextColor.negative)
                        .frame(width: SlideDragger.size.width, height: SlideDragger.size.height)
                        .background(getIconBackgroundColor)
                        .clipShape(Circle())
                    }
                    .animation(.interpolatingSpring(stiffness: 300, damping: 20))
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

    @hColorBuilder
    private var getIconBackgroundColor: some hColor {
        if didFinished {
            hSignalColor.greenElement
        } else {
            hTextColor.primary
        }
    }
}

struct DidAcceptPledgeNotifier: View {
    var canNotify: Bool
    var dragOffsetX: CGFloat
    let onConfirmAction: (() -> Void)?
    @Binding var hasNotifiedStore: Bool
    @PresentableStore var store: ClaimsStore
    var body: some View {
        GeometryReader { geo in
            Color.clear.onReceive(
                Just(canNotify && dragOffsetX > (geo.size.width - SlideDragger.size.width))
            ) { value in
                if value && !hasNotifiedStore {
                    hasNotifiedStore = true
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                        onConfirmAction?()
                        store.send(.didAcceptHonestyPledge)
                    }
                }
            }
        }
    }
}

struct SlideToConfirm: View {
    @State var hasDraggedOnce = false
    @GestureState var dragOffsetX: CGFloat = 0
    @State var draggedTillTheEnd = false
    let onConfirmAction: (() -> Void)?

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
            .padding(.all, 4)
        }
        .background(
            DidAcceptPledgeNotifier(
                canNotify: hasDraggedOnce,
                dragOffsetX: dragOffsetX,
                onConfirmAction: onConfirmAction,
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
    }
}

struct HonestyPledge: View {
    let onConfirmAction: (() -> Void)?

    init(
        onConfirmAction: (() -> Void)?
    ) {
        self.onConfirmAction = onConfirmAction
    }

    var body: some View {
        hForm {
            VStack(alignment: .leading, spacing: 0) {
                L10n.honestyPledgeTitle.hText(.body)
                    .foregroundColor(hTextColor.primary)
                    .padding(.bottom, 8)
                HStack {
                    L10n.honestyPledgeDescription.hText(.body)
                        .foregroundColor(hTextColor.secondary)
                }
                .padding(.bottom, 32)

                SlideToConfirm(onConfirmAction: {
                    onConfirmAction?()
                })
                .frame(maxHeight: 50)
                .padding(.bottom, 20)

                hButton.LargeButton(type: .ghost) {
                    let store: SubmitClaimStore = globalPresentableStoreContainer.get()
                    store.send(.dissmissNewClaimFlow)
                } content: {
                    L10n.generalCancelButton.hText(.body)
                        .foregroundColor(hTextColor.primary)
                }

            }
            .padding(.horizontal, 24)
            .fixedSize(horizontal: false, vertical: true)
        }
        .hDisableScroll
    }
}

extension HonestyPledge {
    static func journey<Next: JourneyPresentation>(
        style: PresentationStyle,
        @JourneyBuilder _ next: @escaping () -> Next
    ) -> some JourneyPresentation {
        HostingJourney(
            ClaimsStore.self,
            rootView: HonestyPledge(onConfirmAction: nil),
            style: style,
            options: [
                .defaults, .blurredBackground,
            ]
        ) { action in
            if case .didAcceptHonestyPledge = action {
                next()
            }
        }
        .withDismissButton
    }
}

extension HonestyPledge {
    @ViewBuilder
    static func journey(from origin: ClaimsOrigin) -> some View {
        HonestyPledge {
            let profileStore: ProfileStore = globalPresentableStoreContainer.get()
            if profileStore.state.pushNotificationCurrentStatus() != .authorized {
                let store: SubmitClaimStore = globalPresentableStoreContainer.get()
                store.send(.navigationAction(action: .openNotificationsPermissionScreen))
            } else {
                if #available(iOS 15.0, *) {
                    let vc = UIApplication.shared.getTopViewController()
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                        vc?.sheetPresentationController?.presentedViewController.view.alpha = 0
                    }
                }
                let store: SubmitClaimStore = globalPresentableStoreContainer.get()
                store.send(.navigationAction(action: .dismissPreSubmitScreensAndStartClaim(origin: origin)))

            }
        }
        .hDisableScroll
    }
}
