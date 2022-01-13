import SwiftUI
import hCore
import hCoreUI

struct TrackPlayer: View {
    @ObservedObject var audioPlayer: AudioPlayer

    let playbackTint: some hColor = hColorScheme(
        light: hTintColor.lavenderOne,
        dark: hLabelColor.tertiary
    )

    let loadingColor: some hColor = hColorScheme(
        light: hLabelColor.link,
        dark: hLabelColor.primary
    )

    @ViewBuilder var image: some View {
        switch audioPlayer.playbackState {
        case let .playing(paused):
            Image(uiImage: paused ? hCoreUIAssets.play.image : hCoreUIAssets.pause.image)
                .foregroundColor(playbackTint)
        default:
            Image(uiImage: hCoreUIAssets.play.image)
                .foregroundColor(playbackTint)
        }
    }

    var body: some View {
        HStack(alignment: .center, spacing: 16) {
            switch audioPlayer.playbackState {
            case .loading:
                ActivityIndicator(style: .large)
                    .foregroundColor(loadingColor)
            default:
                image

                let waveform = WaveformView(stripeColor: playbackTint)
                    .frame(maxWidth: .infinity)
                waveform
                    .overlay(
                        OverlayView(audioPlayer: audioPlayer).mask(waveform)
                    )
            }
        }
        .padding(.horizontal, 16)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(
            RoundedRectangle(cornerRadius: .defaultCornerRadius)
                .fill(hColorScheme(light: hTintColor.lavenderTwo, dark: hTintColor.lavenderOne))
                .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
        )
        .onTapGesture {
            withAnimation(.spring()) {
                audioPlayer.togglePlaying()
            }
        }
    }
}

/**
 Card(
     titleIcon: hCoreUIAssets.warningTriangle.image,
     title: L10n.InfoCardMissingPayment.title,
     body: L10n.InfoCardMissingPayment.body,
     buttonText: L10n.InfoCardMissingPayment.buttonText,
     backgroundColor: .tint(.yellowOne),
     buttonType: .standardSmall(
         backgroundColor: .tint(.yellowTwo),
         textColor: .typographyColor(
             .primary(
                 state: .matching(
                     .tint(.yellowTwo)
                 )
             )
         )
     )
 )
 */
