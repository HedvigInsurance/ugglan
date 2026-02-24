import SwiftUI
import hCore

struct TrackPlayer: View {
    @ObservedObject var audioPlayer: AudioPlayer
    @State private var width: CGFloat = 0
    @Environment(\.trackPlayerBackground) var trackPlayerBackground
    init(
        audioPlayer: AudioPlayer
    ) {
        self.audioPlayer = audioPlayer
    }

    private var image: some View {
        Image(
            uiImage: {
                switch audioPlayer.playbackState {
                case let .playing(paused):
                    if paused {
                        return hCoreUIAssets.play.image
                    } else {
                        return hCoreUIAssets.pause.image
                    }
                default:
                    return hCoreUIAssets.play.image
                }
            }()
        )
        .accessibilityHidden(true)
        .foregroundColor(hFillColor.Opaque.primary)
        .background {
            Circle().fill(hSurfaceColor.Translucent.secondary)
                .frame(width: 32, height: 32)
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(alignment: .center, spacing: 16) {
                if audioPlayer.playbackState == .loading {
                    ActivityIndicator(
                        color: hTextColor.Opaque.primary
                    )
                    .foregroundColor(hTextColor.Opaque.primary)
                    .transition(.opacity.animation(.easeOut))
                } else {
                    image
                    let waveform = WaveformView(
                        stripeColor: hFillColor.Opaque.secondary,
                        sampleHeights: audioPlayer.sampleHeights
                    )
                    .frame(maxWidth: .infinity)
                    waveform
                        .overlay(
                            OverlayView(audioPlayer: audioPlayer, cornerRadius: 0)
                                .mask(waveform)
                        )
                        .transition(
                            .opacity.animation(.easeOut)
                        )
                        .accessibilityHidden(true)
                        .gesture(
                            DragGesture(coordinateSpace: .local)
                                .onChanged { gesture in
                                    let gesturePosition = gesture.startLocation.x + gesture.translation.width
                                    let progress = gesturePosition / width
                                    audioPlayer.setProgress(to: min(max(progress, 0), 1))
                                    audioPlayer.playbackState = .playing(paused: true)
                                }
                                .onEnded { gesture in
                                    let gesturePosition = gesture.startLocation.x + gesture.translation.width
                                    let progress = gesturePosition / width
                                    audioPlayer.setProgress(to: min(max(progress, 0), 1))
                                    audioPlayer.togglePlaying()
                                }
                        )
                        .background {
                            GeometryReader { geo in
                                Color.clear
                                    .onAppear {
                                        width = geo.size.width
                                    }
                                    .onChange(of: geo.size) { size in
                                        width = size.width
                                    }
                            }
                        }
                        .onDisappear {
                            if audioPlayer.playbackState == .playing(paused: false) {
                                audioPlayer.playbackState = .playing(paused: true)
                            }
                        }
                }
            }
            .padding(.horizontal, .padding16)
            .frame(maxWidth: .infinity)
            .frame(height: 64)
            .background(
                trackPlayerBackground
            )
            .onTapGesture {
                audioPlayer.togglePlaying()
            }
            .accessibilityElement(children: .combine)
            .accessibilityAddTraits(.isButton)
            .accessibilityLabel(L10n.a11YAudioRecording)
            .accessibilityAction {
                audioPlayer.togglePlaying()
            }
        }
    }
}

#Preview {
    let audioPlayer = AudioPlayer(
        url: URL(
            string:
                ""
        )
    )
    TrackPlayer(audioPlayer: audioPlayer)
}
@MainActor
private struct EnvironmentTrackPlayerBackground: @preconcurrency EnvironmentKey {
    static let defaultValue: AnyView = AnyView(
        RoundedRectangle(cornerRadius: .cornerRadiusL)
            .fill(hSurfaceColor.Opaque.primary)
    )
}

extension EnvironmentValues {
    public var trackPlayerBackground: AnyView {
        get { self[EnvironmentTrackPlayerBackground.self] }
        set { self[EnvironmentTrackPlayerBackground.self] = newValue }
    }
}

extension View {
    public func trackPlayerBackground<Content: View>(@ViewBuilder background: () -> Content) -> some View {
        environment(\.trackPlayerBackground, AnyView(background()))
    }
}
