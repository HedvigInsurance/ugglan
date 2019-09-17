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
        
        let recordingSession = AVAudioSession.sharedInstance()
        
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
            
            if let audioRecorder = audioRecorder {
                recordBag += view.add(WaveForm(audioRecorder: audioRecorder))
            }
            
            return Disposer {
                audioRecorder?.stop()
                recordBag.dispose()
            }
        }
        
        func presentRecordButton() {
            bag += view.addArranged(recordButton.wrappedIn(UIStackView())) { recordButton in
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
