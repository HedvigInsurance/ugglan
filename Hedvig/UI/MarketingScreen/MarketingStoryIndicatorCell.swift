//
//  MarketingStoryIndicatorCell.swift
//  Hedvig
//
//  Created by Sam Pettersson on 2018-12-13.
//  Copyright © 2018 Hedvig AB. All rights reserved.
//

import Flow
import UIKit

class MarketingStoryIndicatorCell: UICollectionViewCell {
    let progressView = UIView()
    let bag = DisposeBag()
    var progress: Double = 0
    var duration: TimeInterval = 0
    var onDone: (() -> Void)?

    override init(frame: CGRect) {
        super.init(frame: frame)

        layer.cornerRadius = 1.25
        clipsToBounds = true
        backgroundColor = HedvigColors.white.withAlphaComponent(0.5)

        addSubview(progressView)

        progressView.snp.makeConstraints { make in
            make.width.equalToSuperview()
            make.height.equalToSuperview()
            make.center.equalToSuperview()
        }
    }

    func start(marketingStoryIndicator: MarketingStoryIndicator, onDone: @escaping () -> Void) {
        bag.dispose()
        duration = marketingStoryIndicator.duration
        progress = 0
        self.onDone = onDone

        if marketingStoryIndicator.focused {
            progressView.backgroundColor = HedvigColors.white
            progressView.transform = CGAffineTransform(translationX: -progressView.frame.width, y: 0)
            progressView.alpha = 1

            startTimer()
        } else if marketingStoryIndicator.shown {
            progressView.backgroundColor = UIColor.white
            progressView.transform = CGAffineTransform.identity
        } else {
            progressView.backgroundColor = UIColor.clear
        }
    }

    private func startTimer() {
        let progressChunk = duration / 1000

        bag += Signal(every: progressChunk).onValue {
            self.progress +=
                progressChunk
                / self.duration

            let frameWidth = self.progressView.frame.width
            let translationX = -(frameWidth - (frameWidth * CGFloat(self.progress)))

            self.progressView.transform = CGAffineTransform(
                translationX: translationX,
                y: 0
            )

            if self.progress > 1 {
                self.onDone?()
                self.bag.dispose()
            }
        }
    }

    func pause() {
        bag.dispose()
    }

    func resume() {
        startTimer()
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
