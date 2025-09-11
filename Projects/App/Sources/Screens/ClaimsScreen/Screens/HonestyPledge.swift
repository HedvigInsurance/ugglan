import Claims
import Combine
import Profile
import SwiftUI
import hCore
import hCoreUI

struct SlideToConfirm: View {
    let onConfirmAction: (() -> Void)?
    @State private var didFinished: Bool = false
    @State private var updateUIForFinished: Bool = false
    @State private var progress: CGFloat = 0
    @State private var width: CGFloat = 0
    @State private var bounceSliderButton = false

    var body: some View {
        if #available(iOS 16.0, *) {
            slider
                .onTapGesture(coordinateSpace: .local) { location in
                    if didFinished {
                        return
                    }
                    withAnimation(.defaultSpring) {
                        self.progress = location.x + 25
                    }
                    if progress < width {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                            withAnimation(.defaultSpring) {
                                resetProgress()
                            }
                        }
                    } else {
                        promiseConfirmed()
                    }
                }
        } else {
            slider
        }
    }

    private func resetProgress() {
        progress = 0
    }

    private var slider: some View {
        ZStack(alignment: .leading) {
            VStack(alignment: .center) {
                L10n.claimsPledgeSlideLabel.hText(.body1)
                    .foregroundColor(getLabelColor)
                    .frame(maxWidth: .infinity)
                    .opacity(updateUIForFinished ? 0 : (1 - Double(progress / width)))
            }
            Image(uiImage: updateUIForFinished ? hCoreUIAssets.checkmark.image : hCoreUIAssets.chevronRight.image)
                .foregroundColor(hTextColor.Opaque.negative)
                .frame(width: 50, height: 50)
                .background(getIconBackgroundColor)
                .colorScheme(.light)
                .clipShape(Circle())
                .scaleEffect(bounceSliderButton ? 0.8 : 1)
                .offset(x: max(0, min(progress, width - 58)))
                .padding(.horizontal, 4)
                .gesture(
                    DragGesture()
                        .onChanged { gesture in
                            if didFinished {
                                return
                            }
                            withAnimation(.defaultSpring.speed(4)) {
                                progress = (gesture.translation.width + gesture.startLocation.x - 29)
                            }
                            if progress + 58 >= width {
                                promiseConfirmed()
                            }
                        }
                        .onEnded { _ in
                            if didFinished {
                                return
                            }
                            withAnimation(.defaultSpring.speed(2)) {
                                progress = 0
                            }
                        }
                )
        }
        .frame(height: 58)
        .frame(maxWidth: .infinity)
        .background(
            GeometryReader { proxy in
                hSurfaceColor.Opaque.secondary
                    .onAppear {
                        width = proxy.size.width
                    }
                    .onChange(of: proxy.size) { size in
                        width = size.width
                    }
            }
        )
        .cornerRadius(29)
        .accessibilityElement(children: .combine)
        .accessibilityHint(L10n.voiceoverHonestypledgeSlider)
        .accessibilityAction {
            withAnimation(.defaultSpring.speed(2)) {
                progress = 0
            }
            promiseConfirmed()
        }
    }

    private func promiseConfirmed() {
        didFinished = true
        withAnimation(.defaultSpring) {
            progress = width
        }
        withAnimation(.defaultSpring.speed(2)) {
            bounceSliderButton = true
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            withAnimation(.defaultSpring.speed(2)) {
                bounceSliderButton = false
                updateUIForFinished = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                onConfirmAction?()
            }
        }
    }

    @hColorBuilder
    private var getLabelColor: some hColor {
        if didFinished {
            hTextColor.Opaque.disabled
        } else {
            hTextColor.Translucent.secondary
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
                VStack(alignment: .leading, spacing: 0) {
                    L10n.honestyPledgeTitle.hText(.body1)
                        .foregroundColor(hTextColor.Opaque.primary)
                        .padding(.bottom, .padding8)
                    HStack {
                        L10n.honestyPledgeDescription.hText(.body1)
                            .foregroundColor(hTextColor.Opaque.secondary)
                    }
                    .padding(.bottom, .padding32)
                }

                SlideToConfirm(onConfirmAction: {
                    onConfirmAction?()
                })
                .frame(maxHeight: 50)
                .padding(.bottom, 20)

                hCancelButton {
                    router.dismiss()
                }
            }
            .padding(.horizontal, .padding24)
            .padding(.top, -8)
        }
        .hFormContentPosition(.compact)
    }
}

#Preview {
    HonestyPledge {}
}
