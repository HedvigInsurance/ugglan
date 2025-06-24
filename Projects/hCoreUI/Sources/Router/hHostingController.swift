import SwiftUI

@MainActor
public class hHostingController<Content: View>: UIHostingController<Content>, Sendable {
    var onViewWillLayoutSubviews: () -> Void = {}
    var onViewDidLayoutSubviews: () -> Void = {}
    var onViewWillAppear: () -> Void = {}
    var onViewWillDisappear: () -> Void = {}
    private let key = UUID().uuidString
    var onDeinit: @Sendable () -> Void = {}
    private let contentName: String?
    var onDismiss: (() -> Void)? = nil

    public init(rootView: Content, contentName: String? = nil) {
        self.contentName = contentName
        super.init(rootView: rootView)
    }

    public override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        onViewDidLayoutSubviews()
    }

    public override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        onViewWillLayoutSubviews()
    }

    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let name = self.debugDescription.getViewName() {
            logStartView(key, name)
        }
        onViewWillAppear()
    }

    public override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if self.debugDescription.getViewName() != nil {
            logStopView(key)
        }
        onViewWillDisappear()
    }

    public override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        if isBeingDismissed {
            onDismiss?()
        }
    }

    @MainActor required dynamic init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public override func dismiss(animated flag: Bool, completion: (() -> Void)? = nil) {
        super.dismiss(animated: flag, completion: completion)
    }

    deinit {
        self.onDeinit()
    }

    @objc func onCloseButton() {
        self.dismiss(animated: true)
    }

    public override var debugDescription: String {
        return contentName ?? ""
    }
}

extension String {
    fileprivate func getViewName() -> String? {
        if self.lowercased().contains("AnyView".lowercased()) || self.isEmpty || self.contains("Navigation") {
            return nil
        }
        return self
    }
}
