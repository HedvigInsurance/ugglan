import SwiftUI
import hCoreUI

struct OverlayView: View {
    @ObservedObject var audioPlayer: AudioPlayer
    @Environment(\.hUseNewStyle) var hUseNewStyle

    let staplesMaskColorOld: some hColor = hColorScheme(
        light: hLabelColor.link.inverted,
        dark: hLabelColor.primary
    )

    @hColorBuilder
    var getStaplesMaskColor: some hColor {
        if hUseNewStyle {
            hTextColorNew.tertiary
        } else {
            staplesMaskColorOld
        }
    }

    var body: some View {
        GeometryReader { geometry in
            RoundedRectangle(cornerRadius: .defaultCornerRadius)
                .fill(getStaplesMaskColor)
                .frame(width: geometry.size.width * audioPlayer.progress)
        }
    }
}
