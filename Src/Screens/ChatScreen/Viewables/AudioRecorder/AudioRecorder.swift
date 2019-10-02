//
//  AudioRecorder.swift
//  project
//
//  Created by Sam Pettersson on 2019-09-17.
//

import AVKit
import Disk
import Flow
import Foundation
import UIKit
import Apollo

struct AudioRecorder {
    let client: ApolloClient
    let chatState: ChatState
    
    init(
        chatState: ChatState,
        client: ApolloClient = ApolloContainer.shared.client
    ) {
        self.chatState = chatState
        self.client = client
    }
}

extension AudioRecorder: Viewable {
    func materialize(events _: ViewableEvents) -> (UIStackView, Disposable) {
        let bag = DisposeBag()
        let view = UIStackView()
        view.alignment = .center
        view.edgeInsets = UIEdgeInsets(horizontalInset: 20, verticalInset: 0)
        view.isLayoutMarginsRelativeArrangement = true
        view.insetsLayoutMarginsFromSafeArea = true

        let contentContainerView = UIStackView()
        contentContainerView.alignment = .trailing
        view.addArrangedSubview(contentContainerView)

        let recordButtonContainer = UIStackView()
        let playContainer = UIStackView()
        playContainer.alignment = .center
        playContainer.spacing = 10
        playContainer.animationSafeIsHidden = true
        
        contentContainerView.addArrangedSubview(playContainer)
        
        let currentAudioFileUrl = ReadWriteSignal<URL?>(nil)

        let recordButton = RecordButton()
        let audioPlayer = AudioPlayer()

        bag += recordButton.isRecordingSignal.atOnce().onValueDisposePrevious { isRecording in
            guard isRecording == true else {
                return NilDisposer()
            }
            guard let fileUrl = try? Disk.url(for: "\(UUID().uuidString).mp4", in: .temporary) else {
                return NilDisposer()
            }
            
            currentAudioFileUrl.value = fileUrl

            let settings = [
                AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
                AVSampleRateKey: 12000,
                AVNumberOfChannelsKey: 1,
                AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue,
            ]

            class AudioRecorderCoordinator: NSObject, AVAudioRecorderDelegate {}

            try? AVAudioSession.sharedInstance().setCategory(.record)
            let audioRecorder = try? AVAudioRecorder(url: fileUrl, settings: settings)
            let delegate = AudioRecorderCoordinator()
            bag.hold(delegate)
            audioRecorder?.delegate = delegate

            audioRecorder?.record()
            audioRecorder?.isMeteringEnabled = true

            let recordBag = DisposeBag()

            let waveFormContainer = UIView()
            recordButtonContainer.addSubview(waveFormContainer)

            waveFormContainer.snp.makeConstraints { make in
                make.width.equalTo(100)
                make.height.equalTo(50)
                make.centerX.equalToSuperview()
                make.centerY.equalToSuperview()
            }

            waveFormContainer.transform = CGAffineTransform(translationX: -20, y: 0)

            if let audioRecorder = audioRecorder {
                recordBag += waveFormContainer.add(WaveForm(audioRecorder: audioRecorder))
            }

            waveFormContainer.alpha = 0

            recordBag += Signal(after: 0).animated(style: SpringAnimationStyle.lightBounce()) { _ in
                waveFormContainer.alpha = 1
                waveFormContainer.transform = CGAffineTransform(translationX: -20, y: -70)
            }

            return Disposer {
                audioRecorder?.stop()

                if let url = audioRecorder?.url {
                    audioPlayer.audioPlayerSignal.value = try? AVAudioPlayer(contentsOf: url)
                }

                recordBag += Signal(after: 0).animated(style: SpringAnimationStyle.lightBounce()) { _ in
                    waveFormContainer.alpha = 0
                    recordButtonContainer.animationSafeIsHidden = true
                    recordButtonContainer.alpha = 0
                    playContainer.alpha = 1
                    playContainer.animationSafeIsHidden = false
                    waveFormContainer.transform = CGAffineTransform(translationX: -20, y: 0)
                }.onValue { _ in
                    recordBag.dispose()
                }
            }
        }

        func presentRecordButton() {
            bag += view.addArranged(recordButton.wrappedIn(recordButtonContainer)) { recordButton in
                recordButton.axis = .vertical
                recordButton.alignment = .center
            }
        }

        func presentPlay() {
            bag += playContainer.addArranged(audioPlayer.wrappedIn(UIStackView()))

            let redoButton = Button(
                title: "Gör om",
                type: .standardSmall(backgroundColor: .primaryTintColor, textColor: .white)
            )
            
            bag += redoButton.onTapSignal.animated(style: SpringAnimationStyle.lightBounce()) { _ in
                recordButtonContainer.animationSafeIsHidden = false
                recordButtonContainer.alpha = 1
                playContainer.animationSafeIsHidden = true
                playContainer.alpha = 0
            }
            
            bag += playContainer.addArranged(redoButton.wrappedIn(UIStackView())) { stackView in
                stackView.axis = .vertical
                stackView.alignment = .trailing
            }
            
            let sendButton = Button(title: "Skicka", type: .standardSmall(backgroundColor: .primaryTintColor, textColor: .white))
            let loadableSendButton = LoadableButton(button: sendButton)
            
            bag += loadableSendButton.onTapSignal.onValue({ _ in
                guard let fileUrl = currentAudioFileUrl.value else {
                    return
                }
                
                bag += Signal(after: 0).animated(style: SpringAnimationStyle.lightBounce()) { _ in
                    loadableSendButton.isLoadingSignal.value = true
                    playContainer.layoutIfNeeded()
                }
                
                self.chatState.sendChatAudioResponse(fileUrl: fileUrl)
            })
            
            bag += playContainer.addArranged(loadableSendButton.wrappedIn(UIStackView())) { stackView in
                stackView.axis = .vertical
                stackView.alignment = .trailing
            }
        }

        AVAudioSession.sharedInstance().requestRecordPermission { allowed in
            if allowed {
                DispatchQueue.main.async {
                    presentPlay()
                    presentRecordButton()
                }
            }
        }

        return (view, bag)
    }
}
