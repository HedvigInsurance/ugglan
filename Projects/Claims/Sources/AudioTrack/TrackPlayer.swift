import SwiftUI
import hCore
import hCoreUI

struct TrackPlayer: View {
    @ObservedObject var audioPlayer: AudioPlayer
    @Environment(\.hUseNewStyle) var hUseNewStyle
    @Environment(\.hWithoutFootnote) var hWithoutFootnote

    let playbackTint: some hColor = hColorScheme(
        light: hTintColor.lavenderOne,
        dark: hLabelColor.tertiary
    )

    let backgroundColorOld: some hColor = hColorScheme(
        light: hTintColor.lavenderTwo,
        dark: hTintColor.lavenderOne
    )

    @ViewBuilder var image: some View {
        switch audioPlayer.playbackState {
        case let .playing(paused):
            Image(uiImage: paused ? hCoreUIAssets.play.image : hCoreUIAssets.pause.image)
                .foregroundColor(getWaveColor)
        default:
            Image(uiImage: hCoreUIAssets.play.image)
                .foregroundColor(getWaveColor)
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 16) {
                if audioPlayer.playbackState == .loading {
                    ActivityIndicator(
                        style: .large,
                        color: hLabelColor.primary
                    )
                    .foregroundColor(hLabelColor.primary)  // change
                } else {
                    image

                    let waveform = WaveformView(
                        stripeColor: getWaveColor,
                        sampleHeights: audioPlayer.sampleHeights
                    )
                    .frame(maxWidth: .infinity)
                    waveform
                        .padding(.top, 6)
                        .overlay(
                            OverlayView(audioPlayer: audioPlayer).mask(waveform)
                                .padding(.top, 6)
                        )
                }
            }
            .padding(.horizontal, 16)
            .frame(height: 64)
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: .defaultCornerRadius)
                    .fill(getBackgroundColor)
                    .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
            )
            .onTapGesture {
                withAnimation(.spring()) {
                    audioPlayer.togglePlaying()
                }
            }

            if !hWithoutFootnote {
                if hUseNewStyle {
                    hTextNew(L10n.ClaimStatus.Files.claimAudioFooter, style: .footnote)
                        .foregroundColor(hLabelColorNew.secondary)
                } else {
                    hText(L10n.ClaimStatus.Files.claimAudioFooter, style: .footnote)
                        .foregroundColor(hLabelColor.secondary)
                }
            }
        }
    }

    @hColorBuilder
    var getWaveColor: some hColor {
        if hUseNewStyle {
            hLabelColorNew.primary
        } else {
            playbackTint
        }
    }

    @hColorBuilder
    var getBackgroundColor: some hColor {
        if hUseNewStyle {
            hBackgroundColorNew.primary
        } else {
            backgroundColorOld
        }
    }
}

private struct EnvironmentHWithoutFootnote: EnvironmentKey {
    static let defaultValue = false
}

extension EnvironmentValues {
    public var hWithoutFootnote: Bool {
        get { self[EnvironmentHWithoutFootnote.self] }
        set { self[EnvironmentHWithoutFootnote.self] = newValue }
    }
}

extension View {
    public var hWithoutFootnote: some View {
        self.environment(\.hWithoutFootnote, true)
    }
}
