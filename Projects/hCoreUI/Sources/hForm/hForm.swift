import Combine
import Foundation
import SwiftUI
import UIKit
import hCore

struct UpperFormScroller<Content: View>: UIViewRepresentable, Equatable {
    let hostingController: UIHostingController<Content>
    var content: () -> Content
    @SwiftUI.Environment(\.presentableViewUpperScrollView) var upperScrollView
    
    init(@ViewBuilder content: @escaping () -> Content) {
        self.hostingController = UIHostingController(rootView: content())
        self.content = content
    }
    
    func makeCoordinator() -> () {
        return ()
    }
    
    func makeUIView(context: Context) -> UIView {
        if upperScrollView == nil {
            fatalError("Must be used with an upper PresentableView")
        }
        
        self.upperScrollView?.addSubview(self.hostingController.view)
        self.hostingController.view.backgroundColor = .clear
        self.upperScrollView?.backgroundColor = UIColor(base: .brand(.primaryBackground()), elevated: .brand(.secondaryBackground()))
        return UIView()
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {
        self.upperScrollView?.alwaysBounceVertical = true
        
        self.hostingController.rootView = content()

        var contentSize: CGSize = self.hostingController.view.intrinsicContentSize
        contentSize.width = self.upperScrollView?.frame.width ?? 0

        self.hostingController.view.frame.size = contentSize
        self.upperScrollView?.contentSize = contentSize
        self.upperScrollView?.updateConstraintsIfNeeded()
        self.upperScrollView?.layoutIfNeeded()
    }
    
    static func == (lhs: Self, rhs: Self) -> Bool {
        return true
    }
}

public struct hForm<Content: View>: View {
	var content: Content

	public init(
		@ViewBuilder _ builder: () -> Content
	) {
		self.content = builder()
	}

	public var body: some View {
        UpperFormScroller {
			VStack {
				content
			}
			.frame(maxWidth: .infinity)
		}
	}
}
