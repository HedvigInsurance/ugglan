//
//  VideoPlayer.swift
//  project
//
//  Created by Sam Pettersson on 2019-09-13.
//

import AVKit
import Flow
import Foundation
import Presentation

struct VideoPlayer {
    let player: AVPlayer
}

private final class VideoPlayerViewController: AVPlayerViewController {
    private let viewDidDisappearCallbacker = Callbacker<Void>()

    var viewDidDisappearSignal: Signal<Void> {
        viewDidDisappearCallbacker.providedSignal
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)

        if traitCollection.userInterfaceIdiom != .pad {
            let value = UIInterfaceOrientation.portrait.rawValue
            UIDevice.current.setValue(value, forKey: "orientation")
        }

        viewDidDisappearCallbacker.callAll()
    }
}

extension VideoPlayer: Presentable {
    func materialize() -> (AVPlayerViewController, Future<Void>) {
        let bag = DisposeBag()

        let viewController = VideoPlayerViewController()
        if #available(iOS 13.0, *) {
            viewController.overrideUserInterfaceStyle = .dark
        }
        viewController.player = player

        return (viewController, Future { completion in
            bag += viewController.viewDidDisappearSignal.onValue { _ in
                completion(.success)
            }

            return bag
        })
    }
}
