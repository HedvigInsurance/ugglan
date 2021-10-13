import Foundation
import SwiftUI
import hCoreUI
import Combine
import AVFAudio
import hCore

struct TrackPlayer: View {
    @ObservedObject var audioPlayer: AudioPlayer
    
    struct Bar: Identifiable {
        var id = UUID()
        var scale: CGFloat
    }
    
    private var staples: some View {
        HStack(alignment: .center, spacing: 2.5) {
            ForEach(audioPlayer.recording.sample.map { Bar(scale: $0) }) { bar in
                RoundedRectangle(cornerRadius: 1)
                    .foregroundColor(hGrayscaleColor.one)
                    .frame(width: 1.85, height: calculateHeightForBar(maxValue: audioPlayer.recording.max, scale: bar.scale))
                    .animation(.easeInOut)
            }
        }
    }
    
    private var overlayView: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                Rectangle()
                        .foregroundColor(hLabelColor.primary)
                        .frame(width: geometry.size.width * audioPlayer.progress)
                        .onReceive(audioPlayer.playerTimer) { input in
                            guard audioPlayer.isPlaying else { return }
                            audioPlayer.refreshPlayer()
                        }
            }
        }
    }
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 8)
                .fill(hBackgroundColor.secondary)
                .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
            HStack {
                SwiftUI.Button(action: {
                    audioPlayer.togglePlaying()
                }) {
                    if audioPlayer.isPlaying {
                        Image(uiImage: hCoreUIAssets.pause.image).tint(hLabelColor.primary)
                    } else {
                        Image(uiImage: hCoreUIAssets.play.image).tint(hLabelColor.primary)
                    }
                }
                Spacer()
                ScrollView(.horizontal){
                     staples
                    .overlay(
                        overlayView.mask(staples)
                    )
                }
            }
            .padding(20)
        }
    }
    
    func calculateHeightForBar(maxValue: CGFloat, scale: CGFloat) -> CGFloat {
        let maxHeight = CGFloat(60)
        let minHeight = CGFloat(5)
        
        let height = scale/maxValue * maxHeight
        
        return max(height, minHeight)
    }
}
