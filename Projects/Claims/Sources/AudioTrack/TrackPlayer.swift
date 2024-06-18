import SwiftUI
import hCore
import hCoreUI

struct TrackPlayer: View {
    @ObservedObject var audioPlayer: AudioPlayer

    @ViewBuilder var image: some View {
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
        .foregroundColor(hFillColor.Opaque.primary)
        .background {
            Circle().fill(hSurfaceColor.Translucent.secondary)
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(alignment: .center, spacing: 16) {
                if audioPlayer.playbackState == .loading {
                    ActivityIndicator(
                        style: .large,
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
                }
            }
            .padding(.horizontal, .padding16)
            .frame(maxWidth: .infinity)
            .frame(height: 64)
            .background(
                RoundedRectangle(cornerRadius: .cornerRadiusL)
                    .fill(hSurfaceColor.Opaque.primary)
            )
            .onTapGesture {
                audioPlayer.togglePlaying()
            }
        }
    }
}

struct TrackPlayer_Previews: PreviewProvider {

    static var previews: some View {
        let audioPlayer = AudioPlayer(url: URL(string: "https://filesamples.com/samples/audio/m4a/sample4.m4a"))
        TrackPlayer(audioPlayer: audioPlayer)

    }
}
