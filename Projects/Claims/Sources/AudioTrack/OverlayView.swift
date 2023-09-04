import SwiftUI
import hCoreUI

struct OverlayView: View {
    @ObservedObject var audioPlayer: AudioPlayer

    let staplesMaskColorOld: some hColor = hColorScheme(
        light: hLabelColor.link.inverted,
        dark: hLabelColor.primary
    )
    var body: some View {
        GeometryReader { geometry in
            RoundedRectangle(cornerRadius: .defaultCornerRadius)
                .fill(hTextColorNew.tertiary)
                .frame(width: geometry.size.width * audioPlayer.progress)
        }
    }
}
