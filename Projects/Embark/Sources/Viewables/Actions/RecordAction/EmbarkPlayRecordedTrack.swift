import Foundation
import SwiftUI
import hCoreUI
import Combine
import AVFAudio
import hCore

struct RecordedTrack: View {
    @State var audioPlayer: AudioPlayer
    
    struct Bar: Identifiable {
        var id = UUID()
        var scale: CGFloat
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
                }.frame(width: 24, height: 24, alignment: .leading)
                ScrollView(.horizontal){
                    HStack(alignment: .center, spacing: 2.5) {
                        ForEach(audioPlayer.recording.sample.map { Bar(scale: $0) }) { bar in
                            RoundedRectangle(cornerRadius: 0.5)
                                .frame(width: 1.85, height: calculateHeightForBar(maxValue: audioPlayer.recording.max, scale: bar.scale))
                                .animation(.easeInOut)
                        }
                    }
                }
            }
            .padding(20)
        }
    }
    
    func calculateHeightForBar(maxValue: CGFloat, scale: CGFloat) -> CGFloat {
        let maxHeight = CGFloat(60)
        let minHeight = CGFloat(10)
        
        let height = scale/maxValue * maxHeight
        
        return max(height, minHeight)
    }
}
