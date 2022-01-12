import SwiftUI
import hCoreUI

struct OverlayView: View {
    @ObservedObject var audioPlayer: AudioPlayer

    let staplesMaskColor: some hColor = hColorScheme(
        light: hLabelColor.link.inverted,
        dark: hLabelColor.primary
    )

    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: .defaultCornerRadius)
                    .fill(staplesMaskColor)
                    .frame(width: geometry.size.width * audioPlayer.progress)
            }
        }
    }
}
