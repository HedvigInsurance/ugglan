import SwiftUI

struct TrackPlayer: View {
    @ObservedObject var audioPlayer: AudioPlayer
    @State private var width: CGFloat = 0

    init(
        audioPlayer: AudioPlayer
    ) {
        self.audioPlayer = audioPlayer
    }

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
                RoundedRectangle(cornerRadius: .cornerRadiusL)
                    .fill(hSurfaceColor.Opaque.primary)
            )
            .onTapGesture {
                audioPlayer.togglePlaying()
            }
        }
    }
}

#Preview {
    let audioPlayer = AudioPlayer(
        url: URL(
            string:
                "https://com-hedvig-upload.s3.eu-central-1.amazonaws.com/87f477a6-f4b0-48a6-bc48-d11c3b582976-c873499d-30ad-4058-8b35-53b8748c5def.8d42e532-dffb-4267-b9f2-997da015be93.m4a?X-Amz-Security-Token=IQoJb3JpZ2luX2VjEG0aDGV1LWNlbnRyYWwtMSJHMEUCIEuT2D1Jv4fQD2YgFgsuZETqCTaVCxVlYBQxy170UrisAiEA4%2B3G%2BwDtmeJSVlkHYDZgOeHUJy8Ex3Wpuy0OXQUbCn4qiAUIFhAEGgwyMDE0Mjc1Mzk1MzgiDDHKmd%2FoMwWDOs1KiSrlBDfhfZs1XGZ%2BYeNTEhso7Cbm6S65c8LT9Vq6btKLx8daNHecxbnpYM5PFtcc79MCSGixGfNfDfYCJKXlBfaubWy%2FWEIci7j%2B2i2fZX5TQSx%2Fpy%2B%2FcgU9M8bYHY%2F606z%2FF0omdPJCW2F2X9dc%2FjbMYXjuNtV7CNuUrVn0GzCaU8819X9oJMOMLorbJsL0F6vhNFzucQoir69ZktS5RLOtWvksYVboLZuoHZOVdMcnaxkYJbKw7zkDfsdG%2Bm49lnV6ttMVVLHf1R9Ak3hkMDVrcVlZKnhNhQZlyxrR8Y0p5IzepgSLrVkm%2Fo8sMzJ9KpOsmTK9MkYI%2FR31ZlKhYi6MSwx6idbXLlmCrALGWc608nhKe%2FBU%2B%2Ft8grBr59iZRaKzSDKBeDaAx%2BKEv5RKKUr2x9CFOSK3qSpF1kW%2BTi4F5Get4OkCesrABJ9yVAtRkgrIb8gHuAXZZRzw2F%2Fne2w32tGUuINd1tVGZse1s0zHbypv5UezQ7djKvsYY%2B%2BuIC80FtBBZQa8RMLa%2FLNPjrp890FDVt%2BgZNm8hd26UIPSsbtam5iM6BKPYittp2qfWJtIBvjrH7c45tdZteZGVF7HeC4WiGcUv%2BWuxRG1UsJ06dhzZUW%2FQXP5YyfQOwPh7xhR8KeTQa32%2BaDNWIUYEJbQuGTiDWQr3optcpNrkhp6ZUCtq8lIDnXE0qqApKDsd0tn8KgD%2Binf%2BaHtmP8Bmg5bBa1KL0f4sr4WoapUBdzKOAxMtTjAiEvScIFBastK9Dc0LkD1CkCwpLxP3LQq79oaBVA6DKWFJOXkX2Cc7jT%2Fo4sSxmv6fj0w4eqRugY6mgFR9oq8pAFgDbd8O8X1Hxe7jeB7Ee0221nc5GWTdA%2BjS9bH7qQmpo%2BFlaHS5QyNsIn9BZrn1geMkeh4CFOs%2Byg6tKDI81%2F%2Fv%2Bbrv%2FWWhIZ2QeIBQM%2F7y4Bomtvt9rnAYet6HhRKi6tQuGyYRIEPypcc26IjrxIxfzZattbq4YiIlELIeXqskh4hUg5FatoehHoAhR7IxACkg8%2Bo&X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Date=20241125T135739Z&X-Amz-SignedHeaders=host&X-Amz-Credential=ASIAS5ZQEKZJL6OEKQEW%2F20241125%2Feu-central-1%2Fs3%2Faws4_request&X-Amz-Expires=3600&X-Amz-Signature=70e3341bc1946563a638ac5f0d3955ef715f26105552061215809be28a390aed"
        )
    )
    TrackPlayer(audioPlayer: audioPlayer)
}
