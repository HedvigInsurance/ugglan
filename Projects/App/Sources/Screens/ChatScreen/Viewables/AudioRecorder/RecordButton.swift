//
//  RecordButton.swift
//  project
//
//  Created by Sam Pettersson on 2019-09-17.
//

import Flow
import Foundation
import UIKit
import Core
 
struct RecordButton {
    let isRecordingSignal = ReadWriteSignal(false)
}

extension RecordButton: Viewable {
    func materialize(events _: ViewableEvents) -> (UIControl, Disposable) {
        let control = UIControl()
        let bag = DisposeBag()

        let size: CGFloat = 45

        control.snp.makeConstraints { make in
            make.width.height.equalTo(size)
        }
        control.layer.cornerRadius = size / 2
        control.layer.borderWidth = 3

        bag += control.applyBorderColor { _ -> UIColor in
            UIColor.primaryBorder
        }

        let recordIcon = UIView()
        recordIcon.isUserInteractionEnabled = false
        recordIcon.backgroundColor = .pink
        control.addSubview(recordIcon)

        let touchUpInside = control.signal(for: .touchUpInside)
        bag += touchUpInside.feedback(type: .impactLight)

        bag += touchUpInside
            .withLatestFrom(isRecordingSignal.atOnce().plain())
            .map { _, isRecording in !isRecording }
            .bindTo(isRecordingSignal)

        bag += combineLatest(
            recordIcon.didLayoutSignal.atOnce(),
            isRecordingSignal.atOnce().plain()
        ).animated(style: SpringAnimationStyle.lightBounce()) { _, isRecording in
            recordIcon.layer.cornerRadius = isRecording ? 2.5 : recordIcon.frame.width / 2

            recordIcon.snp.remakeConstraints { make in
                make.width.height.equalToSuperview().inset(isRecording ? 15 : 5)
                make.center.equalToSuperview()
            }

            recordIcon.layoutIfNeeded()
            control.layoutIfNeeded()
        }

        return (control, bag)
    }
}
