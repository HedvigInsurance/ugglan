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
    @Environment(\.hUseNewStyle) var hUseNewStyle
    @Binding var didFinished: Bool

    var body: some View {
        ZStack {
            VStack(alignment: .center) {
                if hUseNewStyle {
                    L10n.claimsPledgeSlideLabel.hTextNew(.body)
                        .foregroundColor(hLabelColorNew.secondary)
                } else {
                    L10n.claimsPledgeSlideLabel.hText(.body)
                }
            }
            .frame(maxWidth: .infinity)
            .opacity(didFinished ? 0 : labelOpacity)
            .animation(shouldAnimate && labelOpacity == 1 ? .easeInOut : nil)
        }
        .frame(height: hUseNewStyle ? 58 : 50)
        .frame(maxWidth: .infinity)
        .background(backgroundColor)
        .cornerRadius(hUseNewStyle ? 29 : 25)
    }

    @hColorBuilder
    private var backgroundColor: some hColor {
        if hUseNewStyle {
            hFillColorNew.opaqueTwo
        } else {
            hBackgroundColor.secondary
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
    @Environment(\.hUseNewStyle) var hUseNewStyle
    static let size = CGSize(width: 50, height: 50)

    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                ZStack(alignment: .leading) {
                    ZStack {
                        if hUseNewStyle {
                            Image(uiImage: hCoreUIAssets.chevronRightRevamp.image)
                                .foregroundColor(hLabelColorNew.primary.inverted)
                        } else {
                            Image(uiImage: Asset.continue.image)
                        }
                    }
                    .frame(width: SlideDragger.size.width, height: SlideDragger.size.height)
                    .background(background)
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

    @hColorBuilder
    private var background: some hColor {
        if hUseNewStyle {
            hLabelColorNew.primary
        } else {
            hTintColor.lavenderOne
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
                    onConfirmAction?()
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
    let onConfirmAction: (() -> Void)?
    @Environment(\.hUseNewStyle) var hUseNewStyle

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
            .padding(.all, hUseNewStyle ? 4 : 0)
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
    @Environment(\.hUseNewStyle) var hUseNewStyle
    let onConfirmAction: (() -> Void)?

    init(
        onConfirmAction: (() -> Void)?
    ) {
        self.onConfirmAction = onConfirmAction
    }

    var body: some View {
        hForm {
            VStack(alignment: .leading, spacing: 0) {
                if hUseNewStyle {
                    L10n.honestyPledgeTitle.hTextNew(.body)
                        .foregroundColor(hLabelColorNew.primary)
                        .padding(.bottom, 8)
                }
                HStack {
                    L10n.honestyPledgeDescription.hText(.body)
                        .foregroundColor(hLabelColor.secondary)
                }
                .padding(.bottom, hUseNewStyle ? 32 : 20)

                SlideToConfirm(onConfirmAction: onConfirmAction)
                    .frame(maxHeight: 50)
                    .padding(.bottom, 20)
                if hUseNewStyle {
                    hButton.LargeButtonText {
                        let store: SubmitClaimStore = globalPresentableStoreContainer.get()
                        store.send(.dissmissNewClaimFlow)
                    } content: {
                        L10n.generalCancelButton.hTextNew(.body)
                            .foregroundColor(hLabelColorNew.primary)
                    }
                }

            }
            .padding(.top, hUseNewStyle ? -32 : 0)
            .padding(.horizontal, hUseNewStyle ? 24 : 15)
            .fixedSize(horizontal: false, vertical: true)
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
            rootView: HonestyPledge(onConfirmAction: nil),
            style: style,
            options: [
                .defaults, .prefersLargeTitles(true), .largeTitleDisplayMode(.always),
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

extension HonestyPledge {
    @ViewBuilder
    static func journey(from origin: ClaimsOrigin) -> some View {
        if hAnalyticsExperiment.claimsTriaging {
            HonestyPledge {
                let ugglanStore: UgglanStore = globalPresentableStoreContainer.get()
                if ugglanStore.state.pushNotificationCurrentStatus() != .authorized {
                    let store: SubmitClaimStore = globalPresentableStoreContainer.get()
                    store.send(.navigationAction(action: .openNotificationsPermissionScreen))
                } else {
                    let store: SubmitClaimStore = globalPresentableStoreContainer.get()
                    store.send(.navigationAction(action: .dismissPreSubmitScreensAndStartClaim(origin: origin)))
                }
            }
            .hUseNewStyle
            .hDisableScroll
        } else {
            HonestyPledge {
                let ugglanStore: UgglanStore = globalPresentableStoreContainer.get()
                if ugglanStore.state.pushNotificationCurrentStatus() != .authorized {
                    let store: SubmitClaimStore = globalPresentableStoreContainer.get()
                    store.send(.navigationAction(action: .openNotificationsPermissionScreen))
                } else {
                    let store: SubmitClaimStore = globalPresentableStoreContainer.get()
                    if hAnalyticsExperiment.claimsTriaging {
                        store.send(.navigationAction(action: .openNewTriagingScreen))
                    } else {
                        store.send(.navigationAction(action: .openEntrypointScreen))
                    }
                }
            }
        }
    }
}
