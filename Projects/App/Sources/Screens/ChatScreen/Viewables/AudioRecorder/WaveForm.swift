import AVKit
import Flow
import Form
import Foundation
import UIKit
import hCore

struct WaveForm { let audioRecorder: AVAudioRecorder }

extension WaveForm: Viewable {
	func materialize(events _: ViewableEvents) -> (UIView, Disposable) {
		let view = UIView()
		let bag = DisposeBag()

		view.backgroundColor = .brand(.destructive)

		let viewHeight = 50

		bag += view.didMoveToWindowSignal.take(first: 1).onValue { _ in
			view.snp.makeConstraints { make in make.width.equalTo(100)
				make.height.equalTo(viewHeight)
			}
		}

		view.layer.cornerRadius = CGFloat(viewHeight / 2)

		var staples: [UIView] = []

		for _ in 1...20 {
			let staple = UIView()
			staple.backgroundColor = .white

			staples.append(staple)
			view.addSubview(staple)
		}

		var pastPeakPower: [Float] = []

		let timeStampLabel = UILabel(
			value: "00:00",
			style: TextStyle.brand(.footnote(color: .primary)).colored(.white).centerAligned
		)
		view.addSubview(timeStampLabel)

		timeStampLabel.snp.makeConstraints { make in make.bottom.equalToSuperview().inset(2.5)
			make.width.equalToSuperview()
		}

		bag += Signal(every: 1).onValue { _ in let currentTime = self.audioRecorder.currentTime
			let seconds = currentTime.truncatingRemainder(dividingBy: 60)
			let minutes = (currentTime / 60).truncatingRemainder(dividingBy: 60)
			let secondsLabel = Int(seconds) > 9 ? String(Int(seconds)) : "0\(Int(seconds))"
			let minutesLabel = Int(minutes) > 9 ? String(Int(minutes)) : "0\(Int(minutes))"
			timeStampLabel.value = String("\(minutesLabel):\(secondsLabel)")
		}

		bag += Signal(every: 1 / 60).onValue { _ in self.audioRecorder.updateMeters()
			pastPeakPower.append(self.audioRecorder.averagePower(forChannel: 0))
			pastPeakPower = pastPeakPower.suffix(20)

			pastPeakPower.enumerated().forEach { offset, value in
				let normalizedValue = CGFloat(max(value, -50))
				let maxHeight: CGFloat = 15

				let log = log10(normalizedValue / -50)

				let height: CGFloat

				if log.isNaN { height = -maxHeight } else { height = max(maxHeight * log, -maxHeight) }

				staples[offset].frame = CGRect(
					x: CGFloat(offset * 3) + 20,
					y: 22.5,
					width: 2,
					height: CGFloat(height)
				)
				staples[offset].layoutIfNeeded()
			}
		}

		return (view, bag)
	}
}
