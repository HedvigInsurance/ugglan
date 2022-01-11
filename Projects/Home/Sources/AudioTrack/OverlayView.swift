import SwiftUI
import hCoreUI

struct OverlayView: View {
    @ObservedObject var audioPlayer: AudioPlayer

    let staplesMaskColor: some hColor = hTintColor.lavenderOne.opacity(0.5)

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
