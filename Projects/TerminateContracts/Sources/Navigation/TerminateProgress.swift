import Foundation
import PresentableStore
import SwiftUI
@_spi(Advanced) import SwiftUIIntrospect
import hCore
import hCoreUI

extension View {
    @MainActor public var addTerminationProgressBar: some View {
        self.introspect(.viewController, on: .iOS(.v13...)) { vc in
            let progressViewTag = "navigationProgressBar".hashValue
            let store: TerminationContractStore = globalPresentableStoreContainer.get()
            if let navigationBar = vc.navigationController?.navigationBar,
                navigationBar.subviews.first(where: { $0.tag == progressViewTag }) == nil
            {
                let progresView = UIProgressView()
                progresView.backgroundColor = UIColor.brand(.primaryBackground(false))
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
                store.terminateProgressCancellable = store.stateSignal
                    .map({ $0.progress })
                    .removeDuplicates()
                    .receive(on: RunLoop.main)
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

extension View {
    var resetProgressToPreviousValueOnDismiss: some View {
        let store: TerminationContractStore = globalPresentableStoreContainer.get()
        let previousProgress = store.state.previousProgress ?? 0
        return self.onDeinit {
            let store: TerminationContractStore = globalPresentableStoreContainer.get()
            store.send(.setProgress(progress: previousProgress))
        }
    }
}
