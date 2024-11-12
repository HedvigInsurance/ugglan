import Foundation
import SwiftUI
@_spi(Advanced) import SwiftUIIntrospect
import hCore
import hCoreUI

struct SubmitClaimProgressBarView: ViewModifier {
    @EnvironmentObject var vm: ClaimsNavigationViewModel
    @State var progressView = UIProgressView()

    func body(content: Content) -> some View {
        content.introspect(.viewController, on: .iOS(.v13...)) { vc in
            let progressViewTag = "navigationProgressBar".hashValue
            if let navigationBar = vc.navigationController?.navigationBar,
                navigationBar.subviews.first(where: { $0.tag == progressViewTag }) == nil
            {

                progressView.backgroundColor = UIColor.brand(.primaryBackground(false))
                progressView.layer.cornerRadius = 2
                progressView.tag = progressViewTag
                progressView.tintColor = .brand(.primaryText(false))
                navigationBar.addSubview(progressView)
                progressView.snp.makeConstraints { make in
                    make.leading.equalToSuperview().offset(15)
                    make.trailing.equalToSuperview().offset(-15)
                    make.top.equalToSuperview()
                    make.height.equalTo(4)
                }

                progressView.progress = vm.progress ?? 0
                progressView.alpha = vm.progress == nil ? 0 : 1
            }
        }
        .onUpdate(of: vm.progress) { newProgress in
            if let newProgress {
                UIView.animate(withDuration: 0.2) {
                    progressView.progress = newProgress
                }
            }
            UIView.animate(withDuration: 0.2) {
                progressView.alpha = newProgress == nil ? 0 : 1
            }
        }
    }
}
