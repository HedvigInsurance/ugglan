import Flow
import Foundation
import Presentation
import SwiftUI
import hCore
import hCoreUI

extension JourneyPresentation {
    public var addClaimsProgressBar: Self {
        addConfiguration { presenter in
            let progressViewTag = "navigationProgressBar".hashValue
            presenter.bag += presenter.viewController.view.didMoveToWindowSignal.onValue({ _ in
                let store: SubmitClaimStore = globalPresentableStoreContainer.get()
                if let navigationBar = presenter.viewController.navigationController?.navigationBar,
                    navigationBar.subviews.first(where: { $0.tag == progressViewTag }) == nil
                {
                    let progresView = UIProgressView(color: UIColor.brand(.primaryBackground(false)))
                    progresView.layer.cornerRadius = 2
                    progresView.tag = progressViewTag
                    progresView.tintColor = .brand(.primaryText(false))
                    navigationBar.addSubview(progresView)
                    progresView.snp.makeConstraints { make in
                        make.leading.equalToSuperview().offset(15)
                        make.trailing.equalToSuperview().offset(-15)
                        make.top.equalToSuperview()
                        make.height.equalTo(4)
                    }
                    progresView.progress = store.state.progress ?? 0
                    progresView.alpha = store.state.progress == nil ? 0 : 1
                    let dispose = store.stateSignal.onValue { state in
                        if let progress = state.progress {
                            UIView.animate(withDuration: 0.4) {
                                progresView.setProgress(progress, animated: true)
                            }
                        }
                        UIView.animate(withDuration: 0.2) {
                            progresView.alpha = state.progress == nil ? 0 : 1
                        }
                    }
                    presenter.bag.add(dispose)
                }
            })
        }
    }
}
