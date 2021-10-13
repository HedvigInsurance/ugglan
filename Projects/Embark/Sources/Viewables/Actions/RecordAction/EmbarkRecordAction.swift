import Foundation
import SwiftUI
import hCoreUI
import Combine
import AVFAudio
import hCore

struct EmbarkRecordAction: View {
    @StateObject var audioRecorder = AudioRecorder()
    
    var body: some View {
        VStack {
            if let recording = audioRecorder.recording {
                TrackPlayer(audioPlayer: .init(recording: recording))
                hButton.LargeButtonFilled {
                    ///submit recording
                } content: {
                    hText(L10n.generalContinueButton)
                }
                hButton.LargeButtonText {
                    audioRecorder.restart()
                } content: {
                    hText("Record again")
                }
                Spacer()
            } else {
                RecordButton()
            }
        }.environmentObject(audioRecorder)
    }
}

struct AudioPulseBackground: View {
    @EnvironmentObject var audioRecorder: AudioRecorder
    
    var body: some View {
        Circle().fill(hGrayscaleColor.one)
            .onReceive(audioRecorder.recordingTimer) { input in
                audioRecorder.refresh()
            }
            .scaleEffect(audioRecorder.isRecording ? pow(((audioRecorder.decibelScale.last ?? 0.0) + 0.95), 4) : 0.95)
            .animation(.spring())
    }
}

struct RecordButton: View {
    @EnvironmentObject var audioRecorder: AudioRecorder
    
    @ViewBuilder var pulseBackground: some View {
        if audioRecorder.isRecording {
            AudioPulseBackground()
        } else {
            Color.clear
        }
    }
    
    var body: some View {
        ZStack {
            pulseBackground
            SwiftUI.Button {
                withAnimation(.spring()) {
                    audioRecorder.toggleRecording()
                }
            } label: {
                
            }.buttonStyle(RecordButtonStyle())
        }
    }
}

struct RecordButtonStyle: SwiftUI.ButtonStyle {
    @EnvironmentObject var audioRecorder: AudioRecorder
    
    @hColorBuilder var innerCircleColor: some hColor {
        if audioRecorder.isRecording {
            hLabelColor.primary
        } else {
            hTintColor.red
        }
    }
    
    func makeBody(configuration: Configuration) -> some View {
        VStack {
            Rectangle().fill(innerCircleColor).frame(width: 36, height: 36).cornerRadius(audioRecorder.isRecording ? 1 : 18)
                .padding(36)
        }.background(Circle().fill(hBackgroundColor.secondary)).shadow(color: .black.opacity(0.1), radius: 24, x: 0, y: 4)
    }
}

extension TimeInterval {
    var displayValue: String {
        let seconds = self.truncatingRemainder(dividingBy: 60)
        let minutes = (self / 60).truncatingRemainder(dividingBy: 60)
        let secondsLabel = Int(seconds) > 9 ? String(Int(seconds)) : "0\(Int(seconds))"
        let minutesLabel = Int(minutes) > 9 ? String(Int(minutes)) : "0\(Int(minutes))"
        return "\(minutesLabel):\(secondsLabel)"
    }
}
