import SwiftUI

struct OverlayView: View {
    @ObservedObject var audioPlayer: AudioPlayer
    let cornerRadius: CGFloat
    var body: some View {
        GeometryReader { geometry in
            RoundedRectangle(cornerRadius: cornerRadius)
                .fill(hTextColor.Opaque.tertiary)
                .frame(width: geometry.size.width * audioPlayer.progress)
        }
    }
}
