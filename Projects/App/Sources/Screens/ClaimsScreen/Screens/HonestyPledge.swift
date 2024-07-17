import Claims
import Combine
import Profile
import SwiftUI
import hCore
import hCoreUI

struct SlideTrack: View {
    var shouldAnimate: Bool
    var labelOpacity: Double
    @Binding var didFinished: Bool

    var body: some View {
        ZStack {
            withAnimation(shouldAnimate && labelOpacity == 1 ? .easeInOut : nil) {
                VStack(alignment: .center) {
                    L10n.claimsPledgeSlideLabel.hText(.body1)
                        .foregroundColor(getLabelColor)
                        .frame(maxWidth: .infinity)
                        .opacity(didFinished ? 0 : labelOpacity)
                }
            }
        }
        .frame(height: 58)
        .frame(maxWidth: .infinity)
        .background(hSurfaceColor.Opaque.secondary)
        .cornerRadius(29)
    }

    @hColorBuilder
    private var getLabelColor: some hColor {
        if didFinished {
            hTextColor.Opaque.disabled
        } else {
            hTextColor.Opaque.secondary
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
                                Image(uiImage: hCoreUIAssets.checkmark.image)
                                    .transition(.scale)
                            } else {
                                Image(uiImage: hCoreUIAssets.chevronRight.image)
                                    .transition(.asymmetric(insertion: .scale, removal: .opacity))
                            }
                        }
                        .foregroundColor(hTextColor.Opaque.negative)
                        .frame(width: SlideDragger.size.width, height: SlideDragger.size.height)
                        .background(getIconBackgroundColor)
                        .colorScheme(.light)
                        .clipShape(Circle())
                    }
                    .animation(.interpolatingSpring(stiffness: 300, damping: 20), value: UUID())
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .modifier(
                    DraggerGeometryEffect(
                        dragOffsetX: didFinished ? geo.size.width : dragOffsetX,
                        draggerSize: SlideDragger.size
                    )
                )
            }
            .animation(shouldAnimate && dragOffsetX == 0 ? .spring() : nil, value: UUID())
        }
    }

    @hColorBuilder
    private var getIconBackgroundColor: some hColor {
        if didFinished {
            hSignalColor.Green.element
        } else {
            hTextColor.Opaque.primary
        }
    }
}

struct DidAcceptPledgeNotifier: View {
    var canNotify: Bool
    var dragOffsetX: CGFloat
    let onConfirmAction: (() -> Void)?
    @Binding var hasNotifiedStore: Bool
    var body: some View {
        GeometryReader { geo in
            Color.clear.onReceive(
                Just(canNotify && dragOffsetX > (geo.size.width - SlideDragger.size.width))
            ) { value in
                if value && !hasNotifiedStore {
                    hasNotifiedStore = true
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                        onConfirmAction?()
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
            .padding(.padding4)
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
    @EnvironmentObject var router: Router
    let onConfirmAction: (() -> Void)?

    init(
        onConfirmAction: (() -> Void)?
    ) {
        self.onConfirmAction = onConfirmAction
    }

    var body: some View {
        hForm {
            VStack(alignment: .leading, spacing: 0) {
                L10n.honestyPledgeTitle.hText(.body1)
                    .foregroundColor(hTextColor.Opaque.primary)
                    .padding(.bottom, .padding8)
                HStack {
                    L10n.honestyPledgeDescription.hText(.body1)
                        .foregroundColor(hTextColor.Opaque.secondary)
                }
                .padding(.bottom, .padding32)

                SlideToConfirm(onConfirmAction: {
                    onConfirmAction?()
                })
                .frame(maxHeight: 50)
                .padding(.bottom, 20)

                hButton.LargeButton(type: .ghost) {
                    router.dismiss()
                } content: {
                    L10n.generalCancelButton.hText(.body1)
                        .foregroundColor(hTextColor.Opaque.primary)
                }

            }
            .padding(.horizontal, .padding24)
            .fixedSize(horizontal: false, vertical: true)
        }
        .hDisableScroll
    }
}
