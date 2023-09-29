import SwiftUI
import hCoreUI

struct OverlayView: View {
    @ObservedObject var audioPlayer: AudioPlayer

    let staplesMaskColorOld: some hColor = hColorScheme(
        light: hTintColorOld.link,
        dark: hTextColor.primary
    )
    var body: some View {
        GeometryReader { geometry in
            RoundedRectangle(cornerRadius: .defaultCornerRadius)
                .fill(hTextColor.tertiary)
                .frame(width: geometry.size.width * audioPlayer.progress)
        }
    }
}
