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
    var onDismiss: (() -> Void)?

    public init(rootView: Content, contentName: String? = nil) {
        self.contentName = contentName
        super.init(rootView: rootView)
    }

    override public func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        onViewDidLayoutSubviews()
    }

    override public func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        onViewWillLayoutSubviews()
    }

    override public func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let name = debugDescription.getViewName() {
            logStartView(key, name)
        }
        onViewWillAppear()
    }

    override public func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if debugDescription.getViewName() != nil {
            logStopView(key)
        }
        onViewWillDisappear()
    }

    override public func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        if isBeingDismissed {
            onDismiss?()
        }
    }

    @available(*, unavailable)
    @MainActor dynamic required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override public func dismiss(animated flag: Bool, completion: (() -> Void)? = nil) {
        super.dismiss(animated: flag, completion: completion)
    }

    deinit {
        self.onDeinit()
    }

    @objc func onCloseButton() {
        dismiss(animated: true)
    }

    override public var debugDescription: String {
        contentName ?? ""
    }
}

extension String {
    fileprivate func getViewName() -> String? {
        if lowercased().contains("AnyView".lowercased()) || isEmpty || contains("Navigation") {
            return nil
        }
        return self
    }
}
