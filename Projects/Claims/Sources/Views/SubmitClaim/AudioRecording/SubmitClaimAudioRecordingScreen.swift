import AVFAudio
import Combine
import Foundation
import SwiftUI
import hAnalytics
import hCore
import hCoreUI
import hGraphQL

public struct SubmitClaimAudioRecordingScreen: View {
    @PresentableStore var store: ClaimsStore
    @ObservedObject var audioPlayer: AudioPlayer
    @ObservedObject var audioRecorder: AudioRecorder
    let questions: [String]

    let onSubmit: (_ url: URL) -> Void

    public init(
        questions: [String]
    ) {
        self.questions = questions

        let url = URL(
            string: "https://www.bing.com/az/hprichbg/rb/AdobeSantaFe_EN-US4037753534_1920x1080.jpg"
        ) /* TODO: CHANGE URL */
        audioPlayer = AudioPlayer(url: url!)

        audioRecorder = AudioRecorder()

        func myFunc(_: URL) {}
        self.onSubmit = myFunc
    }

    public var body: some View {
        LoadingViewWithContent(.submitAudioRecording(audioURL: self.audioPlayer.url)) {
            hForm {

                ForEach(questions, id: \.self) { question in
                    HStack(spacing: 0) {
                        hText(L10nDerivation(table: "Localizable", key: question, args: []).render())
                            .foregroundColor(hLabelColor.primary)
                            .padding([.trailing, .leading], 12)
                            .padding([.top, .bottom], 16)
                    }

                    //                HStack(spacing: 0) {
                    //                    hText(L10n.Message.Claims.Record.short)
                    //                        .foregroundColor(hLabelColor.primary)
                    //                        .padding([.trailing, .leading], 12)
                    //                        .padding([.top, .bottom], 16)
                    //                }
                    //                .frame(maxWidth: .infinity, alignment: .leading)
                    //                .background(hBackgroundColor.tertiary)
                    //                .cornerRadius(12)
                    //                .padding(.leading, 16)
                    //                .padding(.trailing, 32)
                    //                .padding(.top, 20)
                    //                .hShadow()
                    //
                    //                HStack(spacing: 0) {
                    //                    hText(L10n.Message.Claims.Record.message1)
                    //                        .foregroundColor(hLabelColor.primary)
                    //                        .padding([.trailing, .leading], 12)
                    //                        .padding([.top, .bottom], 16)
                    //                }
                    //                .frame(maxWidth: .infinity, alignment: .leading)
                    //                .background(hBackgroundColor.tertiary)
                    //                .cornerRadius(12)
                    //                .padding(.leading, 16)
                    //                .padding(.trailing, 32)
                    //                .hShadow()
                    //
                    //                HStack(spacing: 0) {
                    //                    hText(L10n.Message.Claims.Record.message4)
                    //                        .foregroundColor(hLabelColor.primary)
                    //                        .padding([.trailing, .leading], 12)
                    //                        .padding([.top, .bottom], 16)
                    //                }
                    //                .frame(maxWidth: .infinity, alignment: .leading)
                    //                .background(hBackgroundColor.tertiary)
                    //                .cornerRadius(12)
                    //                .padding(.leading, 16)
                    //                .padding(.trailing, 32)
                    //                .hShadow()
                    //
                    //                HStack(spacing: 0) {
                    //                    hText(L10n.Message.Claims.Record.message3)
                    //                        .foregroundColor(hLabelColor.primary)
                    //                        .padding([.trailing, .leading], 12)
                    //                        .padding([.top, .bottom], 16)
                    //                }
                    //                .frame(maxWidth: .infinity, alignment: .leading)
                    //                .background(hBackgroundColor.tertiary)
                    //                .cornerRadius(12)
                    //                .padding(.leading, 16)
                    //                .padding(.trailing, 32)
                    //                .hShadow()

                }
            }
            .hFormAttachToBottom {

                ZStack(alignment: .bottom) {

                    if let recording = audioRecorder.recording {
                        VStack(spacing: 12) {
                            TrackPlayer(audioPlayer: audioPlayer)

                            hButton.LargeButtonFilled {
                                guard let url = audioRecorder.recording?.url else {
                                    return
                                }
                                onSubmit(url)
                                store.send(.submitAudioRecording(audioURL: url))
                            } content: {
                                hText(L10n.generalContinueButton)
                            }
                            hButton.LargeButtonText {
                                withAnimation(.spring()) {
                                    audioRecorder.restart()
                                }
                            } content: {
                                hText(L10n.embarkRecordAgain)
                            }
                        }
                        .transition(.move(edge: .bottom))
                        .onAppear {
                            self.audioPlayer.url = recording.url
                        }

                    } else {

                        RecordButton(isRecording: audioRecorder.isRecording) {
                            if audioRecorder.isRecording {
                            } else {
                            }

                            withAnimation(.spring()) {
                                audioRecorder.toggleRecording()
                            }
                        }
                        .transition(.asymmetric(insertion: .move(edge: .bottom), removal: .offset(x: 0, y: 300)))
                        .padding(.top, UIScreen.main.bounds.size.height / 1.7)
                    }
                }
                .environmentObject(audioRecorder)
            }
        }
    }
}

struct SubmitClaimAudioRecordingScreen_Previews: PreviewProvider {
    static var previews: some View {
        SubmitClaimAudioRecordingScreen(questions: [""])
    }
}
