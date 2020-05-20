//
//  AudioPlayer.swift
//  project
//
//  Created by Sam Pettersson on 2019-09-18.
//

import AVKit
import Flow
import Form
import Foundation
import UIKit
import hCore

struct AudioPlayer {
    let audioPlayerSignal = ReadWriteSignal<AVAudioPlayer?>(nil)
}

extension AudioPlayer: Viewable {
    func materialize(events _: ViewableEvents) -> (UIView, Disposable) {
        let bag = DisposeBag()
        let control = UIControl()
        control.clipsToBounds = true

        let contentView = UIStackView()
        contentView.layoutMargins = UIEdgeInsets(horizontalInset: 20, verticalInset: 10)
        contentView.isLayoutMarginsRelativeArrangement = true
        contentView.spacing = 15
        contentView.isUserInteractionEnabled = false

        control.addSubview(contentView)

        contentView.snp.makeConstraints { make in
            make.top.bottom.trailing.leading.equalToSuperview()
        }

        let shaderView = UIView()
        contentView.addSubview(shaderView)
        shaderView.backgroundColor = UIColor.boxSecondaryBackground.darkened(amount: 0.1)

        shaderView.snp.makeConstraints { make in
            make.width.equalTo(0)
            make.leading.equalToSuperview()
            make.height.equalToSuperview()
        }

        control.backgroundColor = .primaryButtonBackgroundColor
        bag += control.didLayoutSignal.onValue { _ in
            control.layer.cornerRadius = control.frame.height / 2
        }

        let playIconImageView = UIImageView()
        playIconImageView.image = Asset.play.image
        playIconImageView.tintColor = .primaryButtonTextColor
        playIconImageView.contentMode = .scaleAspectFit

        contentView.addArrangedSubview(playIconImageView)

        playIconImageView.snp.makeConstraints { make in
            make.width.height.equalTo(12)
        }

        let timeStampLabel = UILabel(value: "00:00", style: TextStyle.chatTimeStamp.rightAligned.colored(.primaryButtonTextColor))
        contentView.addArrangedSubview(timeStampLabel)

        timeStampLabel.snp.makeConstraints { make in
            make.width.equalTo(35)
        }

        func updateShader(audioPlayer: AVAudioPlayer) {
            let shaderWidth = contentView.layer.frame.width * CGFloat(audioPlayer.currentTime / audioPlayer.duration)

            shaderView.snp.updateConstraints { make in
                make.width.equalTo(shaderWidth)
            }
        }

        func updateTimeStamp(audioPlayer: AVAudioPlayer) {
            let playbackTime = audioPlayer.duration - audioPlayer.currentTime
            let seconds = playbackTime.truncatingRemainder(dividingBy: 60)
            let minutes = (playbackTime / 60).truncatingRemainder(dividingBy: 60)
            let secondsLabel = Int(seconds) > 9 ? String(Int(seconds)) : "0\(Int(seconds))"
            let minutesLabel = Int(minutes) > 9 ? String(Int(minutes)) : "0\(Int(minutes))"
            timeStampLabel.value = String("\(minutesLabel):\(secondsLabel)")
        }

        let timerBag = bag.innerBag()

        func pause(audioPlayer: AVAudioPlayer) {
            timerBag.dispose()
            audioPlayer.pause()
            playIconImageView.image = Asset.play.image
            updateTimeStamp(audioPlayer: audioPlayer)
            updateShader(audioPlayer: audioPlayer)
        }

        func play(audioPlayer: AVAudioPlayer) {
            try? AVAudioSession.sharedInstance().setCategory(.playback)
            timerBag.dispose()
            audioPlayer.play()
            playIconImageView.image = Asset.pause.image
            updateTimeStamp(audioPlayer: audioPlayer)
            updateShader(audioPlayer: audioPlayer)
        }

        bag += control
            .signal(for: .touchUpInside)
            .onValue { _ in

                guard let audioPlayer = self.audioPlayerSignal.value else {
                    return
                }

                if audioPlayer.isPlaying {
                    pause(audioPlayer: audioPlayer)
                    return
                }

                play(audioPlayer: audioPlayer)

                timerBag += Signal(every: 1 / 60).onValue { _ in
                    updateShader(audioPlayer: audioPlayer)

                    if !audioPlayer.isPlaying {
                        pause(audioPlayer: audioPlayer)
                    }
                }

                timerBag += Signal(every: 1).onValue { _ in
                    updateTimeStamp(audioPlayer: audioPlayer)
                }
            }

        bag += audioPlayerSignal.atOnce().compactMap { $0 }.onValue { audioPlayer in
            updateTimeStamp(audioPlayer: audioPlayer)
        }

        return (control, bag)
    }
}
