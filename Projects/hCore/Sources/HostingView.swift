//
//  HostingView.swift
//  HostingView
//
//  Created by Sam Pettersson on 2021-09-09.
//  Copyright © 2021 Hedvig AB. All rights reserved.
//

import Foundation
import UIKit
import SwiftUI

public class HostingView<Content: View>: UIView {
    let rootViewHostingController: UIHostingController<Content>

    public required init(
        rootView: Content
    ) {
        self.rootViewHostingController = .init(rootView: rootView)

        super.init(frame: .zero)

        rootViewHostingController.view.backgroundColor = .clear

        addSubview(rootViewHostingController.view)

        rootViewHostingController.view.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }

    required init?(
        coder: NSCoder
    ) {
        fatalError("init(coder:) has not been implemented")
    }

    override open func systemLayoutSizeFitting(
        _ targetSize: CGSize,
        withHorizontalFittingPriority horizontalFittingPriority: UILayoutPriority,
        verticalFittingPriority: UILayoutPriority
    ) -> CGSize {
        rootViewHostingController.view.systemLayoutSizeFitting(
            targetSize,
            withHorizontalFittingPriority: horizontalFittingPriority,
            verticalFittingPriority: verticalFittingPriority
        )
    }

    override open func sizeThatFits(_ size: CGSize) -> CGSize {
        systemLayoutSizeFitting(size)
    }

    override open func sizeToFit() {
        if let superview = superview {
            frame.size = rootViewHostingController.sizeThatFits(in: superview.frame.size)
        } else {
            frame.size = rootViewHostingController.sizeThatFits(in: .zero)
        }
    }
}
