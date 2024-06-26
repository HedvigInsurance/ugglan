import Foundation
import Presentation
import SwiftUI
import hCore
import hCoreUI

extension View {
    public var addClaimsProgressBar: some View {
        self.introspectViewController { vc in
            let progressViewTag = "navigationProgressBar".hashValue
            let store: SubmitClaimStore = globalPresentableStoreContainer.get()
            if let navigationBar = vc.navigationController?.navigationBar,
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
                store.progressCancellable = store.stateSignal.plain().publisher.map({ $0.progress })
                    .sink { [weak progresView] progress in
                        if let progress {
                            UIView.animate(withDuration: 0.4) {
                                progresView?.setProgress(progress, animated: true)
                            }
                        }
                        UIView.animate(withDuration: 0.2) {
                            progresView?.alpha = progress == nil ? 0 : 1
                        }
                    }
            }
        }
    }
}
