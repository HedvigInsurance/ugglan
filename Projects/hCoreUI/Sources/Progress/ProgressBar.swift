import Foundation
import SwiftUI
@_spi(Advanced) import SwiftUIIntrospect

public struct ProgressBarView: ViewModifier {
    @Binding var progress: Float?
    @State var progressView = UIProgressView()

    public init(
        progress: Binding<Float?>
    ) {
        _progress = progress
    }

    public func body(content: Content) -> some View {
        content.introspect(.viewController, on: .iOS(.v13...)) { vc in
            let progressViewTag = "navigationProgressBar".hashValue
            if let navigationBar = (vc as? UINavigationController)?.navigationBar,
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
            }

            if let progress = progress {
                UIView.animate(withDuration: 0.4) {
                    progressView.setProgress(progress, animated: true)
                }
            }
            UIView.animate(withDuration: 0.2) {
                progressView.alpha = progress == nil ? 0 : 1
            }
        }
    }
}

extension View {
    public func resetProgressOnDismiss(to value: Float?, for progress: Binding<Float?>) -> some View {
        modifier(ResetProgressViewModifier(toValue: value, progress: progress))
    }
}

struct ResetProgressViewModifier: ViewModifier {
    let toValue: Float?
    @Binding var progress: Float?
    @StateObject private var vm = ResetProgressViewModifierViewModel()
    func body(content: Content) -> some View {
        content.onDeinit {
            Task { @MainActor in
                progress = vm.value
            }
        }
        .task {
            if !vm.didSetValue {
                vm.value = toValue
                vm.didSetValue = true
            }
        }
    }
}

class ResetProgressViewModifierViewModel: ObservableObject {
    var value: Float?
    var didSetValue = false
}
