//
//  AudioRecorder.swift
//  project
//
//  Created by Sam Pettersson on 2019-09-17.
//

import Foundation
import UIKit
import Flow
import AVKit
import Disk

struct AudioRecorder {}

extension AudioRecorder: Viewable {
    func materialize(events: ViewableEvents) -> (UIStackView, Disposable) {
        let bag = DisposeBag()
        let view = UIStackView()
        view.alignment = .center
        view.edgeInsets = UIEdgeInsets(horizontalInset: 20, verticalInset: 0)
        view.isLayoutMarginsRelativeArrangement = true
        view.insetsLayoutMarginsFromSafeArea = true
        
        let contentContainerView = UIStackView()
        contentContainerView.alignment = .trailing
        view.addArrangedSubview(contentContainerView)
        
        let recordingSession = AVAudioSession.sharedInstance()
        
        let recordButtonContainer = UIStackView()
        let recordButton = RecordButton()
        
        bag += recordButton.isRecordingSignal.atOnce().onValueDisposePrevious { isRecording in
            guard isRecording == true else {
                return NilDisposer()
            }
            guard let fileUrl = try? Disk.url(for: "\(UUID().uuidString).mp4", in: .temporary) else {
                return NilDisposer()
            }
            
            let settings = [
                AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
                AVSampleRateKey: 12000,
                AVNumberOfChannelsKey: 1,
                AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
            ]
            
            class AudioRecorderCoordinator: NSObject, AVAudioRecorderDelegate {
            }
            
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
                
                recordBag += Signal(after: 0).animated(style: SpringAnimationStyle.lightBounce()) { _ in
                    waveFormContainer.alpha = 0
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
        
        do {
            try recordingSession.setCategory(.playAndRecord, mode: .default)
            try recordingSession.setActive(true)
            
            recordingSession.requestRecordPermission { allowed in
                if allowed {
                    DispatchQueue.main.async {
                        presentRecordButton()
                    }
                }
            }
        } catch {
            
        }
        
        return (view, bag)
    }
}
